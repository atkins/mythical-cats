import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('God', () {
    test('all gods have required properties', () {
      for (final god in God.values) {
        expect(god.displayName.isNotEmpty, true,
            reason: '${god.name} should have a display name');
        expect(god.description.isNotEmpty, true,
            reason: '${god.name} should have a description');
      }
    });

    test('Hermes is the starting god with no unlock requirement', () {
      expect(God.hermes.unlockRequirement, null);
    });

    test('unlock requirements increase exponentially', () {
      expect(God.hestia.unlockRequirement, 1000);
      expect(God.demeter.unlockRequirement, 10000);
      expect(God.dionysus.unlockRequirement, 100000);
      expect(God.athena.unlockRequirement, 1000000);
      expect(God.apollo.unlockRequirement, 10000000);
    });
  });
}
