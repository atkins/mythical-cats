import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialForce', () {
    test('has all 4 forces', () {
      expect(PrimordialForce.chaos, isNotNull);
      expect(PrimordialForce.gaia, isNotNull);
      expect(PrimordialForce.nyx, isNotNull);
      expect(PrimordialForce.erebus, isNotNull);
    });

    test('has correct display names', () {
      expect(PrimordialForce.chaos.displayName, 'Chaos');
      expect(PrimordialForce.gaia.displayName, 'Gaia');
      expect(PrimordialForce.nyx.displayName, 'Nyx');
      expect(PrimordialForce.erebus.displayName, 'Erebus');
    });

    test('has correct descriptions', () {
      expect(PrimordialForce.chaos.description, 'Active Play - Click Power');
      expect(PrimordialForce.gaia.description, 'Building Production & Efficiency');
      expect(PrimordialForce.nyx.description, 'Offline Progression & Time');
      expect(PrimordialForce.erebus.description, 'Tier 2 Resources & Wealth');
    });

    test('has correct icons', () {
      expect(PrimordialForce.chaos.icon, '⚡');
      expect(PrimordialForce.gaia.icon, '🌿');
      expect(PrimordialForce.nyx.icon, '🌙');
      expect(PrimordialForce.erebus.icon, '💎');
    });
  });
}
