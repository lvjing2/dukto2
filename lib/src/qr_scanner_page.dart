import 'dart:io';

import 'localization.dart';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'connection_qr.dart';
import 'windows_qr_scanner_page.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _finished = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Platform.isWindows
      ? const WindowsQrScannerPage()
      : Scaffold(
          appBar: AppBar(title: Text(context.l10n.scanQr)),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    onDetect: (capture) {
                      if (_finished) return;
                      for (final barcode in capture.barcodes) {
                        final value = barcode.rawValue;
                        if (value == null) continue;
                        try {
                          final qr = ConnectionQr.parse(value);
                          _finished = true;
                          Navigator.pop(context, qr);
                          return;
                        } on FormatException {
                          final message = context.l10n.qrInvalid;
                          if (_error != message) {
                            setState(() => _error = message);
                          }
                        }
                      }
                    },
                    errorBuilder: (context, error) => Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography_outlined, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.cameraUnavailable,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(context.l10n.backToConnection),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.qrAim, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.subnetHint,
                          textAlign: TextAlign.center,
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
}
