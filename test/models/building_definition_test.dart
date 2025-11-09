import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('BuildingDefinition', () {
    test('calculateCost scales with cost multiplier', () {
      const def = BuildingDefinitions.smallShrine;

      // First building costs base amount
      expect(def.calculateCost(0)[ResourceType.cats], 15);

      // Second building costs base * multiplier
      final secondCost = def.calculateCost(1)[ResourceType.cats]!;
      expect(secondCost, closeTo(15 * 1.15, 0.01));

      // Third building costs base * multiplier^2
      final thirdCost = def.calculateCost(2)[ResourceType.cats]!;
      expect(thirdCost, closeTo(15 * 1.15 * 1.15, 0.01));
    });

    test('calculateBulkCost sums individual costs', () {
      const def = BuildingDefinitions.smallShrine;

      final bulkCost = def.calculateBulkCost(0, 3)[ResourceType.cats]!;
      final individualSum =
        def.calculateCost(0)[ResourceType.cats]! +
        def.calculateCost(1)[ResourceType.cats]! +
        def.calculateCost(2)[ResourceType.cats]!;

      expect(bulkCost, closeTo(individualSum, 0.01));
    });

    test('all buildings can be retrieved by type', () {
      for (final type in BuildingType.values) {
        final def = BuildingDefinitions.get(type);
        expect(def.type, type);
      }
    });

    test('harvestField can be retrieved and has correct properties', () {
      final def = BuildingDefinitions.get(BuildingType.harvestField);
      expect(def.type, BuildingType.harvestField);
      expect(def.baseCost[ResourceType.cats], 5000);
      expect(def.baseCost[ResourceType.offerings], 500);
      expect(def.baseProduction, 1.0);
      expect(def.productionType, ResourceType.prayers);
    });

    test('festivalGrounds can be retrieved and has correct properties', () {
      final def = BuildingDefinitions.get(BuildingType.festivalGrounds);
      expect(def.type, BuildingType.festivalGrounds);
      expect(def.baseCost[ResourceType.cats], 15000);
      expect(def.baseCost[ResourceType.prayers], 1000);
      expect(def.baseProduction, 5.0);
      expect(def.productionType, ResourceType.cats);
    });
  });
}
