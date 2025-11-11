import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ConquestDefinitions', () {
    test('northernWilds has correct properties', () {
      const territory = ConquestDefinitions.northernWilds;
      expect(territory.id, 'northern_wilds');
      expect(territory.cost, 100);
      expect(territory.productionBonus[ResourceType.cats], 0.05);
      expect(territory.prerequisite, isNull);
    });

    test('easternMountains requires northernWilds', () {
      const territory = ConquestDefinitions.easternMountains;
      expect(territory.prerequisite, 'northern_wilds');
      expect(territory.cost, 500);
    });

    test('all 8 territories exist', () {
      expect(ConquestDefinitions.all.length, 8);
    });

    test('getById returns correct territory', () {
      final territory = ConquestDefinitions.getById('northern_wilds');
      expect(territory?.id, 'northern_wilds');
    });

    test('getById returns null for invalid id', () {
      final territory = ConquestDefinitions.getById('invalid');
      expect(territory, isNull);
    });

    test('all territories have unique IDs', () {
      final ids = ConquestDefinitions.all.map((t) => t.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });
  });
}
