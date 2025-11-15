import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ResourceType', () {
    test('all resource types have required properties', () {
      for (final type in ResourceType.values) {
        expect(type.displayName.isNotEmpty, true,
            reason: '${type.name} should have a display name');
        expect(type.icon.isNotEmpty, true,
            reason: '${type.name} should have an icon');
      }
    });

    test('key resource types have correct display names', () {
      expect(ResourceType.cats.displayName, 'Cats');
      expect(ResourceType.offerings.displayName, 'Offerings');
      expect(ResourceType.prayers.displayName, 'Prayers');
      expect(ResourceType.conquestPoints.displayName, 'Conquest Points');
      expect(ResourceType.wisdom.displayName, 'Wisdom');
    });

    test('Wisdom has correct tier and description', () {
      expect(ResourceType.wisdom.description, 'Divine knowledge and insight');
      expect(ResourceType.wisdom.tier, 2);
    });
  });
}
