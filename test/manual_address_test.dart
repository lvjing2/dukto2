import 'package:flutter_test/flutter_test.dart';
import 'package:dukto2/src/manual_address.dart';

void main() {
  test('IME full-width characters normalize to ASCII IPv4 and port', () {
    for (final value in [
      '１９２．１６８．３１．１８：３０００',
      '192。168。31。18：3000',
      ' 192.168.31.18 : 3000 ',
    ]) {
      expect(normalizeManualAddress(value), '192.168.31.18:3000');
      expect(validateManualAddress(value), isNull);
    }
  });
  test('normalizing punctuation never accepts URLs or invalid endpoints', () {
    for (final value in [
      'https://192.168.31.18:3000',
      '192.168.31.999:3000',
      '192.168.31.18:0',
      '192.168.31.18:65536',
      '192.168.31.18',
      '192.168.31.18:3000:1',
    ]) {
      expect(validateManualAddress(value), isNotNull);
    }
  });
}
