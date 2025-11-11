import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/primordial_upgrade.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialUpgrade', () {
    test('creates upgrade with all properties', () {
      const upgrade = PrimordialUpgrade(
        id: 'chaos_1',
        force: PrimordialForce.chaos,
        tier: 1,
        cost: 10,
        name: 'Chaos I',
        effect: '+10% click power',
      );

      expect(upgrade.id, 'chaos_1');
      expect(upgrade.force, PrimordialForce.chaos);
      expect(upgrade.tier, 1);
      expect(upgrade.cost, 10);
      expect(upgrade.name, 'Chaos I');
      expect(upgrade.effect, '+10% click power');
    });

    test('different tiers have different costs', () {
      const tier1 = PrimordialUpgrade(
        id: 'chaos_1',
        force: PrimordialForce.chaos,
        tier: 1,
        cost: 10,
        name: 'Chaos I',
        effect: '+10% click power',
      );

      const tier2 = PrimordialUpgrade(
        id: 'chaos_2',
        force: PrimordialForce.chaos,
        tier: 2,
        cost: 25,
        name: 'Chaos II',
        effect: '+25% click power',
      );

      expect(tier1.cost, 10);
      expect(tier2.cost, 25);
    });
  });
}
