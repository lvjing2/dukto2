import 'localization.dart';

import 'dart:io';

/// Accept common IME punctuation while preserving strict IPv4/port validation.
String normalizeManualAddress(String value) => String.fromCharCodes(
  value.runes.map((rune) {
    if (rune >= 0xff01 && rune <= 0xff5e) return rune - 0xfee0;
    if (rune == 0x3002 || rune == 0xff61 || rune == 0xfe52) return 0x2e;
    if (rune == 0xfe55) return 0x3a;
    return rune;
  }),
).trim().replaceAllMapped(RegExp(r'\s*([.:])\s*'), (m) => m[1]!);

String? validateManualAddress(String value, {AppLocalizations? localization}) {
  final messages = localization ?? fallbackMessages;
  final parts = normalizeManualAddress(value).split(':');
  if (parts.length != 2) return messages.addressRequired;
  final ip = InternetAddress.tryParse(parts[0]);
  final port = int.tryParse(parts[1]);
  return ip?.type == InternetAddressType.IPv4 &&
          port != null &&
          port > 0 &&
          port <= 65535
      ? null
      : messages.addressInvalid;
}
