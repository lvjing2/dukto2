import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'models.dart';

enum TransferStage {
  platform,
  connection,
  approval,
  upload,
  verification,
  commit,
  storage,
  cleanup,
}

enum TransferFailureKind {
  platform,
  cancelled,
  declined,
  busy,
  expired,
  timeout,
  network,
  certificate,
  invalidData,
  integrity,
  storage,
  unexpected,
}

/// Retains the original exception for diagnosis. Wire responses and UI text do
/// not serialize [cause]: it may contain a path, payload, or capability URL.
class TransferFailure implements Exception {
  final TransferStage stage;
  final TransferFailureKind kind;
  final String operationId;
  final bool incoming;
  final Object cause;
  final StackTrace stackTrace;
  final String? platformCode;

  const TransferFailure({
    required this.stage,
    required this.kind,
    required this.operationId,
    required this.incoming,
    required this.cause,
    required this.stackTrace,
    this.platformCode,
  });

  factory TransferFailure.capture(
    Object error,
    StackTrace stack, {
    required TransferStage stage,
    required String operationId,
    required bool incoming,
    TransferFailureKind? kind,
    String? platformCode,
  }) {
    if (error is TransferFailure) {
      return error;
    }
    return TransferFailure(
      stage: stage,
      operationId: operationId,
      incoming: incoming,
      cause: error,
      stackTrace: stack,
      platformCode: platformCode,
      kind:
          kind ??
          switch (error) {
            TransferCancelled() => TransferFailureKind.cancelled,
            TimeoutException() => TransferFailureKind.timeout,
            HandshakeException() => TransferFailureKind.certificate,
            SocketException() => TransferFailureKind.network,
            FileSystemException() => TransferFailureKind.storage,
            FormatException() => TransferFailureKind.invalidData,
            _ => TransferFailureKind.unexpected,
          },
    );
  }

  Map<String, Object> toJson() => {
    'stage': stage.name, 'kind': kind.name, 'operationId': operationId,
    'incoming': incoming, 'causeType': cause.runtimeType.toString(),
    if (cause case SocketException(:final osError?))
      'osErrorCode': osError.errorCode,
    if (cause case FileSystemException(:final osError?))
      'osErrorCode': osError.errorCode,
    if (platformCode != null &&
        RegExp(r'^[a-zA-Z0-9_]{1,64}$').hasMatch(platformCode!))
      'platformCode': platformCode!,
    // Stack frames retain source locations, never the exception's message.
    'stackTrace': stackTrace
        .toString()
        .split('\n')
        .take(16)
        .map((line) => line.length > 256 ? line.substring(0, 256) : line)
        .join('\n'),
  };

  @override
  String toString() =>
      'TransferFailure(${kind.name}, ${stage.name}, $operationId)';
}

enum TransferLogEvent {
  started,
  stageChanged,
  completed,
  failed,
  cleanupFailed,
}

class TransferLogEntry {
  final DateTime time;
  final String operationId;
  final bool incoming;
  final TransferStage stage;
  final TransferLogEvent event;
  final TransferFailure? failure;
  TransferLogEntry({
    required this.operationId,
    required this.incoming,
    required this.stage,
    required this.event,
    this.failure,
  }) : time = DateTime.now().toUtc();

  Map<String, Object> toJson() => {
    'time': time.toIso8601String(),
    'operationId': operationId,
    'incoming': incoming,
    'stage': stage.name,
    'event': event.name,
    if (failure != null) 'failure': failure!.toJson(),
  };
}

/// Shared, bounded diagnostic journal. IDs are independent of upload/batch
/// tokens. Payload bytes, names, paths and wire error bodies are never logged.
class TransferDiagnostics {
  final int capacity;
  final _entries = ListQueue<TransferLogEntry>();
  final _changes = StreamController<TransferLogEntry>.broadcast();
  bool _closed = false;
  TransferDiagnostics({this.capacity = 200}) {
    if (capacity < 1) throw ArgumentError.value(capacity, 'capacity');
  }
  List<TransferLogEntry> get entries => List.unmodifiable(_entries);
  Stream<TransferLogEntry> get changes => _changes.stream;
  TransferOperation begin({required bool incoming}) =>
      TransferOperation._(this, incoming);
  void recordFailure(TransferFailure failure) {
    if (_entries.any(
      (e) =>
          e.event == TransferLogEvent.failed &&
          e.failure?.operationId == failure.operationId,
    )) {
      return;
    }
    _record(
      TransferLogEntry(
        operationId: failure.operationId,
        incoming: failure.incoming,
        stage: failure.stage,
        event: TransferLogEvent.failed,
        failure: failure,
      ),
    );
  }

  void _record(TransferLogEntry entry) {
    if (_closed) return;
    _entries.add(entry);
    while (_entries.length > capacity) {
      _entries.removeFirst();
    }
    _changes.add(entry);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _changes.close();
  }
}

class TransferOperation {
  final TransferDiagnostics _diagnostics;
  final String id = randomId(8);
  final bool incoming;
  TransferStage stage = TransferStage.connection;
  bool _ended = false;
  TransferOperation._(this._diagnostics, this.incoming) {
    _record(TransferLogEvent.started);
  }
  void move(TransferStage next) {
    if (_ended || next == stage) return;
    stage = next;
    _record(TransferLogEvent.stageChanged);
  }

  void complete() {
    if (_ended) return;
    _record(TransferLogEvent.completed);
    _ended = true;
  }

  TransferFailure capture(
    Object error,
    StackTrace stack, {
    TransferFailureKind? kind,
    TransferStage? at,
  }) => TransferFailure.capture(
    error,
    stack,
    stage: at ?? stage,
    operationId: id,
    incoming: incoming,
    kind: kind,
  );
  TransferFailure fail(
    Object error,
    StackTrace stack, {
    TransferFailureKind? kind,
    TransferStage? at,
  }) {
    final failure = capture(error, stack, kind: kind, at: at);
    if (!_ended) {
      _record(TransferLogEvent.failed, failure);
      _ended = true;
    }
    return failure;
  }

  void cleanupFailed(Object error, StackTrace stack) => _record(
    TransferLogEvent.cleanupFailed,
    capture(error, stack, at: TransferStage.cleanup),
  );
  void _record(TransferLogEvent event, [TransferFailure? failure]) =>
      _diagnostics._record(
        TransferLogEntry(
          operationId: id,
          incoming: incoming,
          stage: failure?.stage ?? stage,
          event: event,
          failure: failure,
        ),
      );
}
