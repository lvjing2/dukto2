import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'platform_receive_target.dart';
import 'app_settings.dart';
import 'desktop_receive_folders.dart';
import 'transfer_session.dart';
import 'transfer_log.dart';
import 'transfer_failure_message.dart';
export 'transfer_session.dart' show SendPhase;

class HistoryEntry {
  final TransferReceipt receipt;
  final bool incoming;
  final DateTime time;
  final String peerName;
  final String? sourceUri;
  final Duration? elapsed;
  HistoryEntry(
    this.receipt,
    this.incoming, {
    this.peerName = '',
    this.sourceUri,
    this.elapsed,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  factory HistoryEntry.fromJson(Map<String, dynamic> row) => HistoryEntry(
    TransferReceipt(
      name: row['name'] as String,
      size: row['size'] as int,
      sha256: row['sha256'] as String,
      file: row['path'] == null ? null : File(row['path'] as String),
      contentUri: row['contentUri'] as String?,
      text: row['text'] as String?,
      textTruncated: row['textTruncated'] == true,
    ),
    row['incoming'] as bool,
    peerName: row['peerName'] as String? ?? '',
    sourceUri: row['sourceUri'] as String?,
    time: DateTime.tryParse(row['time'] as String? ?? ''),
    elapsed: row['elapsedMs'] is int && (row['elapsedMs'] as int) >= 0
        ? Duration(milliseconds: row['elapsedMs'] as int)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'name': receipt.name,
    'size': receipt.size,
    'sha256': receipt.sha256,
    'incoming': incoming,
    'path': receipt.file?.path,
    'contentUri': receipt.contentUri,
    if (receipt.text != null) 'text': receipt.text,
    if (receipt.textTruncated) 'textTruncated': true,
    'peerName': peerName,
    if (sourceUri != null) 'sourceUri': sourceUri,
    'time': time.toIso8601String(),
    if (elapsed != null) 'elapsedMs': elapsed!.inMilliseconds,
  };
}

class QueuedFile {
  final PlatformFile file;
  final int size;
  bool _sent = false;
  bool get sent => _sent;
  QueuedFile(this.file, this.size);
}

class Dukto2Controller extends ChangeNotifier {
  static const platform = MethodChannel('dukto2/platform');
  TransferServer? server;
  PeerDiscovery? discovery;
  final diagnostics = TransferDiagnostics();
  late final client = TransferClient(diagnostics: diagnostics);
  TransferLogWriter? _logWriter;
  StreamSubscription<TransferLogEntry>? _logSubscription;
  TransferFailure? lastTransferFailure;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final history = <HistoryEntry>[];
  List<Peer> peers = [];
  List<String> addresses = [];
  Peer? selected;
  DeviceIdentity? identity;
  Directory? receiveDirectory;
  Directory? _support;
  SettingsStore? _settingsStore;
  final Future<List<PlatformFile>> Function() _pickFiles;
  final Future<String?> Function() _pickDirectory;

  @protected
  String get operatingSystem => Platform.operatingSystem;
  bool get _isAndroid => operatingSystem == 'android';
  bool get _isIOS => operatingSystem == 'ios';
  bool get _isMacOS => operatingSystem == 'macos';
  bool get _isWindows => operatingSystem == 'windows';
  bool get _isLinux => operatingSystem == 'linux';
  bool get _usesDesktopFolders => _isWindows || _isLinux;
  AppSettings settings = const AppSettings();
  bool savingSettings = false;
  String? settingsError;
  String systemName = '';
  String notificationPermission = 'unknown';
  bool get canOpenNotificationSettings =>
      !_isLinux || _linuxNotificationSettingsAvailable;
  bool _linuxNotificationSettingsAvailable = false;
  bool get canEditSettings => _settingsStore != null;
  Dukto2Controller({
    SettingsStore? settingsStore,
    DesktopReceiveFolders? desktopFolders,
    Future<List<PlatformFile>> Function()? filePicker,
    Future<String?> Function()? directoryPicker,
  }) : _pickFiles = filePicker ?? FilePicker.pickFiles,
       _pickDirectory =
           directoryPicker ??
           (() => FilePicker.getDirectoryPath(dialogTitle: '选择接收文件夹')) {
    _desktopFolders = desktopFolders;
    _settingsStore = settingsStore;
    _subscriptions.add(client.progress.listen(_progress));
    _logSubscription = diagnostics.changes.listen(
      (entry) => _logWriter?.add(entry),
    );
  }
  String name = '';
  DeviceType deviceType = DeviceType.hostPlatform;
  String status = '正在准备本机身份…';
  String? error;
  bool starting = true;
  TransferSession? _session;
  TransferSession? get session => _session;
  bool get sending => _session?.sending ?? false;
  bool get receiving => _session?.receiving ?? false;
  int get receivingBatchRemaining =>
      (_session?.incoming == true && _session!.totalFiles > 1)
      ? _session!.remainingFiles
      : 0;
  bool picking = false;
  final _files = <QueuedFile>[];
  List<QueuedFile> get files => UnmodifiableListView(_files);
  int _fileIndex = 0;
  int get fileIndex => _fileIndex;
  int get completedFiles => _files.where((item) => item.sent).length;
  int get totalFileBytes => _files.fold(0, (sum, item) => sum + item.size);
  PlatformFile? get chosenFile =>
      _files.isEmpty ? null : _files[_fileIndex].file;
  int? get chosenSize => _files.isEmpty ? null : _files[_fileIndex].size;
  SendPhase _sendPhase = SendPhase.idle;
  SendPhase get sendPhase => sending ? _session!.sendPhase : _sendPhase;
  set sendPhase(SendPhase phase) => _sendPhase = phase;
  FileOffer? get receivingOffer => _session?.offer;
  bool _disposed = false;
  bool directReceive = false;
  String receiveLocation = '应用内';
  bool customReceiveFolder = false;
  Directory? _desktopReceiveDirectory;
  DesktopReceiveFolders? _desktopFolders;
  bool _receiveFolderAvailable = true;
  final _receiveRoots = <String>[];
  bool get canChooseReceiveFolder =>
      _isAndroid || _isMacOS || _isIOS || _usesDesktopFolders;
  bool get isAppleMobile => _isIOS;
  String get backgroundTransferHint => switch (operatingSystem) {
    'ios' => '传输时请保持应用在前台，切换应用或锁屏可能中断。',
    'android' => '确认收发后可在后台继续传输，请勿强行停止应用。',
    _ => '传输时请保持应用运行，避免设备休眠。',
  };
  TransferKind sendKind = TransferKind.file;
  PlatformFile? chosenTextFile;
  int? chosenTextSize;
  String chosenTextPreview = '';
  Timer? _networkDebounce;
  bool _recoveringNetwork = false;
  DateTime _lastNotification = DateTime.fromMillisecondsSinceEpoch(0);
  FileOffer? get pendingOffer => _session?.pendingOffer;
  TransferProgress? get activeProgress => _session?.progress;
  CancellationToken? get _outgoing => _session?.cancellation;
  DateTime? get transferStarted => _session?.started;
  Future<void>? _incomingCompletion;
  Completer<void>? _outgoingSettled;
  DateTime _lastProgress = DateTime.fromMillisecondsSinceEpoch(0);
  bool get ready => server != null && !starting;
  bool get busy => picking || (_session?.active ?? false);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    try {
      platform.setMethodCallHandler((call) async {
        if (_disposed) return;
        if (call.method == 'networkChanged') {
          _networkDebounce?.cancel();
          _networkDebounce = Timer(const Duration(milliseconds: 700), () {
            if (ready) unawaited(refreshAddresses());
          });
        } else if (call.method == 'discoveredEndpoint') {
          final data = call.arguments as Map?;
          final host = data?['host'];
          final port = data?['port'];
          if (host is String && port is int) {
            await discovery?.confirmEndpoint(host, port);
          }
        } else if (call.method == 'discoveryUnavailable' &&
            peers.isEmpty &&
            !busy) {
          error = call.arguments as String?;
          _notify();
        } else if (call.method == 'transferStopped' && (sending || receiving)) {
          cancelTransfer();
          error = call.arguments as String? ?? '后台传输已停止';
          _notify();
        }
      });
      if (_isAndroid || _isIOS) {
        await loadReceiveLocation();
      }
      _support = await getApplicationSupportDirectory();
      _logWriter = TransferLogWriter(_support!);
      if (_usesDesktopFolders && _desktopFolders == null) {
        final downloads = await getDownloadsDirectory();
        if (downloads == null) {
          throw const FileSystemException('无法找到系统下载目录');
        }
        _desktopFolders = DesktopReceiveFolders(
          _support!,
          Directory(p.join(downloads.path, 'Dukto2')),
        );
      }
      _settingsStore ??= SettingsStore(_support!);
      await loadSettings();
      deviceType = await readDeviceType();
      identity = await DeviceIdentity.loadOrCreate(
        Directory(p.join(_support!.path, 'identity')),
      );
      if (_disposed) return;
      receiveDirectory = Directory(
        p.join(
          _isIOS
              ? (await getTemporaryDirectory()).path
              : (await getApplicationDocumentsDirectory()).path,
          _isIOS ? 'Dukto2 Server' : 'Dukto2 Received',
        ),
      );
      if (_isMacOS || _usesDesktopFolders) {
        await loadReceiveLocation();
        if (_receiveFolderAvailable && _desktopReceiveDirectory != null) {
          await FileReceiveTarget.recover(_desktopReceiveDirectory!);
        }
      }
      await _loadHistory();
      server = TransferServer(
        identity: identity!,
        name: name,
        deviceType: deviceType,
        receiveDirectory: receiveDirectory!,
        onOffer: receiveOffer,
        onApprovedBatchFile: receiveApprovedBatchFile,
        createTarget: _receiveTarget,
        diagnostics: diagnostics,
      );
      try {
        await server!.start(port: PeerDiscovery.defaultTransferPort);
      } on SocketException catch (error) {
        if (![48, 98, 10048].contains(error.osError?.errorCode)) rethrow;
        // Multiple local instances can still use UDP/manual IP on a random port.
        await server!.start();
      }
      _subscriptions.add(server!.progress.listen(_progress));
      _subscriptions.add(server!.received.listen(completeReceive));
      _subscriptions.add(server!.errors.listen(_receiveFailed));
      await refreshAddresses();
      if (_disposed) return;
      discovery = PeerDiscovery(server!.localPeer, useMulticast: !_isIOS);
      _subscriptions.add(
        discovery!.changes.listen((value) {
          peers = value;
          final chosen = selected;
          if (chosen != null) {
            for (final peer in value) {
              if (peer.fingerprint == chosen.fingerprint &&
                  peer.id == chosen.id) {
                selected = peer;
              }
            }
          }
          _notify();
        }),
      );
      try {
        await discovery!.start();
        if (_isAndroid || _isIOS || _isMacOS) {
          await platform.invokeMethod<void>('startDiscovery', {
            'id': identity!.id,
            'port': server!.port,
          });
        }
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

  @visibleForTesting
  Future<void> loadSettings() async {
    settings = await _settingsStore!.load();
    await refreshSystemSettings();
    _notify();
  }

  Future<void> refreshSystemSettings() async {
    final raw = await readDeviceName();
    if (_disposed) return;
    systemName = String.fromCharCodes(raw.runes.take(64));
    _applyDeviceName();
    try {
      notificationPermission =
          await platform.invokeMethod<String>('notificationStatus') ??
          'unknown';
    } on MissingPluginException {
      notificationPermission = 'unavailable';
    } on PlatformException {
      notificationPermission = 'unavailable';
    }
    if (_isLinux) {
      try {
        _linuxNotificationSettingsAvailable =
            await platform.invokeMethod<bool>('canOpenNotificationSettings') ==
            true;
      } on Object {
        _linuxNotificationSettingsAvailable = false;
      }
    }
    _notify();
  }

  void _applyDeviceName() {
    final next = systemName;
    if (next.isEmpty || next == name) return;
    name = next;
    server?.rename(name);
    if (server != null) discovery?.updateLocal(server!.localPeer);
  }

  Future<bool> _saveSettings(AppSettings next) async {
    if (!canEditSettings || savingSettings) return false;
    savingSettings = true;
    settingsError = null;
    _notify();
    try {
      await _settingsStore!.save(next);
      if (_disposed) return false;
      settings = next;
      _applyDeviceName();
      return true;
    } on Object {
      settingsError = '设置未能保存，请重试';
      return false;
    } finally {
      savingSettings = false;
      _notify();
    }
  }

  Future<bool> setAppearance(AppAppearance value) =>
      _saveSettings(settings.copyWith(appearance: value));

  Future<bool> setCompletionNotifications(bool value) async {
    final saved = await _saveSettings(
      settings.copyWith(completionNotifications: value),
    );
    if (saved && value) await requestNotifications();
    return saved;
  }

  Future<void> requestNotifications() async {
    try {
      notificationPermission =
          await platform.invokeMethod<String>('requestNotifications') ??
          'unknown';
    } on Object {
      settingsError = '无法请求通知权限，请在系统设置中检查';
    }
    _notify();
  }

  Future<void> openNotificationSettings() async {
    if (!canOpenNotificationSettings) return;
    try {
      await platform.invokeMethod<void>('openNotificationSettings');
    } on Object {
      settingsError = '无法打开系统设置，请手动检查 Dukto2 通知权限';
      _notify();
    }
  }

  @visibleForTesting
  Future<void> notifyCompletion(
    TransferReceipt receipt, {
    required bool incoming,
  }) async {
    if (!settings.completionNotifications || _disposed) return;
    final kind = receipt.text == null ? '文件' : '文本';
    try {
      await platform.invokeMethod<void>('notifyComplete', {
        'title': incoming ? '接收完成' : '发送完成',
        'body': incoming ? '$kind已接收并通过校验' : '$kind已发送并通过校验',
      });
    } on Object {
      // A denied notification must never change a successful transfer result.
    }
  }

  @visibleForTesting
  Future<void> loadReceiveLocation() async {
    final result = _usesDesktopFolders
        ? await _desktopFolders!.location()
        : await platform.invokeMapMethod<String, dynamic>('receiveLocation');
    directReceive = result?['direct'] == true;
    receiveLocation = result?['label'] as String? ?? '应用内';
    customReceiveFolder =
        result?['custom'] == true || result?['kind'] == 'folder';
    _applyReceiveLocation(result);
  }

  void _applyReceiveLocation(Map<String, dynamic>? result) {
    if (_isIOS && result != null) {
      _receiveFolderAvailable = result['available'] != false;
      if (!_receiveFolderAvailable) {
        error = result['error'] as String? ?? '接收文件夹不可用，请重新选择';
        settingsError = error;
      }
      return;
    }
    if (!(_isMacOS || _usesDesktopFolders) || result == null) return;
    final path = result['path'] as String?;
    _desktopReceiveDirectory = path == null ? null : Directory(path);
    _receiveFolderAvailable = result['available'] == true && path != null;
    _receiveRoots
      ..clear()
      ..addAll((result['roots'] as List? ?? []).whereType<String>());
    if (path != null && _receiveFolderAvailable) _receiveRoots.add(path);
    if (!_receiveFolderAvailable) {
      error = result['error'] as String? ?? '接收文件夹不可用，请重新选择';
      settingsError = error;
    }
  }

  Future<void> chooseReceiveFolder() async {
    if (!canChooseReceiveFolder || busy || !ready) return;
    picking = true;
    settingsError = null;
    _notify();
    try {
      Map<String, dynamic>? result;
      if (_usesDesktopFolders) {
        final path = await _pickDirectory();
        if (path != null) result = await _desktopFolders!.choose(path);
      } else {
        result = await platform.invokeMapMethod<String, dynamic>(
          'chooseReceiveFolder',
        );
      }
      if (result != null) {
        directReceive = result['direct'] == true;
        receiveLocation = result['label'] as String? ?? '已授权文件夹';
        customReceiveFolder =
            result['custom'] == true || result['kind'] == 'folder';
        _applyReceiveLocation(result);
        status = '接收位置已更新';
        if (_receiveFolderAvailable) error = null;
      }
    } on Object catch (exception) {
      error = '无法设置接收位置：$exception';
      settingsError = error;
    } finally {
      picking = false;
      _notify();
    }
  }

  Future<void> resetReceiveFolder() async {
    if (!canChooseReceiveFolder || busy || !ready) return;
    picking = true;
    settingsError = null;
    _notify();
    try {
      if (_usesDesktopFolders) {
        await _desktopFolders!.reset();
      } else {
        await platform.invokeMethod<void>('resetReceiveFolder');
      }
      error = null;
      await loadReceiveLocation();
      status = '已恢复默认接收位置';
    } on Object catch (exception) {
      error = '无法恢复接收位置：$exception';
      settingsError = error;
    } finally {
      picking = false;
      _notify();
    }
  }

  Future<ReceiveTarget> _receiveTarget(String id, FileOffer offer) async {
    final current = _session;
    ReceiveTarget? target;
    try {
      await _beginForeground('正在接收 ${offer.name}');
      if ((_isMacOS || _isIOS || _usesDesktopFolders) &&
          !_receiveFolderAvailable) {
        throw const FileSystemException('接收文件夹不可用，请重新选择');
      }
      target = (_isAndroid || _isIOS) && directReceive
          ? await PlatformReceiveTarget.create(
              platform,
              id,
              offer,
              uriScheme: _isIOS ? 'dukto2-received' : 'content',
            )
          : await FileReceiveTarget.create(
              _desktopReceiveDirectory ?? receiveDirectory!,
              id,
            );
      if (_disposed ||
          current == null ||
          !identical(current, _session) ||
          !current.receiving ||
          current.cancellation.isCancelled) {
        throw TransferCancelled();
      }
      return target;
    } on Object catch (exception, stack) {
      try {
        await target?.discard();
      } on Object catch (cleanup, cleanupStack) {
        _recordCleanupFailure(cleanup, cleanupStack);
      }
      if (exception is TransferCancelled) rethrow;
      throw TransferFailure.capture(
        exception,
        stack,
        stage: TransferStage.storage,
        kind: TransferFailureKind.storage,
        operationId: _session?.id ?? randomId(8),
        incoming: true,
      );
    }
  }

  Future<void> completeReceive(TransferReceipt receipt) {
    final current = _session;
    if (current == null || !current.receiving) return Future.value();
    final elapsed = current.completeFile();
    return _incomingCompletion = () async {
      final more = current.remainingFiles > 0;
      if (!more) await _finishSession(current, SessionPhase.completed);
      status = receipt.text != null ? '已接收文本，校验通过' : '已接收 ${receipt.name}，校验通过';
      _addHistory(receipt, true, peerName: current.peerName, elapsed: elapsed);
      if (!more) unawaited(notifyCompletion(receipt, incoming: true));
      _notify();
    }();
  }

  void _receiveFailed(TransferFailure failure) {
    final current = _session;
    if (current == null || !current.incoming || !current.active) return;
    current.answer(false);
    lastTransferFailure = failure;
    final cancelled =
        current.cancellation.isCancelled ||
        failure.kind == TransferFailureKind.cancelled;
    error = cancelled ? null : '接收失败：${transferFailureMessage(failure)}';
    status = cancelled ? '已取消接收' : '等待文件';
    _incomingCompletion = _finishSession(
      current,
      cancelled ? SessionPhase.cancelled : SessionPhase.failed,
    ).whenComplete(_notify);
    _notify();
  }

  Future<void> _beginForeground(String title) async {
    if (!_isAndroid && !_isIOS) return;
    final current = _session;
    if (current == null) throw TransferCancelled();
    try {
      await current.acquire(
        () => platform
            .invokeMethod<void>('startTransfer', {'title': title})
            .timeout(const Duration(seconds: 20)),
      );
    } on Object catch (error, stack) {
      throw TransferFailure.capture(
        error,
        stack,
        stage: TransferStage.platform,
        kind: error is PlatformException ? TransferFailureKind.platform : null,
        operationId: current.id,
        incoming: current.incoming,
        platformCode: error is PlatformException ? error.code : null,
      );
    }
  }

  @protected
  Future<void> endTransferSession() async {
    if (!_isAndroid && !_isIOS) return;
    await platform
        .invokeMethod<void>('stopTransfer')
        .timeout(const Duration(seconds: 5));
  }

  void _recordCleanupFailure(Object error, StackTrace stack) {
    final failure = TransferFailure.capture(
      error,
      stack,
      stage: TransferStage.cleanup,
      operationId: _session?.id ?? randomId(8),
      incoming: _session?.incoming ?? false,
      platformCode: error is PlatformException ? error.code : null,
    );
    diagnostics
        .begin(incoming: _session?.incoming ?? false)
        .cleanupFailed(failure, stack);
  }

  Future<void> _finishSession(TransferSession current, SessionPhase terminal) =>
      current.finish(terminal, () async {
        try {
          await endTransferSession();
        } on Object catch (error, stack) {
          _recordCleanupFailure(error, stack);
        }
        if (_isAndroid || _isIOS || _usesDesktopFolders) {
          try {
            await platform
                .invokeMethod<void>('keepAwake', false)
                .timeout(const Duration(seconds: 5));
          } on Object catch (error, stack) {
            _recordCleanupFailure(error, stack);
          }
        }
      });

  @visibleForTesting
  Future<DeviceType> readDeviceType() async {
    try {
      final type = DeviceType.parse(
        await platform.invokeMethod<String>('getDeviceType'),
      );
      if (type != DeviceType.unknown) return type;
    } on MissingPluginException {
      // Older native bridges can still start and transfer normally.
    } on PlatformException {
      // Device appearance metadata must never block startup.
    }
    return DeviceType.hostPlatform;
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
        : _isAndroid || _isIOS
        ? '本机'
        : Platform.localHostname;
  }

  Future<bool> receiveOffer(FileOffer offer) async {
    if (_incomingCompletion != null) await _incomingCompletion;
    if (_disposed || busy) return false;
    final current = TransferSession.incoming(offer);
    _session = current;
    lastTransferFailure = null;
    error = null;
    status = '有新的接收请求';
    _notify();
    final accepted = await current.awaitApproval();
    if (identical(_session, current)) {
      status = accepted
          ? '等待发送方上传…'
          : current.cancellation.isCancelled
          ? '已取消接收'
          : '已拒绝接收';
      if (accepted) unawaited(_keepAwake());
      _notify();
    }
    return accepted && !_disposed;
  }

  void answerOffer(bool accept) => _session?.answer(accept);

  Future<bool> receiveApprovedBatchFile(FileOffer offer) async {
    if (_incomingCompletion != null) await _incomingCompletion;
    final current = _session;
    if (_disposed ||
        current == null ||
        !current.receiving ||
        current.phase == SessionPhase.cancelling ||
        current.remainingFiles == 0 ||
        current.totalFiles <= 1 ||
        picking ||
        pendingOffer != null) {
      return false;
    }
    current.beginFile(offer: offer, alreadyApproved: true);
    status = '正在接收本批文件：${offer.name}';
    _notify();
    return true;
  }

  void select(Peer peer) {
    if (busy) return;
    if (selected?.id != peer.id || selected?.fingerprint != peer.fingerprint) {
      for (final item in _files) {
        item._sent = false;
      }
      _fileIndex = 0;
      sendPhase = chosenFile == null ? SendPhase.idle : SendPhase.ready;
      status = '已选择 ${peer.name}';
    }
    selected = peer;
    error = null;
    _notify();
  }

  void _progress(TransferProgress event) {
    final current = _session;
    if (current == null ||
        !current.active ||
        current.incoming != event.incoming ||
        current.phase == SessionPhase.cancelling) {
      return;
    }
    current.updateProgress(event);
    final now = DateTime.now();
    if (_isAndroid && now.difference(_lastNotification).inMilliseconds >= 500) {
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
            .catchError((Object error, StackTrace stack) {
              _recordCleanupFailure(error, stack);
            }),
      );
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
      final picked = await _pickFiles();
      if (picked.isEmpty || _disposed) return;
      final next = <QueuedFile>[];
      for (final file in picked) {
        final size = await file.length();
        if (size == null || size < 0) {
          throw FileSystemException('无法读取文件大小，请先将文件下载到本机', file.name);
        }
        next.add(QueuedFile(file, size));
      }
      if (_disposed) return;
      _files
        ..clear()
        ..addAll(next);
      _fileIndex = 0;
      sendPhase = SendPhase.ready;
      status = '准备发送 ${next.length} 个文件';
    } on Object catch (exception) {
      error = '选择文件失败：$exception';
    } finally {
      picking = false;
      _notify();
    }
  }

  void clearFile() {
    if (busy) return;
    _files.clear();
    _fileIndex = 0;
    sendPhase = SendPhase.idle;
    error = null;
    _notify();
  }

  void removeFile(int index) {
    if (busy || index < 0 || index >= _files.length) return;
    _files.removeAt(index);
    _fileIndex = _files.indexWhere((item) => !item.sent);
    if (_fileIndex < 0) _fileIndex = 0;
    sendPhase = _files.isEmpty
        ? SendPhase.idle
        : completedFiles == _files.length
        ? SendPhase.sent
        : SendPhase.ready;
    error = null;
    _notify();
  }

  void setSendKind(TransferKind kind) {
    if (busy) return;
    sendKind = kind;
    sendPhase = chosenFile == null
        ? SendPhase.idle
        : completedFiles == _files.length
        ? SendPhase.sent
        : SendPhase.ready;
    error = null;
    _notify();
  }

  Future<void> pickTextFile() async {
    if (busy || !ready) return;
    picking = true;
    _notify();
    try {
      final picked = await FilePicker.pickFile();
      if (picked == null || _disposed) return;
      final size = await picked.length();
      if (size == null || size < 1 || size > maxTextBytes) {
        throw const FormatException('请选择 16 MiB 以内的 UTF-8 文本文件');
      }
      final preview = <int>[];
      await for (final chunk in picked.readAsByteStream()) {
        final remaining = 64 * 1024 - preview.length;
        preview.addAll(chunk.take(remaining));
        if (preview.length >= 64 * 1024) break;
      }
      chosenTextFile = picked;
      chosenTextSize = size;
      chosenTextPreview = utf8.decode(preview, allowMalformed: true);
      error = null;
      sendPhase = SendPhase.ready;
    } on Object catch (exception) {
      error = '载入文本失败：$exception';
    } finally {
      picking = false;
      _notify();
    }
  }

  void clearTextFile() {
    if (busy) return;
    chosenTextFile = null;
    chosenTextSize = null;
    chosenTextPreview = '';
    sendPhase = SendPhase.idle;
    _notify();
  }

  Future<void> sendText(String text) async {
    final peer = selected;
    if (peer == null || busy || !ready) return;
    if (chosenTextFile != null && chosenTextSize != null) {
      final picked = chosenTextFile!;
      final size = chosenTextSize!;
      await _sendContent(peer, picked.name, () async {
        final receipt = await client.sendStream(
          peer: peer,
          name: picked.name,
          size: size,
          openRead: picked.readAsByteStream,
          sender: name,
          kind: TransferKind.text,
          cancellation: _outgoing,
        );
        return TransferReceipt(
          name: picked.name,
          size: size,
          sha256: receipt.sha256,
          text: textPreview(chosenTextPreview),
          textTruncated:
              size > utf8.encode(textPreview(chosenTextPreview)).length,
        );
      });
      return;
    }
    if (text.trim().isEmpty || utf8.encode(text).length > maxInlineTextBytes) {
      error = '编辑区最多 1 MiB，大文本请从文件载入（上限 16 MiB）';
      _notify();
      return;
    }
    await _sendContent(
      peer,
      '文本',
      () => client.sendText(
        peer: peer,
        text: text,
        sender: name,
        cancellation: _outgoing,
      ),
    );
  }

  Future<void> sendFile() async {
    final peer = selected;
    final pending = _files.where((item) => !item.sent).toList();
    if (peer == null || pending.isEmpty || busy || !ready) {
      return;
    }
    await _sendContent(
      peer,
      pending.length == 1 ? pending.single.file.name : '${pending.length} 个文件',
      () async {
        TransferReceipt? last;
        String? batchToken;
        var complete = false;
        try {
          if (pending.length > 1) {
            batchToken = await client.offerBatch(
              peer: peer,
              sender: name,
              files: [
                for (final item in pending)
                  FileOffer(
                    sender: name,
                    name: item.file.name,
                    size: item.size,
                  ),
              ],
              cancellation: _outgoing,
            );
          }
          for (var index = 0; index < pending.length; index++) {
            final item = pending[index];
            _outgoing!.check();
            if (_disposed) throw TransferCancelled();
            _fileIndex = _files.indexOf(item);
            _session!.beginFile(alreadyApproved: batchToken != null);
            status = batchToken == null
                ? '等待 ${peer.name} 确认接收 ${item.file.name}…'
                : '正在发送本批文件 ${index + 1} / ${pending.length}';
            _notify();
            last = await client.sendStream(
              peer: peer,
              size: item.size,
              openRead: item.file.readAsByteStream,
              sender: name,
              name: item.file.name,
              cancellation: _outgoing,
              batchToken: batchToken,
              batchIndex: batchToken == null ? null : index,
            );
            final elapsed = _session!.completeFile();
            item._sent = true;
            _addHistory(
              last,
              false,
              peerName: peer.name,
              elapsed: elapsed,
              // iOS exposes an imported cache, not the original source directory.
              sourceUri: _isIOS ? null : item.file.uri.toString(),
            );
          }
          complete = true;
          return last!;
        } finally {
          if (!complete && batchToken != null) {
            await client.cancelBatch(peer, batchToken);
          }
        }
      },
      recordHistory: false,
    );
  }

  @protected
  TransferSession beginOutgoingSession({int fileCount = 1}) {
    if (_session?.active == true) {
      throw StateError('A transfer session is already active');
    }
    return _session = TransferSession.outgoing(
      totalFiles: fileCount,
      peerName: selected?.name ?? '',
    );
  }

  Future<void> _sendContent(
    Peer peer,
    String label,
    Future<TransferReceipt> Function() send, {
    String? sourceUri,
    bool recordHistory = true,
  }) async {
    final current = beginOutgoingSession(
      fileCount: recordHistory ? 1 : _files.where((f) => !f.sent).length,
    );
    final settled = Completer<void>();
    _outgoingSettled = settled;
    lastTransferFailure = null;
    error = null;
    status = '等待 ${peer.name} 确认接收…';
    _notify();
    TransferReceipt? completed;
    var terminal = SessionPhase.failed;
    try {
      await _keepAwake();
      await _beginForeground('正在发送 $label');
      current.cancellation.check();
      final receipt = await send();
      if (recordHistory) {
        final elapsed = current.completeFile();
        _addHistory(
          receipt,
          false,
          peerName: peer.name,
          sourceUri: sourceUri,
          elapsed: elapsed,
        );
      }
      _sendPhase = SendPhase.sent;
      status = '已发送 $label，对方校验通过';
      completed = receipt;
      terminal = SessionPhase.completed;
    } on TransferCancelled {
      diagnostics
          .begin(incoming: false)
          .fail(TransferCancelled(), StackTrace.current);
      _sendPhase = SendPhase.cancelled;
      status = '已取消发送';
      terminal = SessionPhase.cancelled;
    } on Object catch (exception, stack) {
      final failure = TransferFailure.capture(
        exception,
        stack,
        stage: TransferStage.connection,
        operationId: current.id,
        incoming: false,
        platformCode: exception is PlatformException ? exception.code : null,
      );
      lastTransferFailure = failure;
      diagnostics.recordFailure(failure);
      if (current.cancellation.isCancelled) {
        _sendPhase = SendPhase.cancelled;
        status = '已取消发送';
        terminal = SessionPhase.cancelled;
      } else {
        _sendPhase = SendPhase.failed;
        error = '发送失败：${transferFailureMessage(failure)}';
        status = '可重新发送';
      }
    } finally {
      await _finishSession(current, terminal);
      settled.complete();
      if (identical(_outgoingSettled, settled)) _outgoingSettled = null;
      _notify();
    }
    if (completed != null) {
      unawaited(notifyCompletion(completed, incoming: false));
    }
  }

  void cancelTransfer() {
    final current = _session;
    if (current == null || !current.active) return;
    current.cancel();
    if (current.incoming) {
      server?.cancelIncoming();
      status = '已取消接收';
      _incomingCompletion = _finishSession(
        current,
        SessionPhase.cancelled,
      ).whenComplete(_notify);
    }
    _notify();
  }

  Future<void> _keepAwake() async {
    if (_isAndroid || _isIOS || _usesDesktopFolders) {
      final current = _session;
      if (current == null) return;
      try {
        await current.acquire(
          () => platform
              .invokeMethod<void>('keepAwake', true)
              .timeout(const Duration(seconds: 5)),
        );
      } on TransferCancelled {
        // Cancellation before acquisition needs no matching native start.
      } on Object catch (error, stack) {
        _recordCleanupFailure(error, stack);
      }
    }
  }

  bool canOpenHistoryDirectory(HistoryEntry entry) {
    if (entry.receipt.text != null) return false;
    if (entry.incoming) {
      return entry.receipt.contentUri != null ||
          (entry.receipt.file != null && !_isAndroid);
    }
    final uri = Uri.tryParse(entry.sourceUri ?? '');
    return (!_isAndroid && uri?.scheme == 'file') ||
        (_isAndroid && uri?.scheme == 'content');
  }

  Future<void> openHistoryDirectory(HistoryEntry entry) async {
    if (!canOpenHistoryDirectory(entry)) return;
    try {
      final path = entry.incoming
          ? entry.receipt.file?.path
          : (Uri.tryParse(entry.sourceUri ?? '')?.scheme == 'file'
                ? Uri.parse(entry.sourceUri!).toFilePath()
                : null);
      if (_isMacOS) {
        if (path == null || !await File(path).exists()) {
          throw const FileSystemException('文件已移动或删除');
        }
        final result = await Process.run('open', ['-R', path]);
        if (result.exitCode != 0) throw const FileSystemException('无法打开文件目录');
      } else if (_usesDesktopFolders) {
        await platform.invokeMethod<void>('openHistoryDirectory', {
          'path': path,
        });
      } else if (_isIOS || _isAndroid) {
        await platform.invokeMethod<void>('openHistoryDirectory', {
          if (entry.incoming && entry.receipt.contentUri != null)
            'receivedUri': entry.receipt.contentUri,
          if (!entry.incoming) 'sourceUri': entry.sourceUri,
          if (entry.incoming && path != null) 'path': path,
        });
      }
    } on Object catch (exception) {
      error = '打开目录失败：$exception';
      _notify();
    }
  }

  Future<void> export(TransferReceipt receipt) async {
    final file = receipt.file;
    try {
      if ((_isAndroid || _isIOS) && receipt.contentUri != null) {
        await platform.invokeMethod<void>('openReceived', {
          'uri': receipt.contentUri,
        });
        return;
      }
      if (file == null) return;
      if (_isAndroid) {
        final saved = await platform.invokeMethod<bool>('exportFile', {
          'path': file.path,
          'name': receipt.name,
        });
        if (saved == true) {
          status = '已另存 ${receipt.name}';
          _notify();
        }
      } else if (_isMacOS) {
        final result = await Process.run('open', ['-R', file.path]);
        if (result.exitCode != 0) {
          throw FileSystemException('无法在 Finder 显示文件', file.path);
        }
      } else if (_usesDesktopFolders) {
        await platform.invokeMethod<void>('openHistoryDirectory', {
          'path': file.path,
        });
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
        final text = row['text'] as String?;
        if (text != null &&
            (text.trim().isEmpty || utf8.encode(text).length > maxTextBytes)) {
          continue;
        }
        // Restore files only within app-owned or native-authorized receive roots.
        if (incoming &&
            (text == null || path != null || uri != null) &&
            !((path != null && p.isWithin(receiveDirectory!.path, path)) ||
                (path != null &&
                    _receiveRoots.any((root) => p.isWithin(root, path))) ||
                ((_isAndroid || _isIOS) &&
                    uri != null &&
                    Uri.tryParse(uri)?.scheme ==
                        (_isIOS ? 'dukto2-received' : 'content')))) {
          continue;
        }
        history.add(HistoryEntry.fromJson(row));
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
    String? sourceUri,
    Duration? elapsed,
  }) {
    history.insert(
      0,
      HistoryEntry(
        receipt,
        incoming,
        peerName: peerName,
        sourceUri: sourceUri,
        elapsed: elapsed,
      ),
    );
    if (history.length > 100) history.removeLast();
    final data = jsonEncode(history.map((entry) => entry.toJson()).toList());
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
    if (_disposed) return;
    _disposed = true;
    _networkDebounce?.cancel();
    _session?.cancel();
    answerOffer(false);
    await _outgoingSettled?.future;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await discovery?.close();
    await server?.close();
    await _incomingCompletion;
    final current = _session;
    if (current != null) await _finishSession(current, SessionPhase.cancelled);
    await client.close();
    await _historyWrite;
    platform.setMethodCallHandler(null);
    if (_isAndroid || _isIOS || _isMacOS) {
      try {
        await platform.invokeMethod<void>('stopDiscovery');
      } on Object catch (error, stack) {
        _recordCleanupFailure(error, stack);
      }
    }
    await diagnostics.close();
    await _logSubscription?.cancel();
    await _logWriter?.close();
  }
}
