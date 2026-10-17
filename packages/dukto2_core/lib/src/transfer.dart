import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as p;

import 'identity.dart';
import 'models.dart';

typedef OfferHandler = Future<bool> Function(FileOffer offer);
const _idleTimeout = Duration(seconds: 30);
const _approvalTimeout = Duration(seconds: 60);

class _DigestSink implements Sink<crypto.Digest> {
  crypto.Digest? value;
  @override
  void add(crypto.Digest data) => value = data;
  @override
  void close() {}
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

class _Ticket {
  final String id;
  final FileOffer offer;
  final Directory directory;
  DateTime expires = DateTime.now().add(const Duration(minutes: 2));
  final cancellation = CancellationToken();
  String? digest;
  bool uploading = false;
  _Ticket(this.id, this.offer, this.directory);
  File get temporary => File(p.join(directory.path, '.partial'));
}

/// V1: offer -> explicit approval -> stream upload -> digest checked commit.
/// Only a committed file appears in the receive history.
class TransferServer {
  final DeviceIdentity identity;
  final String name;
  final Directory receiveDirectory;
  final OfferHandler onOffer;
  final InternetAddress? bindAddress;
  final _progress = StreamController<TransferProgress>.broadcast();
  final _received = StreamController<TransferReceipt>.broadcast();
  final _errors = StreamController<String>.broadcast();
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  Timer? _expiry;
  _Ticket? _ticket;
  bool _awaitingApproval = false;
  bool _closed = false;
  final _shutdown = Completer<void>();
  final _handlers = <Future<void>>{};

  TransferServer({
    required this.identity,
    required this.name,
    required this.receiveDirectory,
    required this.onOffer,
    this.bindAddress,
  });
  Stream<TransferProgress> get progress => _progress.stream;
  Stream<TransferReceipt> get received => _received.stream;
  Stream<String> get errors => _errors.stream;
  int get port => _server!.port;
  Peer get localPeer => Peer(
    id: identity.id,
    name: name,
    host: '127.0.0.1',
    port: port,
    fingerprint: identity.fingerprint,
  );

  Future<void> start({int port = 0}) async {
    await receiveDirectory.create(recursive: true);
    // Recover only our own staging directories after a process interruption.
    await for (final entity in receiveDirectory.list(followLinks: false)) {
      if (entity is Directory &&
          RegExp(r'^[a-f0-9]{48}$').hasMatch(p.basename(entity.path))) {
        if (await File(p.join(entity.path, '.partial')).exists() ||
            await entity.list().isEmpty) {
          await entity.delete(recursive: true);
        }
      }
    }
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
      onError: (Object error) {
        if (!_closed) _errors.add(error.toString());
      },
    );
    _expiry = Timer.periodic(const Duration(seconds: 5), (_) async {
      final ticket = _ticket;
      if (ticket != null &&
          DateTime.now().isAfter(ticket.expires) &&
          !ticket.uploading) {
        await _discard(ticket);
      }
    });
  }

  void cancelIncoming() {
    final ticket = _ticket;
    if (ticket != null) unawaited(_discard(ticket));
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
    ticket.cancellation.cancel();
    // The upload handler owns the file while its stream is active.
    if (ticket.uploading) return;
    if (identical(_ticket, ticket)) _ticket = null;
    if (await ticket.directory.exists()) {
      await ticket.directory.delete(recursive: true);
    }
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      if (request.method == 'GET' && request.uri.path == '/v1/info') {
        await _reply(request, 200, localPeer.toJson());
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/v1/offer') {
        if (_awaitingApproval || _ticket != null) {
          await _reply(request, 409, {'error': 'Receiver is busy'});
          return;
        }
        _awaitingApproval = true;
        try {
          final offer = FileOffer.fromJson(
            await _json(request),
            request.connectionInfo!.remoteAddress.address,
          );
          final accepted = await Future.any([
            onOffer(offer),
            _shutdown.future.then((_) => false),
          ]).timeout(_approvalTimeout, onTimeout: () => false);
          if (_closed || !accepted) {
            await _reply(request, 403, {
              'error': 'Transfer declined or approval timed out',
            });
            return;
          }
          final id = randomId();
          final directory = await Directory(
            p.join(receiveDirectory.path, id),
          ).create();
          _ticket = _Ticket(id, offer, directory);
          await _reply(request, 200, {'token': id});
        } finally {
          _awaitingApproval = false;
        }
        return;
      }
      final segments = request.uri.pathSegments;
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
      if (request.method == 'DELETE' && segments[1] == 'file') {
        await _discard(ticket);
        await _reply(request, 200, {'cancelled': true});
        return;
      }
      if (request.method == 'PUT' && segments[1] == 'file') {
        if (ticket.uploading || ticket.digest != null) {
          await _reply(request, 409, {'error': 'Upload already started'});
          return;
        }
        if (request.contentLength != ticket.offer.size) {
          await _discard(ticket);
          await _reply(request, 400, {
            'error': 'Content length differs from offer',
          });
          return;
        }
        ticket.uploading = true;
        final digest = _DigestSink();
        final hash = crypto.sha256.startChunkedConversion(digest);
        final sink = ticket.temporary.openWrite();
        var bytes = 0;
        var succeeded = false;
        try {
          ticket.cancellation.check();
          await sink.addStream(
            request.timeout(_idleTimeout).map((chunk) {
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
          await sink.flush();
          ticket.cancellation.check();
          if (bytes != ticket.offer.size) {
            throw const FormatException('Incomplete file');
          }
          hash.close();
          ticket.expires = DateTime.now().add(const Duration(minutes: 2));
          ticket.digest = digest.value.toString();
          succeeded = true;
        } finally {
          try {
            await sink.close();
          } finally {
            ticket.uploading = false;
            if (!succeeded) await _discard(ticket);
          }
        }
        await _reply(request, 200, {'sha256': ticket.digest!, 'size': bytes});
        return;
      }
      if (request.method == 'POST' && segments[1] == 'commit') {
        final body = await _json(request);
        ticket.cancellation.check();
        if (ticket.uploading ||
            ticket.digest == null ||
            body['sha256'] != ticket.digest) {
          await _discard(ticket);
          await _reply(request, 422, {
            'error': 'File checksum mismatch or upload missing',
          });
          return;
        }
        final file = await ticket.temporary.rename(
          p.join(ticket.directory.path, ticket.offer.name),
        );
        _ticket = null;
        _received.add(
          TransferReceipt(
            name: ticket.offer.name,
            size: ticket.offer.size,
            sha256: ticket.digest!,
            file: file,
          ),
        );
        await _reply(request, 200, {
          'committed': true,
          'sha256': ticket.digest!,
        });
        return;
      }
      await _reply(request, 405, {'error': 'Unsupported operation'});
    } on Object catch (error) {
      if (!_closed) _errors.add(error.toString());
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
  }
}

class TransferClient {
  final _progress = StreamController<TransferProgress>.broadcast();
  Stream<TransferProgress> get progress => _progress.stream;

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
  static Future<Peer> probe(String host, int port) async {
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
      ..connectionTimeout = const Duration(seconds: 8);
    String? observed;
    client.badCertificateCallback = (certificate, _, _) {
      observed = crypto.sha256.convert(certificate.der).toString();
      return true;
    };
    try {
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
  Future<TransferReceipt> sendStream({
    required Peer peer,
    required String name,
    required int size,
    required Stream<List<int>> Function() openRead,
    required String sender,
    CancellationToken? cancellation,
  }) async {
    final token = cancellation ?? CancellationToken();
    token.check();
    final fileName = name;
    final offer = FileOffer.fromJson({
      'sender': sender,
      'name': fileName,
      'size': size,
    }, '');
    final client = _client(peer.fingerprint);
    void abort() => client.close(force: true);
    token.onCancel(abort);
    String? transferId;
    var committed = false;
    Uri uri(String path) =>
        Uri(scheme: 'https', host: peer.host, port: peer.port, path: path);
    Future<Map<String, dynamic>> jsonRequest(
      String path,
      Map<String, Object> data, {
      Duration timeout = _idleTimeout,
    }) async {
      token.check();
      final request = await client.postUrl(uri(path));
      request.followRedirects = false;
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(data));
      final response = await request.close().timeout(timeout);
      final body = await _json(response);
      if (response.statusCode != 200) {
        throw HttpException(
          body['error']?.toString() ?? 'Peer rejected transfer',
        );
      }
      return body;
    }

    try {
      final accepted = await jsonRequest(
        '/v1/offer',
        offer.toJson(),
        timeout: const Duration(seconds: 70),
      );
      transferId = accepted['token'] as String;
      if (!RegExp(r'^[a-f0-9]{48}$').hasMatch(transferId)) {
        throw const FormatException('Invalid transfer token');
      }
      token.check();
      final request = await client.putUrl(uri('/v1/file/$transferId'));
      request.followRedirects = false;
      request.contentLength = size;
      request.headers.contentType = ContentType.binary;
      final digest = _DigestSink();
      final hash = crypto.sha256.startChunkedConversion(digest);
      var bytes = 0;
      await request
          .addStream(
            openRead().map((chunk) {
              token.check();
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
          )
          .timeout(const Duration(hours: 2));
      hash.close();
      final response = await request.close().timeout(_idleTimeout);
      final uploaded = await _json(response);
      final checksum = digest.value.toString();
      if (response.statusCode != 200 ||
          uploaded['sha256'] != checksum ||
          uploaded['size'] != size ||
          bytes != size) {
        throw const HttpException('Upload failed or checksum mismatch');
      }
      final receipt = await jsonRequest('/v1/commit/$transferId', {
        'sha256': checksum,
      });
      if (receipt['committed'] != true || receipt['sha256'] != checksum) {
        throw const HttpException('Missing commit acknowledgement');
      }
      committed = true;
      return TransferReceipt(name: fileName, size: size, sha256: checksum);
    } on Object {
      if (token.isCancelled) throw TransferCancelled();
      rethrow;
    } finally {
      token.remove(abort);
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
        } on Object {
          /* Receiver expires orphaned tickets automatically. */
        } finally {
          cleanup.close(force: true);
        }
      }
    }
  }

  Future<void> close() => _progress.close();
}
