import 'dart:async';

import 'package:dukto2_core/dukto2_core.dart';

enum SendPhase {
  idle,
  ready,
  waiting,
  uploading,
  verifying,
  sent,
  cancelled,
  failed,
}

enum SessionDirection { outgoing, incoming }

enum SessionPhase {
  awaitingApproval,
  waiting,
  uploading,
  verifying,
  completing,
  cancelling,
  completed,
  cancelled,
  declined,
  failed,
}

/// One active transfer, including every file in an explicitly approved batch.
/// Approval, payload timing, cancellation and terminal cleanup have one owner.
class TransferSession {
  final String id = randomId(8);
  final SessionDirection direction;
  final int totalFiles;
  final String peerName;
  final CancellationToken cancellation = CancellationToken();
  final FileOffer? _request;
  final Completer<bool>? _approval;
  SessionPhase _phase;
  FileOffer? _offer;
  TransferProgress? _progress;
  Stopwatch? _clock;
  DateTime? _started;
  int _completedFiles = 0;
  Future<void>? _finishing;
  Future<bool>? _decision;
  final _starts = <Future<void>>{};

  TransferSession.outgoing({this.totalFiles = 1, required this.peerName})
    : direction = SessionDirection.outgoing,
      _request = null,
      _approval = null,
      _phase = SessionPhase.waiting;
  TransferSession.incoming(FileOffer offer)
    : direction = SessionDirection.incoming,
      totalFiles = offer.isBatch ? offer.files.length : 1,
      peerName = offer.sender,
      _request = offer,
      _offer = offer,
      _approval = Completer<bool>(),
      _phase = SessionPhase.awaitingApproval;

  SessionPhase get phase => _phase;
  bool get incoming => direction == SessionDirection.incoming;
  bool get active => switch (_phase) {
    SessionPhase.completed ||
    SessionPhase.cancelled ||
    SessionPhase.declined ||
    SessionPhase.failed => false,
    _ => true,
  };
  bool get receiving =>
      incoming &&
      active &&
      _phase != SessionPhase.awaitingApproval &&
      _phase != SessionPhase.cancelling;
  bool get sending => !incoming && active;
  int get remainingFiles => active ? totalFiles - _completedFiles : 0;
  FileOffer? get pendingOffer =>
      _phase == SessionPhase.awaitingApproval ? _request : null;
  FileOffer? get offer => _offer;
  TransferProgress? get progress => _progress;
  DateTime? get started => _started;
  Duration? get elapsed => _clock?.elapsed;
  SendPhase get sendPhase => switch (_phase) {
    SessionPhase.awaitingApproval || SessionPhase.waiting => SendPhase.waiting,
    SessionPhase.uploading => SendPhase.uploading,
    SessionPhase.verifying || SessionPhase.completing => SendPhase.verifying,
    SessionPhase.cancelling || SessionPhase.cancelled => SendPhase.cancelled,
    SessionPhase.completed => SendPhase.sent,
    SessionPhase.declined || SessionPhase.failed => SendPhase.failed,
  };

  Future<bool> awaitApproval({Duration timeout = receiveApprovalTimeout}) =>
      _decision ??= _awaitApproval(timeout);

  Future<bool> _awaitApproval(Duration timeout) async {
    final approved = await _approval!.future.timeout(
      timeout,
      onTimeout: () => false,
    );
    if (_phase != SessionPhase.awaitingApproval) return false;
    _phase = approved ? SessionPhase.waiting : SessionPhase.declined;
    if (!approved) _offer = null;
    return approved;
  }

  void answer(bool accept) {
    if (_approval?.isCompleted == false) _approval!.complete(accept);
  }

  void beginFile({FileOffer? offer, bool alreadyApproved = false}) {
    if (!active ||
        _phase == SessionPhase.cancelling ||
        _completedFiles >= totalFiles) {
      return;
    }
    _offer = offer;
    _progress = null;
    _clock = null;
    _started = null;
    _phase = alreadyApproved ? SessionPhase.uploading : SessionPhase.waiting;
  }

  void updateProgress(TransferProgress progress) {
    if (!active ||
        _phase == SessionPhase.cancelling ||
        progress.incoming != incoming) {
      return;
    }
    _progress = progress;
    _clock ??= Stopwatch()..start();
    _started ??= DateTime.now();
    _phase = progress.bytes == progress.total
        ? SessionPhase.verifying
        : SessionPhase.uploading;
  }

  Duration? completeFile() {
    if (!active ||
        _phase == SessionPhase.cancelling ||
        _completedFiles >= totalFiles) {
      return null;
    }
    _clock?.stop();
    final duration = _clock?.elapsed;
    _completedFiles++;
    _progress = null;
    _offer = null;
    _clock = null;
    _started = null;
    _phase = _completedFiles == totalFiles
        ? SessionPhase.completing
        : SessionPhase.waiting;
    return duration;
  }

  void cancel() {
    if (!active) return;
    answer(false);
    cancellation.cancel();
    _phase = SessionPhase.cancelling;
  }

  Future<void> acquire(Future<void> Function() start) {
    if (!active || cancellation.isCancelled || _finishing != null) {
      return Future.error(TransferCancelled());
    }
    final result = Completer<void>();
    final future = result.future;
    _starts.add(future);
    unawaited(
      future.then<void>(
        (_) {
          _starts.remove(future);
        },
        onError: (Object _, StackTrace _) {
          _starts.remove(future);
        },
      ),
    );
    Future<void>.sync(start).then(
      result.complete,
      onError: (Object error, StackTrace stack) =>
          result.completeError(error, stack),
    );
    return future;
  }

  /// Repeated cancellation, completion and shutdown share the same cleanup.
  /// The session stays busy until cleanup settles, preventing a new batch from
  /// acquiring platform resources while the previous one is releasing them.
  Future<void> finish(SessionPhase terminal, Future<void> Function() cleanup) {
    return _finishing ??= () async {
      if (_phase != SessionPhase.cancelling) _phase = SessionPhase.completing;
      try {
        // A late native start must settle before the matching stop is sent.
        await Future.wait(
          _starts.toList().map((future) async {
            try {
              await future;
            } on Object {
              /* The acquirer retains the error. */
            }
          }),
        );
        await cleanup();
      } finally {
        answer(false);
        _clock?.stop();
        _progress = null;
        _offer = null;
        _phase = terminal;
      }
    }();
  }
}
