import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'android_receive_target.dart';

class HistoryEntry {
  final TransferReceipt receipt;
  final bool incoming;
  final DateTime time;
  final String peerName;
  HistoryEntry(
    this.receipt,
    this.incoming, {
    this.peerName = '',
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

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

class Dukto2Controller extends ChangeNotifier {
  static const platform = MethodChannel('dukto2/platform');
  TransferServer? server;
  PeerDiscovery? discovery;
  final client = TransferClient();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final history = <HistoryEntry>[];
  List<Peer> peers = [];
  List<String> addresses = [];
  Peer? selected;
  DeviceIdentity? identity;
  Directory? receiveDirectory;
  Directory? _support;
  String name = '';
  String status = '正在准备本机身份…';
  String? error;
  bool starting = true;
  bool sending = false;
  bool receiving = false;
  bool picking = false;
  PlatformFile? chosenFile;
  int? chosenSize;
  SendPhase sendPhase = SendPhase.idle;
  FileOffer? receivingOffer;
  String _incomingSender = '';
  bool _disposed = false;
  bool directReceive = false;
  String receiveLocation = '应用内';
  bool get canChooseReceiveFolder => Platform.isAndroid;
  Timer? _networkDebounce;
  bool _recoveringNetwork = false;
  DateTime _lastNotification = DateTime.fromMillisecondsSinceEpoch(0);
  FileOffer? pendingOffer;
  Completer<bool>? _approval;
  TransferProgress? activeProgress;
  CancellationToken? _outgoing;
  DateTime? transferStarted;
  DateTime _lastProgress = DateTime.fromMillisecondsSinceEpoch(0);
  bool get ready => server != null && !starting;
  bool get busy => picking || sending || receiving || pendingOffer != null;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    try {
      if (Platform.isAndroid) {
        platform.setMethodCallHandler((call) async {
          if (_disposed) return;
          if (call.method == 'networkChanged') {
            _networkDebounce?.cancel();
            _networkDebounce = Timer(const Duration(milliseconds: 700), () {
              if (ready) unawaited(refreshAddresses());
            });
          } else if (call.method == 'transferStopped' &&
              (sending || receiving)) {
            cancelTransfer();
            error = call.arguments as String? ?? '后台传输已停止';
            _notify();
          }
        });
        await _loadReceiveLocation();
      }
      _support = await getApplicationSupportDirectory();
      identity = await DeviceIdentity.loadOrCreate(
        Directory(p.join(_support!.path, 'identity')),
      );
      if (_disposed) return;
      name = await readDeviceName();
      if (name.length > 128) name = name.substring(0, 128);
      receiveDirectory = Directory(
        p.join(
          (await getApplicationDocumentsDirectory()).path,
          'Dukto2 Received',
        ),
      );
      await _loadHistory();
      server = TransferServer(
        identity: identity!,
        name: name,
        receiveDirectory: receiveDirectory!,
        onOffer: _offer,
        createTarget: Platform.isAndroid ? _receiveTarget : null,
      );
      try {
        await server!.start(port: PeerDiscovery.defaultTransferPort);
      } on SocketException catch (error) {
        if (![48, 98, 10048].contains(error.osError?.errorCode)) rethrow;
        // Multiple local instances can still use UDP/manual IP on a random port.
        await server!.start();
      }
      _subscriptions.add(server!.progress.listen(_progress));
      _subscriptions.add(client.progress.listen(_progress));
      _subscriptions.add(
        server!.received.listen((receipt) async {
          await _endForeground();
          receiving = false;
          activeProgress = null;
          status = '已接收 ${receipt.name}，校验通过';
          receivingOffer = null;
          _addHistory(receipt, true, peerName: _incomingSender);
          unawaited(_keepAwake());
        }),
      );
      _subscriptions.add(
        server!.errors.listen((message) {
          receiving = false;
          activeProgress = null;
          receivingOffer = null;
          error = '接收失败：$message';
          unawaited(_endForeground());
          status = '等待文件';
          unawaited(_keepAwake());
          _notify();
        }),
      );
      await refreshAddresses();
      if (_disposed) return;
      if (Platform.isAndroid) {
        await platform.invokeMethod<void>('startDiscovery');
      }
      discovery = PeerDiscovery(server!.localPeer);
      _subscriptions.add(
        discovery!.changes.listen((value) {
          peers = value;
          final chosen = selected;
          if (chosen != null) {
            for (final peer in value) {
              if (peer.fingerprint == chosen.fingerprint &&
                  peer.id == chosen.id)
                selected = peer;
            }
          }
          _notify();
        }),
      );
      try {
        await discovery!.start();
      } on Object catch (exception) {
        error = '自动发现暂不可用，可使用手动连接：$exception';
      }
      starting = false;
      status = '已就绪 · 同一 Wi-Fi 下可互传';
      _notify();
    } on Object catch (exception) {
      starting = false;
      error = '启动失败：$exception';
      status = '检查系统网络权限后重新打开应用';
      _notify();
    }
  }

  Future<void> refreshAddresses() async {
    if (_disposed || _recoveringNetwork) return;
    _recoveringNetwork = true;
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      addresses = interfaces
          .expand((i) => i.addresses)
          .where((a) => !a.isLoopback)
          .map((a) => '${a.address}:${server?.port ?? 0}')
          .toList();
      await discovery?.refresh(force: true);
      if (!busy && server != null) await server!.ensureListening();
      _notify();
    } on Object catch (exception) {
      error = '网络恢复失败，可再次刷新：$exception';
      _notify();
    } finally {
      _recoveringNetwork = false;
    }
  }

  Future<void> _loadReceiveLocation() async {
    final result = await platform.invokeMapMethod<String, dynamic>(
      'receiveLocation',
    );
    directReceive = result?['direct'] == true;
    receiveLocation = result?['label'] as String? ?? '应用内';
  }

  Future<void> chooseReceiveFolder() async {
    if (!Platform.isAndroid || busy || !ready) return;
    picking = true;
    _notify();
    try {
      final result = await platform.invokeMapMethod<String, dynamic>(
        'chooseReceiveFolder',
      );
      if (result != null) {
        directReceive = result['direct'] == true;
        receiveLocation = result['label'] as String? ?? '已授权文件夹';
        status = '接收位置已更新';
        error = null;
      }
    } on Object catch (exception) {
      error = '无法设置接收位置：$exception';
    } finally {
      picking = false;
      _notify();
    }
  }

  Future<ReceiveTarget> _receiveTarget(String id, FileOffer offer) async {
    ReceiveTarget? target;
    try {
      await _beginForeground('正在接收 ${offer.name}');
      target = directReceive
          ? await AndroidReceiveTarget.create(platform, id, offer)
          : await FileReceiveTarget.create(receiveDirectory!, id);
      if (_disposed || !receiving) throw TransferCancelled();
      return target;
    } on Object {
      await target?.discard();
      await _endForeground();
      rethrow;
    }
  }

  Future<void> _beginForeground(String title) async {
    if (!Platform.isAndroid) return;
    try {
      await platform
          .invokeMethod<void>('startTransfer', {'title': title})
          .timeout(const Duration(seconds: 20));
    } on Object {
      await _endForeground();
      rethrow;
    }
  }

  Future<void> _endForeground() async {
    if (!Platform.isAndroid) return;
    try {
      await platform.invokeMethod<void>('stopTransfer');
    } on PlatformException {
      /* Already stopped by Android. */
    }
  }

  @visibleForTesting
  Future<String> readDeviceName() async {
    String? configured;
    try {
      configured = await platform.invokeMethod<String>('getDeviceName');
    } on MissingPluginException {
      // Other platforms can continue using the host name until they have a bridge.
    } on PlatformException {
      // A restricted system setting should not prevent local file transfers.
    }
    final cleaned = (configured ?? '')
        .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '')
        .trim();
    return cleaned.isNotEmpty
        ? cleaned
        : Platform.isAndroid
        ? 'Android'
        : Platform.localHostname;
  }

  Future<bool> _offer(FileOffer offer) async {
    if (_disposed || busy) return false;
    final approval = Completer<bool>();
    _approval = approval;
    pendingOffer = offer;
    error = null;
    status = '有新的接收请求';
    _notify();
    final accepted = await approval.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => false,
    );
    if (identical(_approval, approval)) {
      _approval = null;
      pendingOffer = null;
      receiving = accepted;
      receivingOffer = accepted ? offer : null;
      if (accepted) _incomingSender = offer.sender;
      activeProgress = null;
      transferStarted = DateTime.now();
      status = accepted ? '等待发送方上传…' : '已拒绝接收';
      unawaited(_keepAwake());
      _notify();
    }
    return accepted;
  }

  void answerOffer(bool accept) {
    if (_approval?.isCompleted == false) _approval!.complete(accept);
  }

  void select(Peer peer) {
    if (busy) return;
    selected = peer;
    error = null;
    _notify();
  }

  void _progress(TransferProgress event) {
    activeProgress = event;
    final now = DateTime.now();
    if (Platform.isAndroid &&
        now.difference(_lastNotification).inMilliseconds >= 500) {
      _lastNotification = now;
      unawaited(
        platform
            .invokeMethod<void>('updateTransfer', {
              'title': event.incoming ? '正在接收文件' : '正在发送文件',
              'text': event.name,
              'progress': event.total == 0
                  ? 100
                  : (100 * event.bytes ~/ event.total).clamp(0, 100),
            })
            .catchError((Object _) {}),
      );
    }
    transferStarted ??= now;
    if (!event.incoming) {
      sendPhase = event.bytes == event.total
          ? SendPhase.verifying
          : SendPhase.uploading;
    }
    if (now.difference(_lastProgress).inMilliseconds >= 100 ||
        event.bytes == event.total) {
      _lastProgress = now;
      status = event.incoming ? '正在接收 ${event.name}' : '正在发送 ${event.name}';
      _notify();
    }
  }

  Future<void> pickFile() async {
    if (busy || !ready) return;
    picking = true;
    error = null;
    _notify();
    try {
      final picked = await FilePicker.pickFile();
      if (picked == null || _disposed) return;
      final size = await picked.length();
      if (size == null) {
        throw FileSystemException('无法读取文件大小，请先将文件下载到本机', picked.name);
      }
      if (_disposed) return;
      chosenFile = picked;
      chosenSize = size;
      sendPhase = SendPhase.ready;
      status = '准备发送 ${picked.name}';
    } on Object catch (exception) {
      error = '选择文件失败：$exception';
    } finally {
      picking = false;
      _notify();
    }
  }

  void clearFile() {
    if (busy) return;
    chosenFile = null;
    chosenSize = null;
    sendPhase = SendPhase.idle;
    error = null;
    _notify();
  }

  Future<void> sendFile() async {
    final peer = selected;
    final picked = chosenFile;
    final size = chosenSize;
    if (peer == null || picked == null || size == null || busy || !ready) {
      return;
    }
    sending = true;
    sendPhase = SendPhase.waiting;
    activeProgress = null;
    transferStarted = null;
    error = null;
    status = '等待 ${peer.name} 确认接收…';
    _outgoing = CancellationToken();
    _notify();
    try {
      await _keepAwake();
      await _beginForeground('正在发送 ${picked.name}');
      final receipt = await client.sendStream(
        peer: peer,
        size: size,
        openRead: picked.readAsByteStream,
        sender: name,
        name: picked.name,
        cancellation: _outgoing,
      );
      _addHistory(receipt, false, peerName: peer.name);
      sendPhase = SendPhase.sent;
      status = '已发送 ${receipt.name}，对方校验通过';
    } on TransferCancelled {
      sendPhase = SendPhase.cancelled;
      status = '已取消发送';
    } on Object catch (exception) {
      sendPhase = SendPhase.failed;
      error = '发送失败：$exception';
      status = '可重新选择文件发送';
    } finally {
      sending = false;
      await _endForeground();
      _outgoing = null;
      activeProgress = null;
      unawaited(_keepAwake());
      _notify();
    }
  }

  void cancelTransfer() {
    unawaited(_endForeground());
    if (sending) _outgoing?.cancel();
    if (receiving) {
      server?.cancelIncoming();
      receiving = false;
      activeProgress = null;
      receivingOffer = null;
      status = '已取消接收';
      unawaited(_keepAwake());
      _notify();
    }
  }

  Future<void> _keepAwake() async {
    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod<void>('keepAwake', sending || receiving);
      } on PlatformException {
        /* Transfer still works while the screen is awake. */
      }
    }
  }

  Future<void> export(TransferReceipt receipt) async {
    final file = receipt.file;
    try {
      if (Platform.isAndroid && receipt.contentUri != null) {
        await platform.invokeMethod<void>('openReceived', {
          'uri': receipt.contentUri,
        });
        return;
      }
      if (file == null) return;
      if (Platform.isAndroid) {
        final saved = await platform.invokeMethod<bool>('exportFile', {
          'path': file.path,
          'name': receipt.name,
        });
        if (saved == true) {
          status = '已另存 ${receipt.name}';
          _notify();
        }
      } else if (Platform.isMacOS) {
        final result = await Process.run('open', ['-R', file.path]);
        if (result.exitCode != 0) {
          throw FileSystemException('无法在 Finder 显示文件', file.path);
        }
      }
    } on Object catch (exception) {
      error = '导出失败：$exception';
      _notify();
    }
  }

  Future<void> _loadHistory() async {
    final file = File(p.join(_support!.path, 'history.json'));
    if (!await file.exists()) return;
    try {
      final rows = jsonDecode(await file.readAsString()) as List<dynamic>;
      for (final raw in rows.take(100)) {
        final row = raw as Map<String, dynamic>;
        final incoming = row['incoming'] as bool;
        final path = row['path'] as String?;
        final uri = row['contentUri'] as String?;
        // Only restore paths within the app's receive directory.
        if (incoming &&
            !((path != null && p.isWithin(receiveDirectory!.path, path)) ||
                (Platform.isAndroid &&
                    uri != null &&
                    Uri.tryParse(uri)?.scheme == 'content'))) {
          continue;
        }
        history.add(
          HistoryEntry(
            TransferReceipt(
              name: row['name'] as String,
              size: row['size'] as int,
              sha256: row['sha256'] as String,
              file: path == null ? null : File(path),
              contentUri: uri,
            ),
            incoming,
            peerName: row['peerName'] as String? ?? '',
            time: DateTime.tryParse(row['time'] as String? ?? ''),
          ),
        );
      }
    } on Object {
      /* A corrupt history must not prevent new transfers. */
    }
  }

  Future<void> _historyWrite = Future.value();
  void _addHistory(
    TransferReceipt receipt,
    bool incoming, {
    String peerName = '',
  }) {
    history.insert(0, HistoryEntry(receipt, incoming, peerName: peerName));
    if (history.length > 100) history.removeLast();
    final data = jsonEncode(
      history
          .map(
            (entry) => {
              'name': entry.receipt.name,
              'size': entry.receipt.size,
              'sha256': entry.receipt.sha256,
              'incoming': entry.incoming,
              'path': entry.receipt.file?.path,
              'contentUri': entry.receipt.contentUri,
              'peerName': entry.peerName,
              'time': entry.time.toIso8601String(),
            },
          )
          .toList(),
    );
    _historyWrite = _historyWrite
        .then((_) async {
          final file = File(p.join(_support!.path, 'history.json'));
          final temporary = File('${file.path}.tmp');
          await temporary.writeAsString(data, flush: true);
          await temporary.rename(file.path);
        })
        .catchError((Object _) {
          /* Files remain intact if history cannot be saved. */
        });
    _notify();
  }

  Future<void> shutdown() async {
    _disposed = true;
    _networkDebounce?.cancel();
    _outgoing?.cancel();
    answerOffer(false);
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await discovery?.close();
    await server?.close();
    await client.close();
    await _historyWrite;
    if (Platform.isAndroid) {
      platform.setMethodCallHandler(null);
      await _endForeground();
      await platform.invokeMethod<void>('stopDiscovery');
      await platform.invokeMethod<void>('keepAwake', false);
    }
  }
}
