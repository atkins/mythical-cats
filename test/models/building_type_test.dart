import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/building_type.dart';

void main() {
  group('BuildingType', () {
    test('all Phase 3 buildings exist', () {
      expect(BuildingType.academy, isNotNull);
      expect(BuildingType.essenceRefinery, isNotNull);
      expect(BuildingType.nectarBrewery, isNotNull);
      expect(BuildingType.workshop, isNotNull);
      expect(BuildingType.warMonument, isNotNull);
    });
  });
}
