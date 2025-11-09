import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('God', () {
    test('Hermes is the starting god with no unlock requirement', () {
      expect(God.hermes.unlockRequirement, null);
    });

    test('all gods have display names', () {
      for (final god in God.values) {
        expect(god.displayName.isNotEmpty, true);
      }
    });

    test('all gods have descriptions', () {
      for (final god in God.values) {
        expect(god.description.isNotEmpty, true);
      }
    });

    test('unlock requirements increase exponentially', () {
      expect(God.hestia.unlockRequirement, 1000);
      expect(God.demeter.unlockRequirement, 10000);
      expect(God.dionysus.unlockRequirement, 100000);
    });
  });
}
