import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('BuildingType', () {
    test('all Phase 3 buildings exist', () {
      expect(BuildingType.academy, isNotNull);
      expect(BuildingType.essenceRefinery, isNotNull);
      expect(BuildingType.nectarBrewery, isNotNull);
      expect(BuildingType.workshop, isNotNull);
      expect(BuildingType.warMonument, isNotNull);
    });

    test('all building types have required properties', () {
      for (final building in BuildingType.values) {
        expect(building.displayName.isNotEmpty, true,
            reason: '${building.name} should have a display name');
        expect(building.description.isNotEmpty, true,
            reason: '${building.name} should have a description');
      }
    });

    group('Athena Buildings', () {
      final athenaBuildings = [
        BuildingType.hallOfWisdom,
        BuildingType.academyOfAthens,
        BuildingType.strategyChamber,
        BuildingType.oraclesArchive,
      ];

      test('all Athena buildings require Athena god', () {
        for (final building in athenaBuildings) {
          expect(building.requiredGod, God.athena,
              reason: '${building.displayName} should require Athena');
        }
      });

      test('Athena buildings have correct display names', () {
        expect(BuildingType.hallOfWisdom.displayName, 'Hall of Wisdom');
        expect(BuildingType.academyOfAthens.displayName, 'Academy of Athens');
        expect(BuildingType.strategyChamber.displayName, 'Strategy Chamber');
        expect(BuildingType.oraclesArchive.displayName, 'Oracle\'s Archive');
      });
    });

    group('Apollo Buildings', () {
      final apolloBuildings = [
        BuildingType.templeOfDelphi,
        BuildingType.sunChariotStable,
        BuildingType.musesSanctuary,
        BuildingType.celestialObservatory,
      ];

      test('all Apollo buildings require Apollo god', () {
        for (final building in apolloBuildings) {
          expect(building.requiredGod, God.apollo,
              reason: '${building.displayName} should require Apollo');
        }
      });

      test('Apollo buildings have correct display names', () {
        expect(BuildingType.templeOfDelphi.displayName, 'Temple of Delphi');
        expect(BuildingType.sunChariotStable.displayName, 'Sun Chariot Stable');
        expect(BuildingType.musesSanctuary.displayName, 'Muses\' Sanctuary');
        expect(BuildingType.celestialObservatory.displayName, 'Celestial Observatory');
      });
    });
  });
}
