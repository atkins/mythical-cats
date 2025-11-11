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

    group('Athena Buildings', () {
      test('hallOfWisdom has correct display name', () {
        expect(BuildingType.hallOfWisdom.displayName, 'Hall of Wisdom');
      });

      test('hallOfWisdom has correct description', () {
        expect(BuildingType.hallOfWisdom.description,
          'The foundational wisdom structure, a library of divine knowledge');
      });

      test('hallOfWisdom requires Athena', () {
        expect(BuildingType.hallOfWisdom.requiredGod, God.athena);
      });

      test('academyOfAthens has correct display name', () {
        expect(BuildingType.academyOfAthens.displayName, 'Academy of Athens');
      });

      test('academyOfAthens has correct description', () {
        expect(BuildingType.academyOfAthens.description,
          'Where mortals and minor deities study the arts and sciences');
      });

      test('academyOfAthens requires Athena', () {
        expect(BuildingType.academyOfAthens.requiredGod, God.athena);
      });

      test('strategyChamber has correct display name', () {
        expect(BuildingType.strategyChamber.displayName, 'Strategy Chamber');
      });

      test('strategyChamber has correct description', () {
        expect(BuildingType.strategyChamber.description,
          'War room where tactical planning generates strategic insights');
      });

      test('strategyChamber requires Athena', () {
        expect(BuildingType.strategyChamber.requiredGod, God.athena);
      });

      test('oraclesArchive has correct display name', () {
        expect(BuildingType.oraclesArchive.displayName, 'Oracle\'s Archive');
      });

      test('oraclesArchive has correct description', () {
        expect(BuildingType.oraclesArchive.description,
          'Repository of prophecies and divine foresight');
      });

      test('oraclesArchive requires Athena', () {
        expect(BuildingType.oraclesArchive.requiredGod, God.athena);
      });
    });

    group('Apollo Buildings', () {
      test('templeOfDelphi has correct display name', () {
        expect(BuildingType.templeOfDelphi.displayName, 'Temple of Delphi');
      });

      test('templeOfDelphi has correct description', () {
        expect(BuildingType.templeOfDelphi.description,
          'The sacred site of prophecy and oracles');
      });

      test('templeOfDelphi requires Apollo', () {
        expect(BuildingType.templeOfDelphi.requiredGod, God.apollo);
      });

      test('sunChariotStable has correct display name', () {
        expect(BuildingType.sunChariotStable.displayName, 'Sun Chariot Stable');
      });

      test('sunChariotStable has correct description', () {
        expect(BuildingType.sunChariotStable.description,
          'Where Apollo\'s golden chariot rests, radiating enlightenment');
      });

      test('sunChariotStable requires Apollo', () {
        expect(BuildingType.sunChariotStable.requiredGod, God.apollo);
      });

      test('musesSanctuary has correct display name', () {
        expect(BuildingType.musesSanctuary.displayName, 'Muses\' Sanctuary');
      });

      test('musesSanctuary has correct description', () {
        expect(BuildingType.musesSanctuary.description,
          'Home to the nine muses who inspire wisdom and creativity');
      });

      test('musesSanctuary requires Apollo', () {
        expect(BuildingType.musesSanctuary.requiredGod, God.apollo);
      });

      test('celestialObservatory has correct display name', () {
        expect(BuildingType.celestialObservatory.displayName, 'Celestial Observatory');
      });

      test('celestialObservatory has correct description', () {
        expect(BuildingType.celestialObservatory.description,
          'Tracks celestial movements to predict divine patterns');
      });

      test('celestialObservatory requires Apollo', () {
        expect(BuildingType.celestialObservatory.requiredGod, God.apollo);
      });
    });
  });
}
