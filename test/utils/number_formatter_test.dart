import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

void main() {
  group('NumberFormatter', () {
    test('formats small numbers without suffix', () {
      expect(NumberFormatter.format(0), '0');
      expect(NumberFormatter.format(5), '5');
      expect(NumberFormatter.format(99), '99');
      expect(NumberFormatter.format(999), '999');
    });

    test('formats thousands with K suffix', () {
      expect(NumberFormatter.format(1000), '1.0K');
      expect(NumberFormatter.format(1500), '1.5K');
      expect(NumberFormatter.format(999000), '999.0K');
    });

    test('formats millions with M suffix', () {
      expect(NumberFormatter.format(1000000), '1.0M');
      expect(NumberFormatter.format(2300000), '2.3M');
    });

    test('formats billions with B suffix', () {
      expect(NumberFormatter.format(1000000000), '1.0B');
      expect(NumberFormatter.format(5600000000), '5.6B');
    });

    test('formats trillions with T suffix', () {
      expect(NumberFormatter.format(1000000000000), '1.0T');
    });

    test('formatRate adds /sec', () {
      expect(NumberFormatter.formatRate(1.5), '1.5/sec');
      expect(NumberFormatter.formatRate(1500), '1.5K/sec');
    });

    test('formatWithCommas adds commas', () {
      expect(NumberFormatter.formatWithCommas(1234567), '1,234,567');
      expect(NumberFormatter.formatWithCommas(999), '999');
    });
  });
}
