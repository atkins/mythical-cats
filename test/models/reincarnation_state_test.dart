import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('ReincarnationState', () {
    test('creates default state', () {
      const state = ReincarnationState();

      expect(state.totalPrimordialEssence, 0);
      expect(state.availablePrimordialEssence, 0);
      expect(state.ownedUpgradeIds, isEmpty);
      expect(state.activePatron, isNull);
      expect(state.totalReincarnations, 0);
      expect(state.lifetimeCatsEarned, 0);
      expect(state.thisRunCatsEarned, 0);
    });

    test('creates state with values', () {
      const state = ReincarnationState(
        totalPrimordialEssence: 100,
        availablePrimordialEssence: 50,
        ownedUpgradeIds: {'chaos_1', 'gaia_1'},
        activePatron: PrimordialForce.chaos,
        totalReincarnations: 5,
        lifetimeCatsEarned: 1000000,
        thisRunCatsEarned: 10000,
      );

      expect(state.totalPrimordialEssence, 100);
      expect(state.availablePrimordialEssence, 50);
      expect(state.ownedUpgradeIds.length, 2);
      expect(state.activePatron, PrimordialForce.chaos);
      expect(state.totalReincarnations, 5);
      expect(state.lifetimeCatsEarned, 1000000);
      expect(state.thisRunCatsEarned, 10000);
    });

    test('copyWith creates new instance', () {
      const state = ReincarnationState(
        totalPrimordialEssence: 100,
        totalReincarnations: 5,
      );

      final newState = state.copyWith(
        totalPrimordialEssence: 150,
      );

      expect(newState.totalPrimordialEssence, 150);
      expect(newState.totalReincarnations, 5); // unchanged
      expect(state.totalPrimordialEssence, 100); // original unchanged
    });

    test('toJson serializes correctly', () {
      const state = ReincarnationState(
        totalPrimordialEssence: 100,
        availablePrimordialEssence: 50,
        ownedUpgradeIds: {'chaos_1', 'gaia_1'},
        activePatron: PrimordialForce.chaos,
        totalReincarnations: 5,
        lifetimeCatsEarned: 1000000,
        thisRunCatsEarned: 10000,
      );

      final json = state.toJson();

      expect(json['totalPrimordialEssence'], 100);
      expect(json['availablePrimordialEssence'], 50);
      expect(json['ownedUpgradeIds'], ['chaos_1', 'gaia_1']);
      expect(json['activePatron'], 'chaos');
      expect(json['totalReincarnations'], 5);
      expect(json['lifetimeCatsEarned'], 1000000);
      expect(json['thisRunCatsEarned'], 10000);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'totalPrimordialEssence': 100,
        'availablePrimordialEssence': 50,
        'ownedUpgradeIds': ['chaos_1', 'gaia_1'],
        'activePatron': 'chaos',
        'totalReincarnations': 5,
        'lifetimeCatsEarned': 1000000,
        'thisRunCatsEarned': 10000,
      };

      final state = ReincarnationState.fromJson(json);

      expect(state.totalPrimordialEssence, 100);
      expect(state.availablePrimordialEssence, 50);
      expect(state.ownedUpgradeIds, {'chaos_1', 'gaia_1'});
      expect(state.activePatron, PrimordialForce.chaos);
      expect(state.totalReincarnations, 5);
      expect(state.lifetimeCatsEarned, 1000000);
      expect(state.thisRunCatsEarned, 10000);
    });

    test('fromJson handles null activePatron', () {
      final json = {
        'totalPrimordialEssence': 100,
        'availablePrimordialEssence': 50,
        'ownedUpgradeIds': <String>[],
        'activePatron': null,
        'totalReincarnations': 0,
        'lifetimeCatsEarned': 0,
        'thisRunCatsEarned': 0,
      };

      final state = ReincarnationState.fromJson(json);
      expect(state.activePatron, isNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final state = ReincarnationState.fromJson(json);

      expect(state.totalPrimordialEssence, 0);
      expect(state.availablePrimordialEssence, 0);
      expect(state.ownedUpgradeIds, isEmpty);
      expect(state.activePatron, isNull);
      expect(state.totalReincarnations, 0);
      expect(state.lifetimeCatsEarned, 0);
      expect(state.thisRunCatsEarned, 0);
    });
  });
}
