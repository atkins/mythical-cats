import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/conquest_territory.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ConquestTerritory', () {
    test('creates territory with all properties', () {
      final territory = ConquestTerritory(
        id: 'test_territory',
        name: 'Test Territory',
        cost: 100,
        productionBonus: {ResourceType.cats: 0.05},
        prerequisite: null,
      );

      expect(territory.id, 'test_territory');
      expect(territory.name, 'Test Territory');
      expect(territory.cost, 100);
      expect(territory.productionBonus[ResourceType.cats], 0.05);
      expect(territory.prerequisite, isNull);
    });

    test('territory can have prerequisite', () {
      final territory = ConquestTerritory(
        id: 'advanced',
        name: 'Advanced',
        cost: 500,
        productionBonus: {ResourceType.offerings: 0.10},
        prerequisite: 'basic',
      );

      expect(territory.prerequisite, 'basic');
    });
  });
}
