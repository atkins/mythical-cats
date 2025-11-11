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

    test('academy has correct properties', () {
      const academy = BuildingDefinitions.academy;
      expect(academy.type, BuildingType.academy);
      expect(academy.baseCost[ResourceType.cats], 50000);
      expect(academy.baseCost[ResourceType.prayers], 5000);
      expect(academy.baseProduction, 1.0);
      expect(academy.productionType, ResourceType.cats);
    });

    test('essenceRefinery has correct properties', () {
      const refinery = BuildingDefinitions.essenceRefinery;
      expect(refinery.type, BuildingType.essenceRefinery);
      expect(refinery.baseCost[ResourceType.cats], 100000);
      expect(refinery.baseCost[ResourceType.offerings], 10000);
      expect(refinery.baseProduction, 0.5);
      expect(refinery.productionType, ResourceType.divineEssence);
      expect(refinery.costMultiplier, 1.20);
    });

    test('nectarBrewery has correct properties', () {
      const brewery = BuildingDefinitions.nectarBrewery;
      expect(brewery.type, BuildingType.nectarBrewery);
      expect(brewery.baseCost[ResourceType.cats], 1000000);
      expect(brewery.baseCost[ResourceType.divineEssence], 500);
      expect(brewery.baseProduction, 0.1);
      expect(brewery.productionType, ResourceType.ambrosia);
      expect(brewery.costMultiplier, 1.25);
    });

    test('workshop has correct properties', () {
      const workshop = BuildingDefinitions.workshop;
      expect(workshop.type, BuildingType.workshop);
      expect(workshop.baseCost[ResourceType.cats], 250000);
      expect(workshop.baseCost[ResourceType.divineEssence], 100);
      expect(workshop.baseProduction, 0); // Conversion building, no passive production
    });

    test('warMonument has correct properties', () {
      const monument = BuildingDefinitions.warMonument;
      expect(monument.type, BuildingType.warMonument);
      expect(monument.baseCost[ResourceType.cats], 5000000);
      expect(monument.baseCost[ResourceType.ambrosia], 1000);
      expect(monument.baseProduction, 1.0);
      expect(monument.productionType, ResourceType.conquestPoints);
    });

    test('get returns correct definition for Phase 3 buildings', () {
      expect(BuildingDefinitions.get(BuildingType.academy).type, BuildingType.academy);
      expect(BuildingDefinitions.get(BuildingType.essenceRefinery).type, BuildingType.essenceRefinery);
      expect(BuildingDefinitions.get(BuildingType.nectarBrewery).type, BuildingType.nectarBrewery);
      expect(BuildingDefinitions.get(BuildingType.workshop).type, BuildingType.workshop);
      expect(BuildingDefinitions.get(BuildingType.warMonument).type, BuildingType.warMonument);
    });

    group('Athena Buildings', () {
      test('hallOfWisdom has correct properties', () {
        const building = BuildingDefinitions.hallOfWisdom;
        expect(building.type, BuildingType.hallOfWisdom);
        expect(building.baseCost[ResourceType.cats], 75000);
        expect(building.baseProduction, 0.1);
        expect(building.productionType, ResourceType.wisdom);
      });

      test('academyOfAthens has correct properties', () {
        const building = BuildingDefinitions.academyOfAthens;
        expect(building.type, BuildingType.academyOfAthens);
        expect(building.baseCost[ResourceType.cats], 500000);
        expect(building.baseProduction, 0.8);
        expect(building.productionType, ResourceType.wisdom);
      });

      test('strategyChamber has correct properties', () {
        const building = BuildingDefinitions.strategyChamber;
        expect(building.type, BuildingType.strategyChamber);
        expect(building.baseCost[ResourceType.cats], 3000000);
        expect(building.baseProduction, 5.0);
        expect(building.productionType, ResourceType.wisdom);
      });

      test('oraclesArchive has correct properties', () {
        const building = BuildingDefinitions.oraclesArchive;
        expect(building.type, BuildingType.oraclesArchive);
        expect(building.baseCost[ResourceType.cats], 15000000);
        expect(building.baseProduction, 25.0);
        expect(building.productionType, ResourceType.wisdom);
      });
    });

    group('Apollo Buildings', () {
      test('templeOfDelphi has correct properties', () {
        const building = BuildingDefinitions.templeOfDelphi;
        expect(building.type, BuildingType.templeOfDelphi);
        expect(building.baseCost[ResourceType.cats], 250000);
        expect(building.baseProduction, 2.0);
        expect(building.productionType, ResourceType.wisdom);
      });

      test('sunChariotStable has correct properties', () {
        const building = BuildingDefinitions.sunChariotStable;
        expect(building.type, BuildingType.sunChariotStable);
        expect(building.baseCost[ResourceType.cats], 1500000);
        expect(building.baseProduction, 12.0);
        expect(building.productionType, ResourceType.wisdom);
      });

      test('musesSanctuary has correct properties', () {
        const building = BuildingDefinitions.musesSanctuary;
        expect(building.type, BuildingType.musesSanctuary);
        expect(building.baseCost[ResourceType.cats], 8000000);
        expect(building.baseProduction, 60.0);
        expect(building.productionType, ResourceType.wisdom);
      });

      test('celestialObservatory has correct properties', () {
        const building = BuildingDefinitions.celestialObservatory;
        expect(building.type, BuildingType.celestialObservatory);
        expect(building.baseCost[ResourceType.cats], 40000000);
        expect(building.baseProduction, 280.0);
        expect(building.productionType, ResourceType.wisdom);
      });
    });
  });
}
