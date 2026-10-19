import 'localization.dart';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'connection_qr.dart';

class ConnectionQrCard extends StatelessWidget {
  final ConnectionQr qr;
  const ConnectionQrCard({super.key, required this.qr});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.connectionQr,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      if (qr.addresses.isEmpty)
        Text(context.l10n.qrAfterWifi)
      else
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 280, height: 280),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: context.l10n.qrSemantic,
                image: true,
                excludeSemantics: true,
                child: QrImageView(
                  data: qr.encode(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 8),
      Text(context.l10n.qrVerify),
    ],
  );
}
