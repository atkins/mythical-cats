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
  });
}
