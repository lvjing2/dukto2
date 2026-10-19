import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dukto2_core/dukto2_core.dart';

import 'controller.dart';
import 'manual_address.dart';
import 'settings_page.dart';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

String formatHistoryTime(DateTime value, {DateTime? now}) {
  final time = value.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final clock = '${two(time.hour)}:${two(time.minute)}';
  final date = DateTime(time.year, time.month, time.day);
  final current = DateTime(today.year, today.month, today.day);
  if (date == current) return '今天 $clock';
  if (date == DateTime(current.year, current.month, current.day - 1)) {
    return '昨天 $clock';
  }
  return '${time.year == today.year ? '' : '${time.year}/'}${two(time.month)}/${two(time.day)} $clock';
}

String formatElapsed(Duration elapsed) {
  if (elapsed.inMilliseconds < 1000) return '小于 1 秒';
  if (elapsed.inSeconds < 60) {
    return '${(elapsed.inMilliseconds / 1000).toStringAsFixed(1)} 秒';
  }
  final seconds = elapsed.inSeconds % 60;
  final minutes = elapsed.inMinutes % 60;
  return elapsed.inHours == 0
      ? '$minutes 分 $seconds 秒'
      : '${elapsed.inHours} 小时 $minutes 分 $seconds 秒';
}

IconData deviceIcon(DeviceType type) => switch (type) {
  DeviceType.phone => Icons.smartphone_outlined,
  DeviceType.tablet => Icons.tablet_mac_outlined,
  DeviceType.computer => Icons.computer_outlined,
  DeviceType.unknown => Icons.devices_outlined,
};

String deviceTypeLabel(DeviceType type) => switch (type) {
  DeviceType.phone => '手机',
  DeviceType.tablet => '平板',
  DeviceType.computer => '电脑',
  DeviceType.unknown => '设备',
};

class TransferDashboard extends StatefulWidget {
  final Dukto2Controller controller;
  const TransferDashboard({super.key, required this.controller});
  @override
  State<TransferDashboard> createState() => _TransferDashboardState();
}

class _TransferDashboardState extends State<TransferDashboard> {
  Dukto2Controller get c => widget.controller;
  ColorScheme get colors => Theme.of(context).colorScheme;
  Route<bool>? _offerRoute;
  FileOffer? _shownOffer;
  bool _syncScheduled = false;
  final _text = TextEditingController();
  final _textFocus = FocusNode();
  final _textEditorKey = GlobalKey(debugLabel: 'text-editor');
  String? _textIssue;
  String? _historyDevice;
  @override
  void initState() {
    super.initState();
    c.addListener(_scheduleOffer);
    _scheduleOffer();
  }

  @override
  void didUpdateWidget(TransferDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != c) {
      oldWidget.controller.removeListener(_scheduleOffer);
      c.addListener(_scheduleOffer);
      _scheduleOffer();
    }
  }

  @override
  void dispose() {
    c.removeListener(_scheduleOffer);
    _textFocus.dispose();
    _text.dispose();
    super.dispose();
  }

  void _scheduleOffer() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) {
        if (_historyDevice != null &&
            !c.history.any((entry) => entry.peerName == _historyDevice)) {
          setState(() => _historyDevice = null);
        }
        unawaited(_syncOffer());
      }
    });
  }

  // Expiry must close only this request's route, never an unrelated dialog.
  Future<void> _syncOffer() async {
    final offer = c.pendingOffer;
    if (offer == null) {
      final route = _offerRoute;
      _offerRoute = null;
      _shownOffer = null;
      if (route != null && route.isActive) {
        Navigator.of(context).removeRoute(route, false);
      }
      return;
    }
    if (_offerRoute != null || identical(offer, _shownOffer)) return;
    _shownOffer = offer;
    final navigator = Navigator.of(context);
    final phone = MediaQuery.sizeOf(context).width < 720;
    final Route<bool> route = phone
        ? ModalBottomSheetRoute<bool>(
            builder: (context) => _offerContent(context, offer),
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: false,
            enableDrag: false,
          )
        : DialogRoute<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _offerContent(context, offer),
              ),
            ),
          );
    _offerRoute = route;
    final accepted = await navigator.push<bool>(route);
    if (!mounted || !identical(_offerRoute, route)) return;
    _offerRoute = null;
    if (identical(c.pendingOffer, offer)) c.answerOffer(accepted == true);
  }

  Widget _offerContent(
    BuildContext context,
    FileOffer offer,
  ) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          Navigator.pop(context, false),
    },
    child: Focus(
      autofocus: true,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BadgeIcon(Icons.file_download_outlined),
              const SizedBox(height: 16),
              Text(
                '${offer.sender} 想发送${offer.isBatch
                    ? ' ${offer.files.length} 个文件'
                    : offer.isText
                    ? '文本'
                    : '文件'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                offer.isBatch
                    ? '确认一次，接收这批文件'
                    : offer.isText
                    ? '是否接收这段文本？'
                    : '是否接收这个文件？',
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _FileLabel(name: offer.name, size: offer.size),
              ),
              const Divider(height: 1),
              if (offer.isBatch) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: offer.files.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '${index + 1}. ${offer.files[index].name} · ${formatBytes(offer.files[index].size)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              Text(
                '来源名称未经验证，仅接收你认识的内容。请求将在 ${receiveApprovalTimeout.inMinutes} 分钟后过期。',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              if (!offer.isText && c.canChooseReceiveFolder) ...[
                const SizedBox(height: 12),
                Text(
                  '接收位置：${c.receiveLocation}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('拒绝'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        offer.isBatch
                            ? '接收全部'
                            : offer.isText
                            ? '接收文本'
                            : '接收文件',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _verify(Peer peer) async {
    if (c.busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('核对 ${peer.name}'),
        scrollable: true,
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('在对方设备打开「本机信息」，确认核对码与下方完全一致。'),
              _VerificationCode(peer.code),
              Text(
                '${peer.host}:${peer.port}',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              const Text(
                '设备名称不能证明身份。请实际查看对方屏幕后再确认。',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('一致，连接'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) c.select(peer);
  }

  Future<void> _localInfo() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('本机信息'),
      scrollable: true,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('让另一台设备查看此处的核对码。'),
            _VerificationCode(c.identity?.code ?? '正在生成…'),
            const Text('设备名称', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            SelectableText(c.name.isEmpty ? '准备中…' : c.name),
            const SizedBox(height: 20),
            const Text('手动连接地址', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            SelectableText(
              c.addresses.isEmpty ? '连接 Wi-Fi 后显示地址' : c.addresses.join('\n'),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            Text(
              c.backgroundTransferHint,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('完成'),
        ),
      ],
    ),
  );

  Future<void> _manual() async {
    var entered = '';
    final form = GlobalKey<FormState>();
    final address = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动连接'),
        scrollable: true,
        content: Form(
          key: form,
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('在对方设备的「本机信息」中找到地址。'),
                const SizedBox(height: 20),
                TextFormField(
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'monospace'),
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.url,
                  onChanged: (value) => entered = value,
                  decoration: const InputDecoration(
                    labelText: '设备地址',
                    hintText: '192.168.1.20:45879',
                    hintStyle: TextStyle(fontFamily: 'monospace'),
                    helperText: '地址与端口之间使用英文冒号 :',
                  ),
                  validator: (value) => validateManualAddress(value ?? ''),
                  onFieldSubmitted: (_) {
                    if (form.currentState!.validate()) {
                      Navigator.pop(context, normalizeManualAddress(entered));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, normalizeManualAddress(entered));
              }
            },
            child: const Text('下一步'),
          ),
        ],
      ),
    );
    if (address == null || !mounted) return;
    _message('正在连接设备…');
    try {
      final parts = address.split(':');
      final peer = await TransferClient.probe(parts[0], int.parse(parts[1]));
      if (mounted) await _verify(peer);
    } on Object catch (error) {
      if (mounted) _message('连接失败：$error');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop =
                constraints.maxWidth >= 720 &&
                constraints.maxHeight >= 480 &&
                MediaQuery.textScalerOf(context).scale(1) < 1.5;
            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 240,
                    child: ColoredBox(
                      color: colors.surfaceContainerLow,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                              child: Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(8, 0, 8, 28),
                                    child: _Brand(),
                                  ),
                                  _devices(),
                                ],
                              ),
                            ),
                          ),
                          _localFooter(),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colors.outlineVariant,
                  ),
                  Expanded(child: _content(true)),
                ],
              );
            }
            // Scaffold consumes the body's insets; read above it instead.
            if (MediaQuery.viewInsetsOf(this.context).bottom > 0 &&
                _textFocus.hasFocus &&
                c.sendKind == TransferKind.text &&
                c.selected != null) {
              return _phoneTextEditor();
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(child: _Brand()),
                      _settingsButton(),
                      IconButton(
                        tooltip: '本机信息',
                        onPressed: _localInfo,
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _content(false)),
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _phoneTextEditor() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '发送到 ${c.selected!.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: '收起键盘',
              onPressed: _textFocus.unfocus,
              icon: const Icon(Icons.keyboard_hide_outlined),
            ),
          ],
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _textComposer(expanded: true),
        ),
      ),
    ],
  );

  Widget _settingsButton() => IconButton(
    tooltip: '设置',
    onPressed: () {
      _textFocus.unfocus();
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => SettingsPage(controller: c)),
      );
    },
    icon: const Icon(Icons.settings_outlined),
  );

  Widget _localFooter() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(
          deviceIcon(c.deviceType),
          size: 22,
          semanticLabel: deviceTypeLabel(c.deviceType),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '本机',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                c.ready ? '可被附近设备发现' : '正在启动…',
                style: TextStyle(
                  fontSize: 12,
                  color: c.ready ? colors.tertiary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: '本机信息',
          onPressed: _localInfo,
          icon: const Icon(Icons.info_outline, size: 20),
        ),
      ],
    ),
  );

  Widget _devices() {
    final selected = c.selected;
    final peers = [...c.peers];
    if (selected != null &&
        !peers.any(
          (p) =>
              p.fingerprint == selected.fingerprint && p.host == selected.host,
        )) {
      peers.insert(0, selected);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '附近设备 ${c.peers.length}',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: '刷新设备',
              onPressed: c.ready ? () => unawaited(c.refreshAddresses()) : null,
              icon: const Icon(Icons.refresh, size: 21),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (peers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              c.starting ? '正在查找附近设备…' : '还没有发现设备',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        for (final peer in peers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _peer(peer),
          ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: c.ready && !c.busy ? _manual : null,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('手动连接'),
        ),
      ],
    );
  }

  Widget _peer(Peer peer) {
    final selected =
        c.selected?.fingerprint == peer.fingerprint &&
        c.selected?.host == peer.host;
    final discovered = c.peers.any(
      (p) =>
          p.fingerprint == peer.fingerprint &&
          p.host == peer.host &&
          p.port == peer.port,
    );
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? colors.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? colors.primary : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: c.busy ? null : () => _verify(peer),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _BadgeIcon(
                  deviceIcon(peer.deviceType),
                  size: 38,
                  semanticLabel: deviceTypeLabel(peer.deviceType),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peer.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected
                            ? (discovered ? '已核对 · 已选择' : '已核对 · 未发现')
                            : '未核对',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.check, size: 18, color: colors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(bool desktop) => ListView(
    key: const PageStorageKey('transfer-content'),
    padding: EdgeInsets.fromLTRB(
      desktop ? 32 : 20,
      desktop ? 28 : 4,
      desktop ? 32 : 20,
      24,
    ),
    children: [
      if (desktop) ...[
        Row(
          children: [
            Expanded(
              child: Text(
                c.receiving ? '接收内容' : '发送内容',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _settingsButton(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '文件与文本在设备之间直接传输。',
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
      ] else ...[
        _devices(),
        const SizedBox(height: 20),
      ],
      if (c.error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: colors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.error!,
                    style: TextStyle(color: colors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (c.receiving)
        _transferCard(incoming: true)
      else if (c.selected == null)
        _emptyState()
      else ...[
        Text(
          '发送到${desktop ? '' : ' ${c.selected!.name}'}',
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        if (desktop)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Row(
              children: [
                _BadgeIcon(
                  deviceIcon(c.selected!.deviceType),
                  semanticLabel: deviceTypeLabel(c.selected!.deviceType),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.selected!.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: colors.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '核对码已确认',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '查看设备核对码',
                  onPressed: c.busy ? null : () => _verify(c.selected!),
                  icon: const Icon(Icons.info_outline, size: 20),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 12),
        SegmentedButton<TransferKind>(
          segments: const [
            ButtonSegment(
              value: TransferKind.file,
              icon: Icon(Icons.insert_drive_file_outlined),
              label: Text('文件'),
            ),
            ButtonSegment(
              value: TransferKind.text,
              icon: Icon(Icons.notes_outlined),
              label: Text('文本'),
            ),
          ],
          selected: {c.sendKind},
          onSelectionChanged: c.busy
              ? null
              : (values) => c.setSendKind(values.single),
        ),
        const SizedBox(height: 16),
        if (c.sendKind == TransferKind.text)
          _textComposer()
        else if (c.chosenFile == null)
          _chooseFile()
        else
          _transferCard(),
      ],
      if (c.receiving || c.chosenFile != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _note(Icons.lock_outline, '内容仅在这两台设备之间传输。'),
        ),
      const SizedBox(height: 28),
      const Divider(height: 1),
      const SizedBox(height: 20),
      _history(),
      const SizedBox(height: 24),
      _note(Icons.lock_outline, '局域网直连 · 加密传输'),
      if (!c.sending && !c.receiving && c.status.startsWith('已'))
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Semantics(
            liveRegion: true,
            child: Text(
              c.status,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),
        ),
    ],
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Icon(
          c.peers.isEmpty ? Icons.wifi_find : Icons.devices_outlined,
          size: 44,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          c.starting
              ? '正在准备本机身份…'
              : c.peers.isEmpty
              ? '还没有发现附近设备'
              : '选择一台设备开始',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          c.peers.isEmpty
              ? '让两台设备连接同一 Wi-Fi，\n并在对方设备打开 Dukto2。'
              : '点击设备，核对屏幕上的身份码。',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: c.ready && !c.busy ? _manual : null,
          icon: const Icon(Icons.add_link),
          label: const Text('手动输入地址'),
        ),
      ],
    ),
  );

  Future<void> _copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) _message('已复制文本');
    } on Object {
      if (mounted) _message('无法复制，请重试');
    }
  }

  Future<void> _showText(TransferReceipt receipt) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('文本内容'),
      scrollable: true,
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (receipt.textTruncated ||
                receipt.text!.length > maxTextPreviewCharacters) ...[
              Text(
                receipt.textTruncated
                    ? '以下为预览。文本总大小 ${formatBytes(receipt.size)}，完整内容请打开文件查看。'
                    : '以下为预览，可使用「复制文本」复制完整内容。',
              ),
              const SizedBox(height: 12),
            ],
            SelectableText(textPreview(receipt.text!)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        if (receipt.file != null || receipt.contentUri != null)
          TextButton(
            onPressed: () => c.export(receipt),
            child: const Text('打开完整文本'),
          ),
        FilledButton.icon(
          onPressed: () => _copyText(receipt.text!),
          icon: const Icon(Icons.content_copy),
          label: Text(receipt.textTruncated ? '复制预览' : '复制文本'),
        ),
      ],
    ),
  );

  Future<void> _pasteText() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted || c.busy) return;
      final pasted = data?.text;
      if (pasted == null || pasted.isEmpty) {
        _message('剪贴板中没有文本');
        return;
      }
      final selection = _text.selection;
      final start = selection.isValid ? selection.start : _text.text.length;
      final end = selection.isValid ? selection.end : _text.text.length;
      final next = _text.text.replaceRange(start, end, pasted);
      if (utf8.encode(next).length > maxInlineTextBytes) {
        setState(() => _textIssue = '编辑区最多 1 MiB，大文本请从文件载入（上限 16 MiB）');
        return;
      }
      _text.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: start + pasted.length),
      );
      setState(() {
        _textIssue = null;
        c.sendPhase = SendPhase.idle;
      });
    } on Object {
      if (mounted) _message('无法读取剪贴板，请重试');
    }
  }

  Widget _textInput({
    required bool expanded,
    required bool tooLarge,
  }) => KeyedSubtree(
    // Keep the editor, selection and IME connection when the keyboard opens.
    key: _textEditorKey,
    child: TextField(
      key: const ValueKey('text-composer'),
      controller: _text,
      focusNode: _textFocus,
      minLines: expanded ? null : 4,
      maxLines: expanded ? null : 10,
      expands: expanded,
      textAlignVertical: TextAlignVertical.top,
      readOnly: c.busy,
      keyboardType: TextInputType.multiline,
      inputFormatters: [LengthLimitingTextInputFormatter(maxInlineTextBytes)],
      decoration: InputDecoration(
        labelText: '文本内容',
        hintText: '输入文字或粘贴链接',
        alignLabelWithHint: true,
        errorText: tooLarge ? '编辑区最多 1 MiB，大文本请从文件载入（上限 16 MiB）' : _textIssue,
      ),
      onChanged: (_) => setState(() {
        _textIssue = null;
        c.sendPhase = SendPhase.idle;
      }),
    ),
  );

  Widget _textComposer({bool expanded = false}) {
    final bytes = utf8.encode(_text.text).length;
    final tooLarge = bytes > maxInlineTextBytes;
    final fromFile = c.chosenTextFile != null;
    final supported = c.selected?.supportsText == true;
    final phase = c.sendPhase;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fromFile) ...[
            _FileLabel(name: c.chosenTextFile!.name, size: c.chosenTextSize!),
            const SizedBox(height: 12),
            Text(
              '已载入 UTF-8 文本文件，完整内容将流式传输。',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            SelectableText(textPreview(c.chosenTextPreview), maxLines: 8),
          ] else if (expanded)
            Expanded(child: _textInput(expanded: true, tooLarge: tooLarge))
          else
            _textInput(expanded: false, tooLarge: tooLarge),
          if (!expanded) ...[
            const SizedBox(height: 8),
            Text(
              '文本上限 16 MiB · 对方确认后接收',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
          if (!supported) ...[
            const SizedBox(height: 8),
            const Text('对方版本暂不支持文本，请先更新对方应用。'),
          ],
          if (c.sending) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(phase == SendPhase.waiting ? '等待对方接收文本…' : '正在发送并校验文本…'),
          ] else if (!expanded && phase == SendPhase.sent) ...[
            const SizedBox(height: 12),
            Text('文本已发送，对方校验通过', style: TextStyle(color: colors.tertiary)),
          ] else if (!expanded && phase == SendPhase.cancelled) ...[
            const SizedBox(height: 12),
            const Text('已取消发送，文本已保留'),
          ],
          const SizedBox(height: 8),
          Row(
            key: const ValueKey('text-actions'),
            children: [
              if (!c.sending) ...[
                IconButton(
                  tooltip: '粘贴文本',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: c.busy || fromFile ? null : _pasteText,
                  icon: const Icon(Icons.content_paste_outlined),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: '更多文本操作',
                  enabled: !c.busy,
                  requestFocus: expanded ? false : null,
                  offset: expanded ? const Offset(0, -112) : Offset.zero,
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  constraints: const BoxConstraints(minWidth: 200),
                  icon: const Icon(Icons.more_horiz),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'load', child: Text('载入文本文件')),
                    PopupMenuItem(
                      value: 'clear',
                      enabled: fromFile || _text.text.isNotEmpty,
                      child: const Text('清空内容'),
                    ),
                  ],
                  onSelected: (action) {
                    if (action == 'load') {
                      unawaited(c.pickTextFile());
                    } else {
                      setState(() {
                        c.clearTextFile();
                        _text.clear();
                        _textIssue = null;
                        c.sendPhase = SendPhase.idle;
                      });
                    }
                  },
                ),
              ],
              const Spacer(),
              const SizedBox(width: 8),
              if (c.sending)
                OutlinedButton(
                  onPressed: c.cancelTransfer,
                  child: const Text('取消传输'),
                )
              else
                Tooltip(
                  message: '发送文本',
                  child: FilledButton.icon(
                    key: const ValueKey('send-text'),
                    onPressed:
                        c.ready &&
                            !c.busy &&
                            supported &&
                            (fromFile ||
                                (!tooLarge && _text.text.trim().isNotEmpty))
                        ? () {
                            FocusScope.of(context).unfocus();
                            c.sendText(_text.text);
                          }
                        : null,
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: const Text('发送'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chooseFile() => Container(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colors.outline),
    ),
    child: Column(
      children: [
        Icon(
          Icons.file_upload_outlined,
          size: 38,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        const Text(
          '选择文件，发送给对方',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '对方确认接收后开始传输',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: c.ready && !c.busy ? c.pickFile : null,
          icon: const Icon(Icons.add, size: 20),
          label: Text(c.picking ? '正在选择…' : '选择文件'),
        ),
        const SizedBox(height: 14),
        Text(
          '支持多选 · 按顺序发送',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      ],
    ),
  );

  Widget _transferCard({bool incoming = false}) {
    final p = c.activeProgress;
    final bytes = p?.bytes ?? 0;
    final total = incoming
        ? c.receivingOffer?.size ?? p?.total ?? 0
        : c.chosenSize ?? 0;
    final name = incoming
        ? c.receivingOffer?.name ?? p?.name ?? '接收文件'
        : c.chosenFile!.name;
    final fraction = total == 0 ? 1.0 : (bytes / total).clamp(0.0, 1.0);
    final elapsed = c.transferStarted == null
        ? 0
        : DateTime.now().difference(c.transferStarted!).inMilliseconds / 1000;
    final phase = c.sendPhase;
    final active = incoming || c.sending;
    final phaseLabel = incoming
        ? (p == null
              ? c.receivingBatchRemaining > 0
                    ? '等待本批文件上传…'
                    : '等待发送方上传…'
              : bytes == total
              ? '正在校验文件…'
              : '正在接收')
        : switch (phase) {
            SendPhase.idle || SendPhase.ready => '准备就绪',
            SendPhase.waiting => '等待对方接收',
            SendPhase.uploading => '正在发送',
            SendPhase.verifying => '等待对方校验…',
            SendPhase.sent => '已发送，校验通过',
            SendPhase.cancelled => '已取消发送',
            SendPhase.failed => '发送失败，可重新发送',
          };
    final batch = !incoming && c.files.length > 1;
    final label = batch
        ? phase == SendPhase.sent
              ? '全部已发送，校验通过'
              : active
              ? '第 ${c.fileIndex + 1} / ${c.files.length} 项 · $phaseLabel'
              : '${c.completedFiles} / ${c.files.length} 项已发送 · $phaseLabel'
        : phaseLabel;
    final statusColor = phase == SendPhase.failed && !incoming
        ? colors.error
        : phase == SendPhase.sent && !incoming
        ? colors.tertiary
        : colors.onSurface;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _FileLabel(
                  name: batch ? '${c.files.length} 个文件' : name,
                  size: batch ? c.totalFileBytes : total,
                ),
              ),
              if (!active)
                IconButton(
                  tooltip: '移除已选文件',
                  onPressed: c.busy ? null : c.clearFile,
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
          ),
          if (batch) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: c.files.length,
                itemBuilder: (context, index) {
                  final item = c.files[index];
                  return Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          item.sent
                              ? Icons.check_circle_outline
                              : Icons.insert_drive_file_outlined,
                          size: 18,
                          color: item.sent
                              ? colors.tertiary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${item.file.name} · ${formatBytes(item.size)}${item.sent ? ' · 已发送' : ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: active && index == c.fileIndex
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      if (!active)
                        IconButton(
                          tooltip: '移除 ${item.file.name}',
                          onPressed: c.busy ? null : () => c.removeFile(index),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                incoming
                    ? Icons.file_download_outlined
                    : phase == SendPhase.sent
                    ? Icons.check_circle_outline
                    : phase == SendPhase.failed
                    ? Icons.error_outline
                    : phase == SendPhase.waiting
                    ? Icons.schedule
                    : phase == SendPhase.cancelled
                    ? Icons.close
                    : Icons.file_upload_outlined,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, color: statusColor),
                  ),
                ),
              ),
              if (active && p != null)
                Text(
                  '${(fraction * 100).floor()}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: p == null ? null : fraction,
              minHeight: 5,
              borderRadius: BorderRadius.circular(8),
              semanticsLabel: incoming ? '接收进度' : '发送进度',
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  '${formatBytes(bytes)} / ${formatBytes(total)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (p != null && elapsed > .2)
                  Text(
                    '${formatBytes((bytes / elapsed).round())}/s',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (active)
                  OutlinedButton(
                    onPressed: c.cancelTransfer,
                    child: const Text('取消传输'),
                  )
                else if (phase == SendPhase.sent)
                  FilledButton(
                    onPressed: c.busy ? null : c.clearFile,
                    child: const Text('发送其他文件'),
                  )
                else ...[
                  TextButton(
                    onPressed: c.busy ? null : c.pickFile,
                    child: const Text('重新选择'),
                  ),
                  FilledButton.icon(
                    onPressed: c.ready && !c.busy ? c.sendFile : null,
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: Text(
                      c.completedFiles > 0
                          ? '继续发送'
                          : phase == SendPhase.failed
                          ? '重新发送'
                          : '发送文件',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    final devices = c.history.map((entry) => entry.peerName).toSet().toList();
    final selectedDevice = devices.contains(_historyDevice)
        ? _historyDevice
        : null;
    final entries = c.history.where(
      (entry) => selectedDevice == null || entry.peerName == selectedDevice,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              const Text(
                '最近传输',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (devices.isNotEmpty)
                SizedBox(
                  width: (constraints.maxWidth * .55).clamp(120.0, 260.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          key: const ValueKey('history-device-filter'),
                          value: selectedDevice,
                          hint: const Text(
                            '全部设备',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selectedItemBuilder: (context) => [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '全部设备',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            for (final device in devices)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  device.isEmpty ? '另一台设备' : device,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          isExpanded: true,
                          itemHeight: null,
                          menuMaxHeight: 360,
                          borderRadius: BorderRadius.circular(8),
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface,
                          ),
                          onChanged: (value) =>
                              setState(() => _historyDevice = value),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('全部设备'),
                              ),
                            ),
                            for (final device in devices)
                              DropdownMenuItem<String>(
                                value: device,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    device.isEmpty ? '另一台设备' : device,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (c.history.isEmpty)
          Text(
            '完成的文件与文本会显示在这里。',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        for (final entry in entries.take(20)) _historyEntry(entry),
      ],
    );
  }

  Widget _historyEntry(HistoryEntry entry) {
    final name = entry.receipt.text == null ? entry.receipt.name : '文本消息';
    final peer = entry.peerName.isEmpty ? '另一台设备' : entry.peerName;
    final status = entry.incoming ? '已接收' : '已发送';
    final secondary = TextStyle(fontSize: 12, color: colors.onSurfaceVariant);
    final title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Tooltip(
            message: name,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(formatBytes(entry.receipt.size), style: secondary),
      ],
    );
    final device = Tooltip(
      message: '$status · $peer',
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: status,
              style: TextStyle(color: colors.tertiary),
            ),
            TextSpan(text: ' · $peer'),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: secondary,
      ),
    );
    final time = Tooltip(
      message: entry.time.toLocal().toString(),
      child: Text(formatHistoryTime(entry.time), style: secondary),
    );
    final duration = entry.elapsed == null
        ? null
        : Text('耗时 ${formatElapsed(entry.elapsed!)}', style: secondary);
    final action = entry.receipt.text != null
        ? TextButton(
            key: const ValueKey('history-text-actions'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => _showText(entry.receipt),
            child: const Text('查看文本', maxLines: 1),
          )
        : Tooltip(
            message: c.canOpenHistoryDirectory(entry)
                ? '打开本机文件所在目录'
                : '此记录没有可用的本机文件位置',
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: c.canOpenHistoryDirectory(entry)
                  ? () => c.openHistoryDirectory(entry)
                  : null,
              child: const Text('打开目录', maxLines: 1),
            ),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= 600 &&
              MediaQuery.textScalerOf(context).scale(1) < 1.5;
          if (wide) {
            return Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    entry.incoming
                        ? Icons.file_download_outlined
                        : Icons.file_upload_outlined,
                    size: 22,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    key: const ValueKey('history-entry-info'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 6), device],
                  ),
                ),
                const SizedBox(width: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Column(
                    key: const ValueKey('history-entry-timing'),
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      time,
                      if (duration != null) ...[
                        const SizedBox(height: 6),
                        duration,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                action,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      key: const ValueKey('history-entry-info'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        device,
                        const SizedBox(height: 4),
                        Wrap(
                          key: const ValueKey('history-entry-timing'),
                          spacing: 8,
                          runSpacing: 4,
                          children: [time, ?duration],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  action,
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _note(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      ),
    ],
  );
}

class _VerificationCode extends StatelessWidget {
  final String code;
  const _VerificationCode(this.code);
  @override
  Widget build(BuildContext context) {
    final chunks = code.split(' ');
    final text = chunks.length == 4
        ? '${chunks.take(2).join(' ')}\n${chunks.skip(2).join(' ')}'
        : code;
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SelectableText(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.asset(
          'assets/branding/dukto2.png',
          width: 32,
          height: 32,
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(width: 10),
      const Flexible(
        child: Text(
          'Dukto2',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            letterSpacing: -.5,
          ),
        ),
      ),
    ],
  );
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final String? semanticLabel;
  const _BadgeIcon(this.icon, {this.size = 44, this.semanticLabel});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      icon,
      size: 22,
      color: Theme.of(context).colorScheme.primary,
      semanticLabel: semanticLabel,
    ),
  );
}

class _FileLabel extends StatelessWidget {
  final String name;
  final int size;
  const _FileLabel({required this.name, required this.size});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const _BadgeIcon(Icons.description_outlined),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              formatBytes(size),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
