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

    test('all 11 territories exist', () {
      expect(ConquestDefinitions.all.length, 11);
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

  group('Phase 5 Territories', () {
    test('libraryOfAlexandria has correct properties', () {
      const territory = ConquestDefinitions.libraryOfAlexandria;
      expect(territory.id, 'library_of_alexandria');
      expect(territory.name, 'Library of Alexandria');
      expect(territory.cost, 5000000);
      expect(territory.productionBonus[ResourceType.wisdom], 0.25);
      expect(territory.prerequisite, 'titans_realm');
    });

    test('oracleOfDelphi has correct properties', () {
      const territory = ConquestDefinitions.oracleOfDelphi;
      expect(territory.id, 'oracle_of_delphi');
      expect(territory.name, 'Oracle of Delphi');
      expect(territory.cost, 2500000);
      expect(territory.productionBonus.containsKey(ResourceType.wisdom), true);
      expect(territory.prerequisite, 'titans_realm');
    });

    test('academyOfAthens has correct properties', () {
      const territory = ConquestDefinitions.academyOfAthens;
      expect(territory.id, 'academy_of_athens');
      expect(territory.name, 'Academy of Athens');
      expect(territory.cost, 10000000);
      expect(territory.productionBonus[ResourceType.wisdom], 0.50); // +50% Wisdom
      expect(territory.prerequisite, 'titans_realm');
    });
  });
}
