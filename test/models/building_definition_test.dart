import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('BuildingDefinition', () {
    test('calculateCost scales with cost multiplier', () {
      final def = BuildingDefinitions.smallShrine;

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
      final def = BuildingDefinitions.smallShrine;

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
  });
}
