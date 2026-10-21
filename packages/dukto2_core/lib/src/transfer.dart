import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as p;

import 'identity.dart';
import 'models.dart';
import 'receive_target.dart';
import 'diagnostics.dart';

typedef OfferHandler = Future<bool> Function(FileOffer offer);
const _idleTimeout = Duration(seconds: 30);

/// Time available to approve a file, text message, or exact batch manifest.
const receiveApprovalTimeout = Duration(minutes: 5);

// Leave time for the receiver's expiry response to arrive before giving up.
final _offerResponseTimeout =
    receiveApprovalTimeout + const Duration(seconds: 35);

TransferFailureKind _responseFailureKind(int status) => switch (status) {
  403 => TransferFailureKind.declined,
  409 => TransferFailureKind.busy,
  404 => TransferFailureKind.expired,
  422 => TransferFailureKind.integrity,
  _ => TransferFailureKind.unexpected,
};

class _DigestSink implements Sink<crypto.Digest> {
  crypto.Digest? value;
  @override
  void add(crypto.Digest data) => value = data;
  @override
  void close() {}
}

/// An optional v1 extension. Only an authenticated, token-scoped positive
/// response establishes peer cancellation; missing/failed checks mean nothing.
class _CancellationMonitor {
  final Uri endpoint;
  final HttpClient Function() createClient;
  final void Function() onCancelled;
  HttpClient? _client;
  Timer? _timer;
  Future<bool>? _pending;
  bool confirmed = false;
  bool _closed = false;

  _CancellationMonitor(this.endpoint, this.createClient, this.onCancelled);

  void start() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(check()),
    );
  }

  Future<bool> check() {
    if (confirmed) return Future.value(true);
    if (_closed) return Future.value(false);
    return _pending ??= _check().whenComplete(() => _pending = null);
  }

  Future<bool> _check() async {
    try {
      final http = _client ??= createClient()
        ..connectionTimeout = const Duration(seconds: 2);
      final cancelled = await (() async {
        final request = await http.getUrl(endpoint);
        request.followRedirects = false;
        final response = await request.close();
        final body = await _json(response);
        return response.statusCode == 200 && body['cancelled'] == true;
      })().timeout(const Duration(seconds: 2));
      if (!_closed && cancelled) {
        confirmed = true;
        onCancelled();
      }
    } on Object {
      _client?.close(force: true);
      _client = null;
    }
    return confirmed;
  }

  Future<void> close() async {
    _closed = true;
    _timer?.cancel();
    _client?.close(force: true);
    await _pending;
  }
}

Future<Map<String, dynamic>> _json(
  Stream<List<int>> stream, {
  int limit = 8192,
}) async {
  final bytes = <int>[];
  await for (final chunk in stream.timeout(_idleTimeout)) {
    if (bytes.length + chunk.length > limit) {
      throw const FormatException('Message too large');
    }
    bytes.addAll(chunk);
  }
  return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
}

Stream<List<int>> _withCancellation(
  Stream<List<int>> source,
  CancellationToken token,
) {
  late StreamController<List<int>> controller;
  StreamSubscription<List<int>>? subscription;
  void cancel() {
    if (!controller.isClosed) {
      controller.addError(TransferCancelled());
      unawaited(controller.close());
    }
    unawaited(subscription?.cancel());
  }

  controller = StreamController<List<int>>(
    onListen: () {
      subscription = source.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      token.onCancel(cancel);
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () async {
      token.remove(cancel);
      await subscription?.cancel();
    },
  );
  return controller.stream;
}

class _Ticket {
  final String id;
  final FileOffer offer;
  final ReceiveTarget target;
  final TransferOperation operation;
  DateTime expires = DateTime.now().add(const Duration(minutes: 2));
  final cancellation = CancellationToken();
  String? digest;
  bool uploading = false;
  bool discarded = false;
  final String? batchToken;
  _Ticket(this.id, this.offer, this.target, this.operation, {this.batchToken});
}

class _Batch {
  final String token;
  final FileOffer offer;
  int next = 0;
  DateTime expires;
  _Batch(this.token, this.offer, Duration timeout)
    : expires = DateTime.now().add(timeout);
}

/// V1: offer -> explicit approval -> stream upload -> digest checked commit.
/// Only a committed file appears in the receive history.
class TransferServer {
  final TransferDiagnostics diagnostics;
  final bool _ownsDiagnostics;
  final DeviceIdentity identity;
  final DeviceType deviceType;
  String _name;
  String get name => _name;
  final Directory receiveDirectory;
  final OfferHandler onOffer;
  final OfferHandler? onApprovedBatchFile;
  final InternetAddress? bindAddress;
  final ReceiveTargetFactory? createTarget;
  final Duration idleTimeout;
  final Duration batchIdleTimeout;
  final Duration cancellationReceiptLifetime;
  final _cancelled = <String, ({String address, DateTime expires})>{};
  final _progress = StreamController<TransferProgress>.broadcast();
  final _received = StreamController<TransferReceipt>.broadcast();
  final _errors = StreamController<TransferFailure>.broadcast();
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  Timer? _expiry;
  _Ticket? _ticket;
  _Batch? _batch;
  String? _pendingBatchToken;
  String? _pendingBatchAddress;
  Completer<void>? _batchApprovalCancellation;
  bool _awaitingApproval = false;
  bool _closed = false;
  final _shutdown = Completer<void>();
  final _handlers = <Future<void>>{};

  TransferServer({
    required this.identity,
    required String name,
    DeviceType? deviceType,
    required this.receiveDirectory,
    required this.onOffer,
    this.onApprovedBatchFile,
    this.bindAddress,
    this.createTarget,
    this.idleTimeout = _idleTimeout,
    this.batchIdleTimeout = const Duration(minutes: 2),
    this.cancellationReceiptLifetime = const Duration(minutes: 2),
    TransferDiagnostics? diagnostics,
  }) : _name = name,
       diagnostics = diagnostics ?? TransferDiagnostics(),
       _ownsDiagnostics = diagnostics == null,
       deviceType = deviceType ?? DeviceType.hostPlatform;
  void rename(String value) {
    if (value.trim().isEmpty || value.length > 128) {
      throw ArgumentError.value(value, 'name', 'Invalid device name');
    }
    _name = value;
  }

  Stream<TransferProgress> get progress => _progress.stream;
  Stream<TransferReceipt> get received => _received.stream;
  Stream<TransferFailure> get errors => _errors.stream;

  void _emitFailure(
    Object error,
    StackTrace stack, {
    TransferOperation? operation,
    TransferStage stage = TransferStage.connection,
    TransferFailureKind? kind,
    bool notify = true,
  }) {
    final failure = (operation ?? diagnostics.begin(incoming: true)).fail(
      error,
      stack,
      at: stage,
      kind: kind,
    );
    if (!_closed && notify) _errors.add(failure);
  }

  int get port => _server!.port;
  Peer get localPeer => Peer(
    id: identity.id,
    name: name,
    host: '127.0.0.1',
    port: port,
    fingerprint: identity.fingerprint,
    supportsText: true,
    supportsBatch: true,
    deviceType: deviceType,
  );

  Future<void> start({int port = 0}) async {
    await receiveDirectory.create(recursive: true);
    // Recover only our own staging directories after a process interruption.
    await FileReceiveTarget.recover(receiveDirectory);
    await _listen(port);
    _expiry = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_batch != null &&
          _ticket == null &&
          !_awaitingApproval &&
          DateTime.now().isAfter(_batch!.expires)) {
        _batch = null;
        _emitFailure(
          StateError('Batch approval expired'),
          StackTrace.current,
          stage: TransferStage.approval,
          kind: TransferFailureKind.expired,
        );
      }
      final ticket = _ticket;
      if (ticket != null &&
          DateTime.now().isAfter(ticket.expires) &&
          !ticket.uploading) {
        try {
          await _discard(ticket);
          _emitFailure(
            StateError('Transfer expired before completion'),
            StackTrace.current,
            operation: ticket.operation,
            stage: ticket.operation.stage,
            kind: TransferFailureKind.expired,
          );
        } on Object catch (error, stack) {
          _emitFailure(
            error,
            stack,
            operation: ticket.operation,
            stage: TransferStage.cleanup,
          );
        }
      }
    });
  }

  Future<void> _listen(int port) async {
    _server = await HttpServer.bindSecure(
      bindAddress ?? InternetAddress.anyIPv4,
      port,
      identity.securityContext(),
    );
    _server!.idleTimeout = const Duration(seconds: 75);
    _subscription = _server!.listen(
      (request) {
        final handler = _handle(request);
        _handlers.add(handler);
        unawaited(handler.whenComplete(() => _handlers.remove(handler)));
      },
      onError: (Object error, StackTrace stack) {
        _emitFailure(error, stack);
      },
    );
  }

  /// A resumed app may retain an invalidated listener. Rebind only while idle;
  /// discovery restart is independent and never cancels an active upload.
  Future<void> ensureListening() async {
    if (_closed || _ticket != null || _awaitingApproval) return;
    final previousPort = port;
    try {
      final peer = await TransferClient.probe(
        '127.0.0.1',
        previousPort,
        timeout: const Duration(seconds: 1),
      );
      if (peer.fingerprint != identity.fingerprint) {
        throw const HandshakeException('Local listener identity changed');
      }
      return;
    } on Object {
      await _subscription?.cancel();
      await _server?.close(force: true);
      if (!_closed) await _listen(previousPort);
    }
  }

  void cancelIncoming() {
    _batch = null;
    final ticket = _ticket;
    // Once commit starts it may already have published a file. Never advertise
    // cancellation for that completed/committing transaction.
    if (ticket != null && ticket.operation.stage != TransferStage.commit) {
      final now = DateTime.now();
      _cancelled.removeWhere((_, receipt) => !receipt.expires.isAfter(now));
      _cancelled[ticket.id] = (
        address: ticket.offer.remoteAddress,
        expires: now.add(cancellationReceiptLifetime),
      );
      while (_cancelled.length > 128) {
        _cancelled.remove(_cancelled.keys.first);
      }
      ticket.operation.fail(TransferCancelled(), StackTrace.current);
      unawaited(
        _discard(ticket).catchError((Object error, StackTrace stack) {
          ticket.operation.cleanupFailed(error, stack);
        }),
      );
    }
  }

  Future<void> _reply(
    HttpRequest request,
    int status,
    Map<String, Object> body,
  ) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  Future<void> _discard(_Ticket ticket) async {
    if (ticket.batchToken != null && _batch?.token == ticket.batchToken) {
      _batch = null;
    }
    ticket.cancellation.cancel();
    // The upload handler owns the file while its stream is active.
    if (ticket.uploading || ticket.discarded) return;
    ticket.discarded = true;
    if (identical(_ticket, ticket)) _ticket = null;
    await ticket.target.discard();
  }

  Future<void> _handle(HttpRequest request) async {
    _Ticket? activeTicket;
    TransferOperation? operation;
    var applicationOwnsRequest = false;
    try {
      if (request.method == 'GET' && request.uri.path == '/v1/info') {
        await _reply(request, 200, localPeer.toJson());
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/v1/batch') {
        operation = diagnostics.begin(incoming: true)
          ..move(TransferStage.approval);
        if (_awaitingApproval || _ticket != null || _batch != null) {
          operation.fail(
            StateError('Receiver is busy'),
            StackTrace.current,
            kind: TransferFailureKind.busy,
          );
          await _reply(request, 409, {'error': 'Receiver is busy'});
          return;
        }
        _awaitingApproval = true;
        try {
          final body = await _json(request, limit: 1024 * 1024);
          final token = body['token'];
          if (token is! String || !RegExp(r'^[a-f0-9]{48}$').hasMatch(token)) {
            throw const FormatException('Invalid batch request token');
          }
          final offer = batchOfferFromJson(
            body,
            request.connectionInfo!.remoteAddress.address,
          );
          final cancelled = Completer<void>();
          _pendingBatchToken = token;
          _pendingBatchAddress = offer.remoteAddress;
          _batchApprovalCancellation = cancelled;
          applicationOwnsRequest = true;
          final accepted = await Future.any([
            onOffer(offer),
            _shutdown.future.then((_) => false),
            cancelled.future.then((_) => false),
          ]).timeout(receiveApprovalTimeout, onTimeout: () => false);
          if (_closed || !accepted || cancelled.isCompleted) {
            operation.fail(
              StateError('Batch declined or approval timed out'),
              StackTrace.current,
              kind: cancelled.isCompleted
                  ? TransferFailureKind.cancelled
                  : TransferFailureKind.declined,
            );
            await _reply(request, 403, {
              'error': 'Batch declined or approval timed out',
            });
            return;
          }
          final batch = _Batch(token, offer, batchIdleTimeout);
          _batch = batch;
          await _reply(request, 200, {'token': batch.token});
          operation.complete();
        } finally {
          _pendingBatchToken = null;
          _pendingBatchAddress = null;
          _batchApprovalCancellation = null;
          _awaitingApproval = false;
        }
        return;
      }
      final route = request.uri.pathSegments;
      if (request.method == 'DELETE' &&
          route.length == 3 &&
          route[0] == 'v1' &&
          route[1] == 'batch') {
        if (route[2] == _pendingBatchToken &&
            request.connectionInfo!.remoteAddress.address ==
                _pendingBatchAddress) {
          if (_batchApprovalCancellation?.isCompleted == false) {
            _batchApprovalCancellation!.complete();
          }
          _emitFailure(
            TransferCancelled(),
            StackTrace.current,
            stage: TransferStage.approval,
          );
          await _reply(request, 200, {'cancelled': true});
          return;
        }
        final batch = _batch;
        if (batch == null ||
            route[2] != batch.token ||
            request.connectionInfo!.remoteAddress.address !=
                batch.offer.remoteAddress) {
          await _reply(request, 404, {'error': 'Unknown batch'});
          return;
        }
        cancelIncoming();
        _emitFailure(
          TransferCancelled(),
          StackTrace.current,
          stage: TransferStage.approval,
        );
        await _reply(request, 200, {'cancelled': true});
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/v1/offer') {
        operation = diagnostics.begin(incoming: true)
          ..move(TransferStage.approval);
        if (_awaitingApproval || _ticket != null) {
          operation.fail(
            StateError('Receiver is busy'),
            StackTrace.current,
            kind: TransferFailureKind.busy,
          );
          await _reply(request, 409, {'error': 'Receiver is busy'});
          return;
        }
        _awaitingApproval = true;
        try {
          final body = await _json(request);
          final offer = FileOffer.fromJson(
            body,
            request.connectionInfo!.remoteAddress.address,
          );
          final batch = _batch;
          if (batch != null || body['batchToken'] != null) {
            if (batch == null ||
                body['batchToken'] != batch.token ||
                body['batchIndex'] != batch.next ||
                batch.next >= batch.offer.files.length ||
                DateTime.now().isAfter(batch.expires) ||
                offer.remoteAddress != batch.offer.remoteAddress ||
                offer.sender != batch.offer.sender ||
                offer.isText ||
                offer.name != batch.offer.files[batch.next].name ||
                offer.size != batch.offer.files[batch.next].size) {
              operation.fail(
                StateError('File is not in the approved batch'),
                StackTrace.current,
                kind: TransferFailureKind.declined,
              );
              await _reply(request, 403, {
                'error': 'File is not in the approved batch',
              });
              return;
            }
          }
          applicationOwnsRequest = true;
          final accepted = await Future.any([
            batch == null
                ? onOffer(offer)
                : (onApprovedBatchFile?.call(offer) ?? Future.value(true)),
            _shutdown.future.then((_) => false),
          ]).timeout(receiveApprovalTimeout, onTimeout: () => false);
          if (_closed ||
              !accepted ||
              (batch != null && !identical(_batch, batch))) {
            operation.fail(
              StateError('Transfer declined or approval timed out'),
              StackTrace.current,
              kind: TransferFailureKind.declined,
            );
            if (batch != null && identical(_batch, batch)) _batch = null;
            if (batch != null && !_closed) {
              _emitFailure(
                StateError('Batch could not continue'),
                StackTrace.current,
                operation: operation,
                stage: TransferStage.approval,
                kind: TransferFailureKind.declined,
              );
            }
            await _reply(request, 403, {
              'error': 'Transfer declined or approval timed out',
            });
            return;
          }
          final id = randomId();
          operation.move(TransferStage.storage);
          final target = offer.isText
              ? TextReceiveTarget(
                  storage: offer.size > maxInlineTextBytes
                      ? await (createTarget?.call(id, offer) ??
                            FileReceiveTarget.create(receiveDirectory, id))
                      : null,
                )
              : await (createTarget?.call(id, offer) ??
                    FileReceiveTarget.create(receiveDirectory, id));
          if (_closed) {
            await target.discard();
            return;
          }
          if (batch != null && !identical(_batch, batch)) {
            await target.discard();
            await _reply(request, 403, {'error': 'Batch cancelled'});
            return;
          }
          _ticket = _Ticket(
            id,
            offer,
            target,
            operation,
            batchToken: batch?.token,
          );
          await _reply(request, 200, {'token': id, 'cancelStatus': true});
        } finally {
          _awaitingApproval = false;
        }
        return;
      }
      final segments = request.uri.pathSegments;
      if (request.method == 'GET' &&
          segments.length == 3 &&
          segments[0] == 'v1' &&
          segments[1] == 'status') {
        final receipt = _cancelled[segments[2]];
        if (receipt != null &&
            receipt.address == request.connectionInfo!.remoteAddress.address &&
            receipt.expires.isAfter(DateTime.now())) {
          await _reply(request, 200, {'cancelled': true});
          return;
        }
        if (receipt != null && !receipt.expires.isAfter(DateTime.now())) {
          _cancelled.remove(segments[2]);
        }
      }
      final ticket = _ticket;
      if (segments.length != 3 ||
          segments[0] != 'v1' ||
          ticket == null ||
          segments[2] != ticket.id ||
          request.connectionInfo!.remoteAddress.address !=
              ticket.offer.remoteAddress ||
          DateTime.now().isAfter(ticket.expires)) {
        await _reply(request, 404, {'error': 'Unknown or expired transfer'});
        return;
      }
      if (request.method == 'GET' && segments[1] == 'status') {
        // A read-only poll must never own cleanup or emit a transfer failure if
        // its connection closes while a separate upload/commit is running.
        await _reply(request, 200, {'cancelled': false});
        return;
      }
      activeTicket = ticket;
      operation = ticket.operation;
      if (request.method == 'DELETE' && segments[1] == 'file') {
        final wasUploading = ticket.uploading;
        await _discard(ticket);
        if (!wasUploading) {
          _emitFailure(
            TransferCancelled(),
            StackTrace.current,
            operation: operation,
            stage: operation.stage,
          );
        }
        await _reply(request, 200, {'cancelled': true});
        return;
      }
      if (request.method == 'PUT' && segments[1] == 'file') {
        operation.move(TransferStage.upload);
        if (ticket.uploading || ticket.digest != null) {
          await _reply(request, 409, {'error': 'Upload already started'});
          return;
        }
        if (request.contentLength != ticket.offer.size) {
          await _discard(ticket);
          _emitFailure(
            const FormatException('Content length differs from offer'),
            StackTrace.current,
            operation: operation,
            stage: TransferStage.verification,
            kind: TransferFailureKind.integrity,
          );
          await _reply(request, 400, {
            'error': 'Content length differs from offer',
          });
          return;
        }
        ticket.uploading = true;
        final digest = _DigestSink();
        final hash = crypto.sha256.startChunkedConversion(digest);
        var bytes = 0;
        var succeeded = false;
        Object? primaryError;
        try {
          ticket.cancellation.check();
          _progress.add(
            TransferProgress(
              id: ticket.id,
              name: ticket.offer.name,
              total: ticket.offer.size,
              bytes: 0,
              incoming: true,
            ),
          );
          await ticket.target.addStream(
            _withCancellation(
              request,
              ticket.cancellation,
            ).timeout(idleTimeout).map((chunk) {
              ticket.cancellation.check();
              ticket.expires = DateTime.now().add(const Duration(minutes: 2));
              bytes += chunk.length;
              if (bytes > ticket.offer.size) {
                throw const FormatException('Upload exceeded offered size');
              }
              hash.add(chunk);
              _progress.add(
                TransferProgress(
                  id: ticket.id,
                  name: ticket.offer.name,
                  total: ticket.offer.size,
                  bytes: bytes,
                  incoming: true,
                ),
              );
              return chunk;
            }),
          );
          ticket.cancellation.check();
          if (bytes != ticket.offer.size) {
            throw const FormatException('Incomplete file');
          }
          hash.close();
          ticket.expires = DateTime.now().add(const Duration(minutes: 2));
          ticket.digest = digest.value.toString();
          succeeded = true;
        } on Object catch (error, stack) {
          primaryError = operation.capture(
            error,
            stack,
            at: error is FileSystemException ? TransferStage.storage : null,
          );
          Error.throwWithStackTrace(primaryError, stack);
        } finally {
          try {
            await ticket.target.close();
          } on Object catch (error, stack) {
            if (primaryError == null) {
              primaryError = operation.capture(
                error,
                stack,
                at: TransferStage.storage,
              );
              Error.throwWithStackTrace(primaryError, stack);
            }
            operation.cleanupFailed(error, stack);
          } finally {
            ticket.uploading = false;
            if (!succeeded || primaryError != null) {
              try {
                await _discard(ticket);
              } on Object catch (error, stack) {
                if (primaryError == null) rethrow;
                operation.cleanupFailed(error, stack);
              }
            }
          }
        }
        await _reply(request, 200, {'sha256': ticket.digest!, 'size': bytes});
        return;
      }
      if (request.method == 'POST' && segments[1] == 'commit') {
        operation.move(TransferStage.verification);
        final body = await _json(request);
        ticket.cancellation.check();
        if (ticket.uploading ||
            ticket.digest == null ||
            body['sha256'] != ticket.digest) {
          await _discard(ticket);
          _emitFailure(
            const FormatException('File checksum mismatch or upload missing'),
            StackTrace.current,
            operation: operation,
            stage: operation.stage,
            kind: TransferFailureKind.integrity,
          );
          await _reply(request, 422, {
            'error': 'File checksum mismatch or upload missing',
          });
          return;
        }
        operation.move(TransferStage.commit);
        final receipt = await ticket.target.commit(
          ticket.offer,
          ticket.digest!,
        );
        _ticket = null;
        final batch = _batch;
        if (batch != null && ticket.batchToken == batch.token) {
          batch.next++;
          batch.expires = DateTime.now().add(batchIdleTimeout);
          if (batch.next == batch.offer.files.length) _batch = null;
        }
        _received.add(receipt);
        operation.complete();
        await _reply(request, 200, {
          'committed': true,
          'sha256': ticket.digest!,
        });
        return;
      }
      await _reply(request, 405, {'error': 'Unsupported operation'});
    } on Object catch (error, stack) {
      if (activeTicket != null && !activeTicket.uploading) {
        try {
          await _discard(activeTicket);
        } on Object catch (cleanup, cleanupStack) {
          activeTicket.operation.cleanupFailed(cleanup, cleanupStack);
        }
      }
      _emitFailure(
        error,
        stack,
        operation: operation,
        stage: operation?.stage ?? TransferStage.connection,
        notify: applicationOwnsRequest || activeTicket != null,
      );
      try {
        await _reply(request, 400, {'error': 'Transfer failed'});
      } on Object {
        /* Disconnected client. */
      }
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _cancelled.clear();
    _batch = null;
    _shutdown.complete();
    _expiry?.cancel();
    _ticket?.cancellation.cancel();
    await _subscription?.cancel();
    await _server?.close(force: true);
    await Future.wait(_handlers.toList());
    final ticket = _ticket;
    if (ticket != null && !ticket.uploading) await _discard(ticket);
    await _progress.close();
    await _received.close();
    await _errors.close();
    if (_ownsDiagnostics) await diagnostics.close();
  }
}

class TransferClient {
  final TransferDiagnostics diagnostics;
  final bool _ownsDiagnostics;

  /// Maximum upload time without the HTTP sink consuming non-empty data.
  /// Sustained progress is not subject to a fixed whole-file deadline.
  final Duration uploadIdleTimeout;
  TransferClient({
    TransferDiagnostics? diagnostics,
    this.uploadIdleTimeout = _idleTimeout,
  }) : diagnostics = diagnostics ?? TransferDiagnostics(),
       _ownsDiagnostics = diagnostics == null {
    if (uploadIdleTimeout <= Duration.zero) {
      throw ArgumentError.value(uploadIdleTimeout, 'uploadIdleTimeout');
    }
  }
  final _progress = StreamController<TransferProgress>.broadcast();
  Stream<TransferProgress> get progress => _progress.stream;

  Future<String> offerBatch({
    required Peer peer,
    required String sender,
    required List<FileOffer> files,
    CancellationToken? cancellation,
  }) async {
    if (!peer.supportsBatch) {
      throw const FormatException('对方版本不支持整批接收，请先更新对方的 Dukto2');
    }
    final batchToken = randomId();
    final body = {
      'token': batchToken,
      'sender': sender,
      'files': [
        for (final file in files) {'name': file.name, 'size': file.size},
      ],
    };
    batchOfferFromJson(body, '');
    final token = cancellation ?? CancellationToken();
    token.check();
    final http = _client(peer.fingerprint);
    void abort() => http.close(force: true);
    token.onCancel(abort);
    final operation = diagnostics.begin(incoming: false);
    try {
      final request = await http.postUrl(
        Uri(
          scheme: 'https',
          host: peer.host,
          port: peer.port,
          path: '/v1/batch',
        ),
      );
      request.followRedirects = false;
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
      operation.move(TransferStage.approval);
      final response = await request.close().timeout(_offerResponseTimeout);
      final reply = await _json(response);
      if (response.statusCode != 200) {
        throw operation.capture(
          HttpException(reply['error']?.toString() ?? 'Batch declined'),
          StackTrace.current,
          kind: _responseFailureKind(response.statusCode),
        );
      }
      final batch = reply['token'];
      if (batch is! String || batch != batchToken) {
        throw const FormatException('Invalid batch token');
      }
      operation.complete();
      return batch;
    } on Object catch (error, stack) {
      if (token.isCancelled) {
        await cancelBatch(peer, batchToken);
        operation.fail(TransferCancelled(), stack);
        throw TransferCancelled();
      }
      Error.throwWithStackTrace(operation.fail(error, stack), stack);
    } finally {
      token.remove(abort);
      http.close(force: true);
    }
  }

  Future<void> cancelBatch(Peer peer, String token) async {
    if (!RegExp(r'^[a-f0-9]{48}$').hasMatch(token)) return;
    final http = _client(peer.fingerprint);
    final operation = diagnostics.begin(incoming: false)
      ..move(TransferStage.cleanup);
    try {
      final request = await http
          .deleteUrl(
            Uri(
              scheme: 'https',
              host: peer.host,
              port: peer.port,
              path: '/v1/batch/$token',
            ),
          )
          .timeout(const Duration(seconds: 2));
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 2),
      );
      await response.drain<void>().timeout(const Duration(seconds: 2));
      operation.complete();
    } on Object catch (error, stack) {
      operation.cleanupFailed(error, stack);
      // An unreachable receiver expires the in-memory grant automatically.
    } finally {
      http.close(force: true);
    }
  }

  static HttpClient _client(String fingerprint) {
    final client = HttpClient(context: SecurityContext(withTrustedRoots: false))
      ..findProxy = ((_) => 'DIRECT')
      ..connectionTimeout = const Duration(seconds: 8)
      ..idleTimeout = _idleTimeout;
    client.badCertificateCallback = (certificate, host, port) =>
        crypto.sha256.convert(certificate.der).toString() == fingerprint;
    return client;
  }

  /// This only reads an unauthenticated candidate identity. No file is sent until
  /// the user compares the displayed code with the receiving device.
  static Future<Peer> probe(
    String host,
    int port, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final address = InternetAddress.tryParse(host);
    if (address == null ||
        address.type != InternetAddressType.IPv4 ||
        port < 1 ||
        port > 65535) {
      throw const FormatException(
        'Enter an IPv4 address and a port between 1 and 65535',
      );
    }
    final client = HttpClient(context: SecurityContext(withTrustedRoots: false))
      ..findProxy = ((_) => 'DIRECT')
      ..connectionTimeout = timeout;
    String? observed;
    client.badCertificateCallback = (certificate, _, _) {
      observed = crypto.sha256.convert(certificate.der).toString();
      return true;
    };
    try {
      return await (() async {
        final request = await client.getUrl(
          Uri(scheme: 'https', host: host, port: port, path: '/v1/info'),
        );
        request.followRedirects = false;
        final response = await request.close().timeout(_idleTimeout);
        if (response.statusCode != 200) {
          throw const HttpException('Peer info unavailable');
        }
        final peer = Peer.fromJson(await _json(response), host);
        if (peer.fingerprint != observed) {
          throw const HandshakeException('Peer certificate changed');
        }
        return peer;
      })().timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }

  Future<TransferReceipt> sendFile({
    required Peer peer,
    required File file,
    required String sender,
    String? name,
    CancellationToken? cancellation,
  }) async => sendStream(
    peer: peer,
    name: name ?? p.basename(file.path),
    size: await file.length(),
    openRead: file.openRead,
    sender: sender,
    cancellation: cancellation,
  );

  /// Platform file pickers can supply a stream without a filesystem path (Android SAF).
  Future<TransferReceipt> sendText({
    required Peer peer,
    required String text,
    required String sender,
    CancellationToken? cancellation,
  }) async {
    final bytes = utf8.encode(text);
    if (text.trim().isEmpty || bytes.length > maxTextBytes) {
      throw const FormatException(
        'Text must contain 1 byte to 16 MiB of UTF-8',
      );
    }
    final receipt = await sendStream(
      peer: peer,
      name: '文本消息',
      size: bytes.length,
      openRead: () => Stream.value(bytes),
      sender: sender,
      kind: TransferKind.text,
      cancellation: cancellation,
    );
    return TransferReceipt(
      name: receipt.name,
      size: receipt.size,
      sha256: receipt.sha256,
      text: bytes.length > maxInlineTextBytes ? textPreview(text) : text,
      textTruncated: bytes.length > maxInlineTextBytes,
    );
  }

  Future<TransferReceipt> sendStream({
    required Peer peer,
    required String name,
    required int size,
    required Stream<List<int>> Function() openRead,
    required String sender,
    TransferKind kind = TransferKind.file,
    CancellationToken? cancellation,
    String? batchToken,
    int? batchIndex,
  }) async {
    final token = cancellation ?? CancellationToken();
    token.check();
    if (kind == TransferKind.text && !peer.supportsText) {
      throw const FormatException(
        'Peer does not support text; update the receiver',
      );
    }
    final fileName = name;
    final offer = FileOffer.fromJson({
      'sender': sender,
      'name': fileName,
      'size': size,
      if (kind == TransferKind.text) 'kind': 'text',
    }, '');
    final client = _client(peer.fingerprint);
    final uploadCancellation = CancellationToken();
    final uploadStopped = Completer<void>();
    void abort() {
      uploadCancellation.cancel();
      client.close(force: true);
      if (!uploadStopped.isCompleted) uploadStopped.complete();
    }

    token.onCancel(abort);
    _CancellationMonitor? cancellationMonitor;
    String? transferId;
    var committed = false;
    var uploadTimedOut = false;
    final operation = diagnostics.begin(incoming: false);
    Uri uri(String path) =>
        Uri(scheme: 'https', host: peer.host, port: peer.port, path: path);
    Future<Map<String, dynamic>> jsonRequest(
      String path,
      Map<String, Object> data, {
      Duration timeout = _idleTimeout,
    }) async {
      token.check();
      final request = await client.postUrl(uri(path));
      operation.move(
        path == '/v1/offer' ? TransferStage.approval : TransferStage.commit,
      );
      request.followRedirects = false;
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(data));
      final response = await request.close().timeout(timeout);
      final body = await _json(response);
      if (response.statusCode != 200) {
        throw operation.capture(
          HttpException(body['error']?.toString() ?? 'Peer rejected transfer'),
          StackTrace.current,
          kind: _responseFailureKind(response.statusCode),
        );
      }
      return body;
    }

    try {
      final accepted = await jsonRequest('/v1/offer', {
        ...offer.toJson(),
        'batchToken': ?batchToken,
        'batchIndex': ?batchIndex,
      }, timeout: _offerResponseTimeout);
      transferId = accepted['token'] as String;
      if (!RegExp(r'^[a-f0-9]{48}$').hasMatch(transferId)) {
        throw const FormatException('Invalid transfer token');
      }
      if (accepted['cancelStatus'] == true) {
        cancellationMonitor = _CancellationMonitor(
          uri('/v1/status/$transferId'),
          () => _client(peer.fingerprint),
          abort,
        )..start();
      }
      token.check();
      final request = await client.putUrl(uri('/v1/file/$transferId'));
      operation.move(TransferStage.upload);
      _progress.add(
        TransferProgress(
          id: transferId,
          name: fileName,
          total: size,
          bytes: 0,
          incoming: false,
        ),
      );
      request.followRedirects = false;
      request.contentLength = size;
      request.headers.contentType = ContentType.binary;
      final digest = _DigestSink();
      final hash = crypto.sha256.startChunkedConversion(digest);
      var bytes = 0;
      Timer? uploadTimer;
      void resetUploadTimer() {
        uploadTimer?.cancel();
        uploadTimer = Timer(uploadIdleTimeout, () {
          uploadTimedOut = true;
          // Abort resources as well as finishing the caller's wait. Closing a
          // socket alone may leave addStream waiting on a paused subscription.
          abort();
        });
      }

      resetUploadTimer();
      try {
        await Future.any<void>([
          request.addStream(
            _withCancellation(openRead(), uploadCancellation).map((chunk) {
              token.check();
              if (chunk.isNotEmpty) resetUploadTimer();
              bytes += chunk.length;
              hash.add(chunk);
              _progress.add(
                TransferProgress(
                  id: transferId!,
                  name: fileName,
                  total: size,
                  bytes: bytes,
                  incoming: false,
                ),
              );
              return chunk;
            }),
          ),
          uploadStopped.future.then<void>((_) => throw TransferCancelled()),
        ]);
      } finally {
        uploadTimer?.cancel();
      }
      // A forcibly closed HttpClient may finish addStream without an error.
      // Never advance to verification/commit after the watchdog stopped it.
      if (uploadTimedOut) {
        throw TimeoutException('Upload made no progress', uploadIdleTimeout);
      }
      uploadCancellation.check();
      hash.close();
      operation.move(TransferStage.verification);
      final response = await request.close().timeout(_idleTimeout);
      final uploaded = await _json(response);
      final checksum = digest.value.toString();
      if (response.statusCode != 200) {
        throw operation.capture(
          const HttpException('Upload failed'),
          StackTrace.current,
          kind: _responseFailureKind(response.statusCode),
        );
      }
      if (uploaded['sha256'] != checksum ||
          uploaded['size'] != size ||
          bytes != size) {
        throw operation.capture(
          const HttpException('Upload failed or checksum mismatch'),
          StackTrace.current,
          kind: TransferFailureKind.integrity,
        );
      }
      final receipt = await jsonRequest('/v1/commit/$transferId', {
        'sha256': checksum,
      });
      if (receipt['committed'] != true || receipt['sha256'] != checksum) {
        throw const HttpException('Missing commit acknowledgement');
      }
      committed = true;
      operation.complete();
      return TransferReceipt(name: fileName, size: size, sha256: checksum);
    } on Object catch (error, stack) {
      if (token.isCancelled) {
        operation.fail(TransferCancelled(), stack);
        throw TransferCancelled();
      }
      if (await cancellationMonitor?.check() == true) {
        final cancelled = TransferCancelled(byPeer: true);
        operation.fail(cancelled, stack);
        throw cancelled;
      }
      final cause = uploadTimedOut
          ? TimeoutException('Upload made no progress', uploadIdleTimeout)
          : error;
      Error.throwWithStackTrace(operation.fail(cause, stack), stack);
    } finally {
      token.remove(abort);
      await cancellationMonitor?.close();
      client.close(force: true);
      if (!committed && transferId != null) {
        final cleanup = _client(peer.fingerprint);
        try {
          final request = await cleanup
              .deleteUrl(uri('/v1/file/$transferId'))
              .timeout(const Duration(seconds: 2));
          final response = await request.close().timeout(
            const Duration(seconds: 2),
          );
          await response.drain<void>().timeout(const Duration(seconds: 2));
        } on Object catch (error, stack) {
          operation.cleanupFailed(error, stack);
          /* Receiver expires orphaned tickets automatically. */
        } finally {
          cleanup.close(force: true);
        }
      }
    }
  }

  Future<void> close() async {
    await _progress.close();
    if (_ownsDiagnostics) await diagnostics.close();
  }
}
