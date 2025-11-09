import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ResourceType', () {
    test('has correct display names', () {
      expect(ResourceType.cats.displayName, 'Cats');
      expect(ResourceType.offerings.displayName, 'Offerings');
      expect(ResourceType.prayers.displayName, 'Prayers');
    });

    test('has icons for all types', () {
      for (final type in ResourceType.values) {
        expect(type.icon.isNotEmpty, true);
      }
    });
  });
}
