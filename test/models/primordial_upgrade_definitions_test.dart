import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialUpgradeDefinitions', () {
    test('chaos upgrades have correct tier progression', () {
      final chaos1 = PrimordialUpgradeDefinitions.chaosI;
      final chaos5 = PrimordialUpgradeDefinitions.chaosV;

      expect(chaos1.force, PrimordialForce.chaos);
      expect(chaos1.tier, 1);
      expect(chaos1.cost, 10);

      expect(chaos5.tier, 5);
      expect(chaos5.cost, 200);
    });

    test('gaia upgrades exist', () {
      expect(PrimordialUpgradeDefinitions.gaiaI, isNotNull);
      expect(PrimordialUpgradeDefinitions.gaiaV, isNotNull);
    });

    test('nyx upgrades exist', () {
      expect(PrimordialUpgradeDefinitions.nyxI, isNotNull);
      expect(PrimordialUpgradeDefinitions.nyxV, isNotNull);
    });

    test('erebus upgrades exist', () {
      expect(PrimordialUpgradeDefinitions.erebusI, isNotNull);
      expect(PrimordialUpgradeDefinitions.erebusV, isNotNull);
    });

    test('all returns 20 upgrades', () {
      expect(PrimordialUpgradeDefinitions.all.length, 20);
    });

    test('getForceUpgrades filters correctly', () {
      final chaosUpgrades = PrimordialUpgradeDefinitions.getForceUpgrades(PrimordialForce.chaos);
      expect(chaosUpgrades.length, 5);
      expect(chaosUpgrades.every((u) => u.force == PrimordialForce.chaos), true);
    });

    test('getById returns correct upgrade', () {
      final upgrade = PrimordialUpgradeDefinitions.getById('chaos_1');
      expect(upgrade?.id, 'chaos_1');
      expect(upgrade?.force, PrimordialForce.chaos);
    });
  });
}
