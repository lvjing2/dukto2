import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dukto2_core/dukto2_core.dart';

import 'controller.dart';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

class TransferDashboard extends StatefulWidget {
  final Dukto2Controller controller;
  final VoidCallback? onToggleTheme;
  const TransferDashboard({
    super.key,
    required this.controller,
    this.onToggleTheme,
  });
  @override
  State<TransferDashboard> createState() => _TransferDashboardState();
}

class _TransferDashboardState extends State<TransferDashboard> {
  Dukto2Controller get c => widget.controller;
  ColorScheme get colors => Theme.of(context).colorScheme;
  Route<bool>? _offerRoute;
  FileOffer? _shownOffer;
  bool _syncScheduled = false;
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
    super.dispose();
  }

  void _scheduleOffer() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) unawaited(_syncOffer());
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

  Widget _offerContent(BuildContext context, FileOffer offer) =>
      CallbackShortcuts(
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
                    '${offer.sender} 想发送文件',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('是否接收这个文件？'),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _FileLabel(name: offer.name, size: offer.size),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    '来源名称未经验证，仅接收你认识的文件。请求将在 60 秒后过期。',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
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
                          child: const Text('接收文件'),
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
              '传输时请让两台设备保持应用在前台。',
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

  Future<void> _about() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('关于 dukto2'),
      scrollable: true,
      content: const SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dukto2 · 0.1.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('致敬 Dukto 与原作者 Emanuele Colombo，感谢 xuzhen 及社区贡献者的持续维护。'),
            SizedBox(height: 16),
            Text('由 OpenAI Codex 在人工指导下创作代码、UI、测试与文档。'),
            SizedBox(height: 16),
            Text('一个希望延续 Dukto 简单、直接体验的独立重写项目。'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              showLicensePage(context: context, applicationName: 'dukto2'),
          child: const Text('第三方许可'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    ),
  );

  Widget _aboutButton() => IconButton(
    tooltip: '关于 dukto2',
    onPressed: _about,
    icon: const Icon(Icons.more_horiz),
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
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.url,
                  onChanged: (value) => entered = value,
                  decoration: const InputDecoration(
                    labelText: '设备地址',
                    hintText: '192.168.1.20:45879',
                  ),
                  validator: (value) {
                    final parts = (value?.trim() ?? '').split(':');
                    if (parts.length != 2) return '请输入 IPv4 地址和端口';
                    final ip = InternetAddress.tryParse(parts[0]);
                    final port = int.tryParse(parts[1]);
                    return ip?.type == InternetAddressType.IPv4 &&
                            port != null &&
                            port > 0 &&
                            port <= 65535
                        ? null
                        : '请输入有效的 IPv4 地址和 1–65535 端口';
                  },
                  onFieldSubmitted: (_) {
                    if (form.currentState!.validate()) {
                      Navigator.pop(context, entered.trim());
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
                Navigator.pop(context, entered.trim());
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(child: _Brand()),
                      if (widget.onToggleTheme != null) _themeButton(),
                      IconButton(
                        tooltip: '本机信息',
                        onPressed: _localInfo,
                        icon: const Icon(Icons.info_outline),
                      ),
                      _aboutButton(),
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

  Widget _themeButton() => IconButton(
    tooltip: Theme.of(context).brightness == Brightness.dark ? '切换浅色' : '切换深色',
    onPressed: widget.onToggleTheme,
    icon: Icon(
      Theme.of(context).brightness == Brightness.dark
          ? Icons.light_mode_outlined
          : Icons.dark_mode_outlined,
    ),
  );

  Widget _localFooter() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        const Icon(Icons.laptop_mac_outlined, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '这台 Mac',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                '附近设备 ${peers.length}',
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
                const _BadgeIcon(Icons.devices_outlined, size: 38),
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
                        selected ? '已核对 · 当前连接' : '未核对',
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
                c.receiving ? '接收文件' : '发送文件',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (widget.onToggleTheme != null) _themeButton(),
            _aboutButton(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '文件在设备之间直接传输。',
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
                const _BadgeIcon(Icons.devices_outlined),
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
        if (c.chosenFile == null) _chooseFile() else _transferCard(),
      ],
      if (c.receiving || c.chosenFile != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _note(Icons.lock_outline, '文件仅在这两台设备之间传输。'),
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
              ? '让两台设备连接同一 Wi-Fi，\n并在对方设备打开 dukto2。'
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
          '选择一个文件，发送给对方',
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
          '每次发送一个文件 · 保留原始内容',
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
    final label = incoming
        ? (p == null
              ? '等待发送方上传…'
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
                child: _FileLabel(name: name, size: total),
              ),
              if (!active)
                IconButton(
                  tooltip: '移除已选文件',
                  onPressed: c.busy ? null : c.clearFile,
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
          ),
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
                    child: const Text('发送另一个文件'),
                  )
                else ...[
                  TextButton(
                    onPressed: c.busy ? null : c.pickFile,
                    child: const Text('更换文件'),
                  ),
                  FilledButton.icon(
                    onPressed: c.ready && !c.busy ? c.sendFile : null,
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: Text(phase == SendPhase.failed ? '重新发送' : '发送文件'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '最近传输',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      if (c.history.isEmpty)
        Text(
          '完成的文件会显示在这里。',
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
      for (final entry in c.history.take(20))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                entry.incoming
                    ? Icons.file_download_outlined
                    : Icons.file_upload_outlined,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.receipt.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.incoming ? '来自' : '发往'} ${entry.peerName.isEmpty ? '另一台设备' : entry.peerName} · ${formatBytes(entry.receipt.size)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.incoming ? '已接收' : '已发送',
                    style: TextStyle(fontSize: 12, color: colors.tertiary),
                  ),
                  if (entry.incoming)
                    TextButton(
                      onPressed: () => c.export(entry.receipt),
                      child: Text(Platform.isAndroid ? '保存到…' : '查看'),
                    )
                  else
                    Text(
                      '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  IconButton(
                    tooltip: '复制 SHA-256 校验值',
                    iconSize: 16,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: entry.receipt.sha256),
                      );
                      _message('已复制 SHA-256 校验值');
                    },
                    icon: const Icon(Icons.content_copy),
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );

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
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          Icons.near_me_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
      ),
      const SizedBox(width: 10),
      const Flexible(
        child: Text(
          'dukto2',
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
  const _BadgeIcon(this.icon, {this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
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
