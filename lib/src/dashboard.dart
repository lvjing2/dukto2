import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import 'localization.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dukto2_core/dukto2_core.dart';

import 'controller.dart';
import 'connection_qr.dart';
import 'connection_qr_card.dart';
import 'qr_scanner_page.dart';
import 'manual_address.dart';
import 'settings_page.dart';

String formatBytes(int bytes, {String? locale}) {
  // Isolate the Latin unit and number together within an RTL paragraph.
  String directed(String value) =>
      locale?.startsWith('ar') == true ? '\u2066$value\u2069' : value;
  String number(num n, int digits) => locale == null
      ? n.toStringAsFixed(digits)
      : NumberFormat.decimalPatternDigits(
          locale: locale,
          decimalDigits: digits,
        ).format(n);
  if (bytes < 1024) return directed('$bytes B');
  if (bytes < 1024 * 1024) return directed('${number(bytes / 1024, 1)} KB');
  if (bytes < 1024 * 1024 * 1024) {
    return directed('${number(bytes / (1024 * 1024), 1)} MB');
  }
  return directed('${number(bytes / (1024 * 1024 * 1024), 2)} GB');
}

String formatHistoryTime(
  DateTime value, {
  DateTime? now,
  AppLocalizations? localization,
}) {
  final messages = localization ?? fallbackMessages;
  final time = value.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final clock = localization == null
      ? '${two(time.hour)}:${two(time.minute)}'
      : DateFormat.Hm(messages.localeName).format(time);
  final date = DateTime(time.year, time.month, time.day);
  final current = DateTime(today.year, today.month, today.day);
  if (date == current) return messages.todayTime((clock).toString());
  if (date == DateTime(current.year, current.month, current.day - 1)) {
    return messages.yesterdayTime((clock).toString());
  }
  if (localization == null) {
    return '${time.year == today.year ? '' : '${time.year}/'}${two(time.month)}/${two(time.day)} $clock';
  }
  return '${(time.year == today.year ? DateFormat.Md(messages.localeName) : DateFormat.yMd(messages.localeName)).format(time)} $clock';
}

String formatElapsed(Duration elapsed, {AppLocalizations? localization}) {
  final messages = localization ?? fallbackMessages;
  if (elapsed.inMilliseconds < 1000) return messages.lessThanSecond;
  if (elapsed.inSeconds < 60) {
    return messages.secondsDuration(
      NumberFormat.decimalPatternDigits(
        locale: messages.localeName,
        decimalDigits: 1,
      ).format(elapsed.inMilliseconds / 1000),
    );
  }
  final seconds = elapsed.inSeconds % 60;
  final minutes = elapsed.inMinutes % 60;
  return elapsed.inHours == 0
      ? messages.minutesDuration((minutes).toString(), (seconds).toString())
      : messages.hoursDuration(
          (elapsed.inHours).toString(),
          (minutes).toString(),
          (seconds).toString(),
        );
}

IconData deviceIcon(DeviceType type) => switch (type) {
  DeviceType.phone => Icons.smartphone_outlined,
  DeviceType.tablet => Icons.tablet_mac_outlined,
  DeviceType.computer => Icons.computer_outlined,
  DeviceType.unknown => Icons.devices_outlined,
};

String deviceTypeLabel(DeviceType type, {AppLocalizations? localization}) {
  final messages = localization ?? fallbackMessages;
  return switch (type) {
    DeviceType.phone => messages.phone,
    DeviceType.tablet => messages.tablet,
    DeviceType.computer => messages.computer,
    DeviceType.unknown => messages.device,
  };
}

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
  bool _textIssue = false;
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
                context.l10n.incomingOffer(
                  (offer.sender).toString(),
                  offer.isBatch
                      ? context.l10n.fileCount(offer.files.length)
                      : offer.isText
                      ? context.l10n.text
                      : context.l10n.file,
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                offer.isBatch
                    ? context.l10n.batchConsent
                    : offer.isText
                    ? context.l10n.textConsent
                    : context.l10n.fileConsent,
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _FileLabel(
                  name: offer.isBatch
                      ? context.l10n.fileCount(offer.files.length)
                      : offer.isText
                      ? context.l10n.textMessage
                      : offer.name,
                  size: offer.size,
                ),
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
                        '${index + 1}. ${offer.files[index].name} · ${formatBytes(offer.files[index].size, locale: context.l10n.localeName)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              Text(
                context.l10n.approvalWarning(
                  (receiveApprovalTimeout.inMinutes).toString(),
                ),
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              if (!offer.isText && c.canChooseReceiveFolder) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.receiveAt((c.receiveLocation).toString()),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.l10n.decline),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        offer.isBatch
                            ? context.l10n.receiveAll
                            : offer.isText
                            ? context.l10n.receiveText
                            : context.l10n.receiveFile,
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
        title: Text(context.l10n.verifyPeer((peer.name).toString())),
        scrollable: true,
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.verificationInstructions),
              _VerificationCode(peer.code),
              Text(
                '${peer.host}:${peer.port}',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.verificationWarning,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirmConnection),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) c.select(peer);
  }

  Future<void> _localInfo() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.localInfo),
      scrollable: true,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.showLocalCode),
            _VerificationCode(c.identity?.code ?? context.l10n.generating),
            Text(context.l10n.deviceName, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            SelectableText(c.name.isEmpty ? context.l10n.preparing : c.name),
            if (c.server != null) ...[
              const SizedBox(height: 20),
              ConnectionQrCard(
                qr: ConnectionQr.local(c.server!.localPeer, c.addresses),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              context.l10n.connectionAddress,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            SelectableText(
              c.addresses.isEmpty
                  ? context.l10n.addressWhenConnected
                  : c.addresses.join('\n'),
              textDirection: c.addresses.isEmpty ? null : TextDirection.ltr,
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
          child: Text(context.l10n.done),
        ),
      ],
    ),
  );

  Future<void> _scan() async {
    final qr = await Navigator.of(context).push<ConnectionQr>(
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (qr == null || !mounted || c.busy) return;
    if (qr.fingerprint == c.identity?.fingerprint) {
      _message(context.l10n.qrSelf);
      return;
    }
    _message(context.l10n.qrConnecting);
    try {
      await c.connectQr(qr);
    } on Object {
      if (mounted) _message(context.l10n.qrConnectionFailed);
    }
  }

  Widget _connectionActions() {
    final manual = OutlinedButton.icon(
      onPressed: c.ready && !c.busy ? _manual : null,
      icon: const Icon(Icons.add_link, size: 20),
      label: Text(context.l10n.enterAddress),
    );
    if (!c.canScanQr) {
      return Align(alignment: AlignmentDirectional.centerStart, child: manual);
    }
    final secondaryStyle = TextButton.styleFrom(
      foregroundColor: colors.onSurfaceVariant,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      textStyle: Theme.of(context).textTheme.labelMedium
          ?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
    );
    final scanAction = TextButton.icon(
      style: secondaryStyle,
      onPressed: c.ready && !c.busy ? _scan : null,
      icon: const Icon(Icons.qr_code_scanner, size: 18),
      label: Text(context.l10n.scanQr),
    );
    final manualAction = TextButton.icon(
      style: secondaryStyle,
      onPressed: c.ready && !c.busy ? _manual : null,
      icon: const Icon(Icons.add_link, size: 18),
      label: Text(context.l10n.enterAddress),
    );
    if (MediaQuery.sizeOf(context).width >= 600) {
      return Wrap(spacing: 8, children: [scanAction, manualAction]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: scanAction),
          const SizedBox(width: 8),
          Expanded(child: manualAction),
        ],
      ),
    );
  }

  Future<void> _manual() async {
    var entered = '';
    final form = GlobalKey<FormState>();
    final address = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.manualConnection),
        scrollable: true,
        content: Form(
          key: form,
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.findPeerAddress),
                const SizedBox(height: 20),
                TextFormField(
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'monospace'),
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.url,
                  onChanged: (value) => entered = value,
                  decoration: InputDecoration(
                    labelText: context.l10n.deviceAddress,
                    hintText: '192.168.1.20:45879',
                    hintStyle: TextStyle(fontFamily: 'monospace'),
                    helperText: context.l10n.addressSeparator,
                  ),
                  validator: (value) => validateManualAddress(
                    value ?? '',
                    localization: context.l10n,
                  ),
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
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, normalizeManualAddress(entered));
              }
            },
            child: Text(context.l10n.next),
          ),
        ],
      ),
    );
    if (address == null || !mounted) return;
    _message(context.l10n.connecting);
    try {
      final parts = address.split(':');
      final peer = await TransferClient.probe(parts[0], int.parse(parts[1]));
      if (mounted) await _verify(peer);
    } on Object {
      if (mounted) _message(context.l10n.connectionFailed);
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
                        tooltip: context.l10n.localInfo,
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
                '${context.l10n.sendToPeer(c.selected!.name)} · $_connectionText',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: context.l10n.hideKeyboard,
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
    tooltip: context.l10n.settings,
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
          semanticLabel: deviceTypeLabel(
            c.deviceType,
            localization: context.l10n,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.thisDevice,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                c.ready ? context.l10n.discoverable : context.l10n.starting,
                style: TextStyle(
                  fontSize: 12,
                  color: c.ready ? colors.tertiary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.localInfo,
          onPressed: _localInfo,
          icon: const Icon(Icons.info_outline, size: 20),
        ),
      ],
    ),
  );

  String get _connectionText => switch (c.connectionState) {
    PeerConnectionState.online => context.l10n.deviceOnline,
    PeerConnectionState.offline => context.l10n.deviceOffline,
    PeerConnectionState.checking => context.l10n.deviceChecking,
    PeerConnectionState.identityChanged => context.l10n.deviceIdentityChanged,
  };

  Widget _connectionDot(PeerConnectionState state) => ExcludeSemantics(
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: state == PeerConnectionState.online
            ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.green.shade400
                  : Colors.green.shade700)
            : state == PeerConnectionState.identityChanged
            ? colors.error
            : colors.onSurfaceVariant,
      ),
    ),
  );

  Widget _connectionStatus() => Row(
    children: [
      _connectionDot(c.connectionState),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          _connectionText,
          style: TextStyle(
            fontSize: 12,
            color: c.connectionState == PeerConnectionState.identityChanged
                ? colors.error
                : colors.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );

  Widget _devices() {
    final peers = c.peers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.nearbyDevices((c.peers.length).toString()),
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: context.l10n.refreshDevices,
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
              c.starting ? context.l10n.findingDevices : context.l10n.noDevices,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        for (final peer in peers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _peer(peer),
          ),
        const SizedBox(height: 4),
        _connectionActions(),
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
                _BadgeIcon(
                  deviceIcon(peer.deviceType),
                  size: 38,
                  semanticLabel: deviceTypeLabel(
                    peer.deviceType,
                    localization: context.l10n,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _connectionDot(
                            selected
                                ? c.connectionState
                                : PeerConnectionState.online,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              peer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected
                            ? (c.connectionState == PeerConnectionState.online
                                  ? context.l10n.verifiedSelected
                                  : _connectionText)
                            : context.l10n.unverified,
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
                    padding: const EdgeInsetsDirectional.only(start: 4),
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
                c.receiving
                    ? context.l10n.receivingContent
                    : context.l10n.sendingContent,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _settingsButton(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.directTransfer,
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
          context.l10n.sendTo(
            (desktop ? '' : ' ${c.selected!.name}').toString(),
          ),
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        if (desktop)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Row(
              children: [
                _BadgeIcon(
                  deviceIcon(c.selected!.deviceType),
                  semanticLabel: deviceTypeLabel(
                    c.selected!.deviceType,
                    localization: context.l10n,
                  ),
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
                      _connectionStatus(),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.viewVerification,
                  onPressed: c.busy ? null : () => _verify(c.selected!),
                  icon: const Icon(Icons.info_outline, size: 20),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _connectionStatus(),
          ),
        SegmentedButton<TransferKind>(
          segments: [
            ButtonSegment(
              value: TransferKind.file,
              icon: Icon(Icons.insert_drive_file_outlined),
              label: Text(context.l10n.file),
            ),
            ButtonSegment(
              value: TransferKind.text,
              icon: Icon(Icons.notes_outlined),
              label: Text(context.l10n.text),
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
          child: _note(Icons.lock_outline, context.l10n.betweenDevices),
        ),
      const SizedBox(height: 28),
      const Divider(height: 1),
      const SizedBox(height: 20),
      _history(),
      const SizedBox(height: 24),
      _note(Icons.lock_outline, context.l10n.encryptedLan),
      if (!c.sending && !c.receiving && c.ready)
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
              ? context.l10n.preparingIdentity
              : c.peers.isEmpty
              ? context.l10n.noNearbyDevices
              : context.l10n.selectDevice,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          c.peers.isEmpty
              ? context.l10n.qrInstructions
              : context.l10n.selectVerifyHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ],
    ),
  );

  Future<void> _copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) _message(context.l10n.textCopied);
    } on Object {
      if (mounted) _message(context.l10n.copyFailed);
    }
  }

  Future<void> _showText(TransferReceipt receipt) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.textContent),
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
                    ? context.l10n.filePreviewHint(
                        (formatBytes(
                          receipt.size,
                          locale: context.l10n.localeName,
                        )).toString(),
                      )
                    : context.l10n.textPreviewHint,
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
          child: Text(context.l10n.close),
        ),
        if (receipt.file != null || receipt.contentUri != null)
          TextButton(
            onPressed: () => c.export(receipt),
            child: Text(context.l10n.openFullText),
          ),
        FilledButton.icon(
          onPressed: () => _copyText(receipt.text!),
          icon: const Icon(Icons.content_copy),
          label: Text(
            receipt.textTruncated
                ? context.l10n.copyPreview
                : context.l10n.copyText,
          ),
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
        _message(context.l10n.emptyClipboard);
        return;
      }
      final selection = _text.selection;
      final start = selection.isValid ? selection.start : _text.text.length;
      final end = selection.isValid ? selection.end : _text.text.length;
      final next = _text.text.replaceRange(start, end, pasted);
      if (utf8.encode(next).length > maxInlineTextBytes) {
        setState(() => _textIssue = true);
        return;
      }
      _text.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: start + pasted.length),
      );
      setState(() {
        _textIssue = false;
        c.sendPhase = SendPhase.idle;
      });
    } on Object {
      if (mounted) _message(context.l10n.clipboardFailed);
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
        labelText: context.l10n.textContent,
        hintText: context.l10n.textPlaceholder,
        alignLabelWithHint: true,
        errorText: (tooLarge || _textIssue) ? context.l10n.editorLimit : null,
      ),
      onChanged: (_) => setState(() {
        _textIssue = false;
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
              context.l10n.textFileLoaded,
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
              context.l10n.textLimit,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
          if (!supported) ...[
            const SizedBox(height: 8),
            Text(context.l10n.textUnsupported),
          ],
          if (c.sending) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              phase == SendPhase.waiting
                  ? context.l10n.waitingText
                  : context.l10n.sendingText,
            ),
          ] else if (!expanded && phase == SendPhase.sent) ...[
            const SizedBox(height: 12),
            Text(
              context.l10n.textSent,
              style: TextStyle(color: colors.tertiary),
            ),
          ] else if (!expanded && phase == SendPhase.cancelled) ...[
            const SizedBox(height: 12),
            Text(context.l10n.textCancelled),
          ],
          const SizedBox(height: 8),
          Row(
            key: const ValueKey('text-actions'),
            children: [
              if (!c.sending) ...[
                IconButton(
                  tooltip: context.l10n.pasteText,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: c.busy || fromFile ? null : _pasteText,
                  icon: const Icon(Icons.content_paste_outlined),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: context.l10n.moreTextActions,
                  enabled: !c.busy,
                  requestFocus: expanded ? false : null,
                  offset: expanded ? const Offset(0, -112) : Offset.zero,
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  constraints: const BoxConstraints(minWidth: 200),
                  icon: const Icon(Icons.more_horiz),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'load',
                      child: Text(context.l10n.loadTextFile),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      enabled: fromFile || _text.text.isNotEmpty,
                      child: Text(context.l10n.clearText),
                    ),
                  ],
                  onSelected: (action) {
                    if (action == 'load') {
                      unawaited(c.pickTextFile());
                    } else {
                      setState(() {
                        c.clearTextFile();
                        _text.clear();
                        _textIssue = false;
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
                  child: Text(context.l10n.cancelTransfer),
                )
              else
                Tooltip(
                  message: context.l10n.sendText,
                  child: FilledButton.icon(
                    key: const ValueKey('send-text'),
                    onPressed:
                        c.ready &&
                            !c.busy &&
                            c.canSendToSelected &&
                            supported &&
                            (fromFile ||
                                (!tooLarge && _text.text.trim().isNotEmpty))
                        ? () {
                            FocusScope.of(context).unfocus();
                            c.sendText(_text.text);
                          }
                        : null,
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: Text(context.l10n.send),
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
        Text(
          context.l10n.chooseFileHint,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.approvalBeforeTransfer,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: c.ready && !c.busy ? c.pickFile : null,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            c.picking ? context.l10n.picking : context.l10n.chooseFiles,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.multiSelectHint,
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
        ? c.receivingOffer?.name ?? p?.name ?? context.l10n.receiveFile
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
                    ? context.l10n.waitingBatch
                    : context.l10n.waitingUpload
              : bytes == total
              ? context.l10n.verifyingFile
              : context.l10n.receiving)
        : switch (phase) {
            SendPhase.idle || SendPhase.ready => context.l10n.ready,
            SendPhase.waiting => context.l10n.waitingReceiver,
            SendPhase.uploading => context.l10n.sending,
            SendPhase.verifying => context.l10n.waitingVerification,
            SendPhase.sent => context.l10n.sentVerified,
            SendPhase.cancelled => context.l10n.sendCancelled,
            SendPhase.failed => context.l10n.sendFailedRetry,
          };
    final batch = !incoming && c.files.length > 1;
    final label = batch
        ? phase == SendPhase.sent
              ? context.l10n.batchSent
              : active
              ? context.l10n.batchCurrent(
                  (c.fileIndex + 1).toString(),
                  (c.files.length).toString(),
                  (phaseLabel).toString(),
                )
              : context.l10n.batchCompleted(
                  (c.completedFiles).toString(),
                  (c.files.length).toString(),
                  (phaseLabel).toString(),
                )
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
                  name: batch ? context.l10n.fileCount(c.files.length) : name,
                  size: batch ? c.totalFileBytes : total,
                ),
              ),
              if (!active)
                IconButton(
                  tooltip: context.l10n.removeFiles,
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
                            '${item.file.name} · ${formatBytes(item.size, locale: context.l10n.localeName)}${item.sent ? ' · ${context.l10n.sent}' : ''}',
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
                          tooltip: context.l10n.removeFile(
                            (item.file.name).toString(),
                          ),
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
              semanticsLabel: incoming
                  ? context.l10n.receiveProgress
                  : context.l10n.sendProgress,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  '${formatBytes(bytes, locale: context.l10n.localeName)} / ${formatBytes(total, locale: context.l10n.localeName)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (p != null && elapsed > .2)
                  Text(
                    '${formatBytes((bytes / elapsed).round(), locale: context.l10n.localeName)}/s',
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
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (active)
                  OutlinedButton(
                    onPressed: c.cancelTransfer,
                    child: Text(context.l10n.cancelTransfer),
                  )
                else if (phase == SendPhase.sent)
                  FilledButton(
                    onPressed: c.busy ? null : c.clearFile,
                    child: Text(context.l10n.sendOtherFiles),
                  )
                else ...[
                  TextButton(
                    onPressed: c.busy ? null : c.pickFile,
                    child: Text(context.l10n.chooseAgain),
                  ),
                  FilledButton.icon(
                    onPressed: c.ready && !c.busy && c.canSendToSelected
                        ? c.sendFile
                        : null,
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: Text(
                      c.completedFiles > 0
                          ? context.l10n.continueSending
                          : phase == SendPhase.failed
                          ? context.l10n.resend
                          : context.l10n.sendFiles,
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
              Text(
                context.l10n.recentTransfers,
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
                          hint: Text(
                            context.l10n.allDevices,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selectedItemBuilder: (context) => [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                context.l10n.allDevices,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            for (final device in devices)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  device.isEmpty
                                      ? context.l10n.otherDevice
                                      : device,
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
                            DropdownMenuItem<String>(
                              value: null,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(context.l10n.allDevices),
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
                                    device.isEmpty
                                        ? context.l10n.otherDevice
                                        : device,
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
            context.l10n.emptyHistory,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        for (final entry in entries.take(20)) _historyEntry(entry),
      ],
    );
  }

  Widget _historyEntry(HistoryEntry entry) {
    final name = entry.receipt.text == null
        ? entry.receipt.name
        : context.l10n.textMessage;
    final peer = entry.peerName.isEmpty
        ? context.l10n.otherDevice
        : entry.peerName;
    final status = entry.incoming ? context.l10n.received : context.l10n.sent;
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
        Text(
          formatBytes(entry.receipt.size, locale: context.l10n.localeName),
          style: secondary,
        ),
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
      child: Text(
        formatHistoryTime(entry.time, localization: context.l10n),
        style: secondary,
      ),
    );
    final duration = entry.elapsed == null
        ? null
        : Text(
            context.l10n.durationLabel(
              (formatElapsed(
                entry.elapsed!,
                localization: context.l10n,
              )).toString(),
            ),
            style: secondary,
          );
    final action = entry.receipt.text != null
        ? TextButton(
            key: const ValueKey('history-text-actions'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => _showText(entry.receipt),
            child: Text(context.l10n.viewText, maxLines: 1),
          )
        : Tooltip(
            message: c.canOpenHistoryDirectory(entry)
                ? context.l10n.openFolderHint
                : context.l10n.noLocalFile,
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: c.canOpenHistoryDirectory(entry)
                  ? () => c.openHistoryDirectory(entry)
                  : null,
              child: Text(context.l10n.openFolder, maxLines: 1),
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
        textDirection: TextDirection.ltr,
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
              formatBytes(size, locale: context.l10n.localeName),
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
