import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/prophecy.dart';
import 'package:mythical_cats/models/random_event_definitions.dart';

void main() {
  group('GameState', () {
    test('initial state has correct defaults', () {
      final state = GameState.initial();

      expect(state.getResource(ResourceType.cats), 0);
      expect(state.getResource(ResourceType.offerings), 0);
      expect(state.hasUnlockedGod(God.hermes), true);
      expect(state.hasUnlockedGod(God.hestia), false);
      expect(state.totalCatsEarned, 0);
    });

    test('copyWith creates new instance with changes', () {
      final state = GameState.initial();
      final newResources = {ResourceType.cats: 100.0};
      final newState = state.copyWith(resources: newResources);

      expect(newState.getResource(ResourceType.cats), 100);
      expect(state.getResource(ResourceType.cats), 0); // Original unchanged
    });

    test('getResource returns 0 for missing resources', () {
      final state = GameState.initial();
      expect(state.getResource(ResourceType.divineEssence), 0);
    });

    test('getBuildingCount returns 0 for buildings not built', () {
      final state = GameState.initial();
      expect(state.getBuildingCount(BuildingType.temple), 0);
    });

    test('toJson and fromJson round-trip correctly', () {
      final state = GameState(
        resources: {ResourceType.cats: 123.45},
        buildings: {BuildingType.smallShrine: 5},
        unlockedGods: {God.hermes, God.hestia},
        lastUpdate: DateTime(2025, 11, 8, 12, 0),
        totalCatsEarned: 200.0,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.getResource(ResourceType.cats), 123.45);
      expect(restored.getBuildingCount(BuildingType.smallShrine), 5);
      expect(restored.hasUnlockedGod(God.hermes), true);
      expect(restored.hasUnlockedGod(God.hestia), true);
      expect(restored.totalCatsEarned, 200.0);
    });

    test('hasUnlockedAchievement works correctly', () {
      final state = GameState.initial().copyWith(
        unlockedAchievements: {'cats_100', 'buildings_10'},
      );

      expect(state.hasUnlockedAchievement('cats_100'), true);
      expect(state.hasUnlockedAchievement('cats_1k'), false);
    });

    test('achievements serialize correctly', () {
      final state = GameState.initial().copyWith(
        unlockedAchievements: {'cats_100', 'buildings_10'},
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.unlockedAchievements.length, 2);
      expect(restored.hasUnlockedAchievement('cats_100'), true);
      expect(restored.hasUnlockedAchievement('buildings_10'), true);
    });

    test('initial state has empty completed research', () {
      final state = GameState.initial();
      expect(state.completedResearch.isEmpty, true);
    });

    test('hasCompletedResearch returns false for incomplete research', () {
      final state = GameState.initial();
      expect(state.hasCompletedResearch('divine_architecture_1'), false);
    });

    test('hasCompletedResearch returns true for completed research', () {
      final state = GameState.initial().copyWith(
        completedResearch: {'divine_architecture_1'},
      );
      expect(state.hasCompletedResearch('divine_architecture_1'), true);
    });

    test('completedResearch serializes in toJson', () {
      final state = GameState.initial().copyWith(
        completedResearch: {'divine_architecture_1', 'essence_refinement'},
      );
      final json = state.toJson();
      expect(json['completedResearch'], ['divine_architecture_1', 'essence_refinement']);
    });

    test('completedResearch deserializes from JSON', () {
      final state = GameState.initial().copyWith(
        completedResearch: {'divine_architecture_1'},
      );
      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.hasCompletedResearch('divine_architecture_1'), true);
    });

    test('initial state has empty conquered territories', () {
      final state = GameState.initial();
      expect(state.conqueredTerritories.isEmpty, true);
    });

    test('hasConqueredTerritory returns false for unconquered', () {
      final state = GameState.initial();
      expect(state.hasConqueredTerritory('northern_wilds'), false);
    });

    test('hasConqueredTerritory returns true for conquered', () {
      final state = GameState.initial().copyWith(
        conqueredTerritories: {'northern_wilds'},
      );
      expect(state.hasConqueredTerritory('northern_wilds'), true);
    });

    test('conqueredTerritories serializes correctly', () {
      final state = GameState.initial().copyWith(
        conqueredTerritories: {'northern_wilds', 'eastern_mountains'},
      );
      final json = state.toJson();
      expect(json['conqueredTerritories'], ['northern_wilds', 'eastern_mountains']);
    });

    test('includes reincarnation state', () {
      final state = GameState.initial();
      expect(state.reincarnationState, isNotNull);
      expect(state.reincarnationState.totalPrimordialEssence, 0);
    });

    test('copyWith updates reincarnation state', () {
      final state = GameState.initial();
      const newReincarnation = ReincarnationState(
        totalPrimordialEssence: 100,
        availablePrimordialEssence: 50,
      );

      final updated = state.copyWith(reincarnationState: newReincarnation);

      expect(updated.reincarnationState.totalPrimordialEssence, 100);
      expect(updated.reincarnationState.availablePrimordialEssence, 50);
    });

    test('toJson serializes reincarnation state', () {
      final state = GameState.initial().copyWith(
        reincarnationState: const ReincarnationState(
          totalPrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1'},
          activePatron: PrimordialForce.chaos,
        ),
      );

      final json = state.toJson();

      expect(json['reincarnationState'], isNotNull);
      expect(json['reincarnationState']['totalPrimordialEssence'], 100);
      expect(json['reincarnationState']['ownedUpgradeIds'], ['chaos_1']);
      expect(json['reincarnationState']['activePatron'], 'chaos');
    });

    test('fromJson deserializes reincarnation state', () {
      final json = <String, dynamic>{
        'resources': {'cats': 0, 'offerings': 0, 'prayers': 0},
        'buildings': <String, dynamic>{},
        'unlockedGods': ['hermes'],
        'lastUpdate': DateTime.now().toIso8601String(),
        'totalCatsEarned': 0,
        'unlockedAchievements': [],
        'completedResearch': [],
        'conqueredTerritories': [],
        'reincarnationState': {
          'totalPrimordialEssence': 100,
          'availablePrimordialEssence': 50,
          'ownedUpgradeIds': ['chaos_1'],
          'activePatron': 'chaos',
          'totalReincarnations': 5,
          'lifetimeCatsEarned': 1000000,
          'thisRunCatsEarned': 10000,
        },
      };

      final state = GameState.fromJson(json);

      expect(state.reincarnationState.totalPrimordialEssence, 100);
      expect(state.reincarnationState.availablePrimordialEssence, 50);
      expect(state.reincarnationState.ownedUpgradeIds, {'chaos_1'});
      expect(state.reincarnationState.activePatron, PrimordialForce.chaos);
    });

    // Task 4: Add Wisdom to GameState tests
    test('GameState initializes with 0 Wisdom', () {
      final state = GameState.initial();
      expect(state.resources[ResourceType.wisdom], 0);
    });

    test('GameState can store Wisdom', () {
      final state = GameState.initial();
      final updated = state.copyWith(
        resources: {
          ResourceType.cats: 0,
          ResourceType.offerings: 0,
          ResourceType.prayers: 0,
          ResourceType.wisdom: 100,
        },
      );
      expect(updated.resources[ResourceType.wisdom], 100);
    });

    test('Wisdom serializes correctly in toJson', () {
      final state = GameState.initial().copyWith(
        resources: {
          ResourceType.cats: 50,
          ResourceType.wisdom: 123.5,
        },
      );
      final json = state.toJson();
      expect(json['resources']['wisdom'], 123.5);
    });

    test('Wisdom deserializes correctly from JSON', () {
      final json = <String, dynamic>{
        'resources': {'cats': 0, 'offerings': 0, 'prayers': 0, 'wisdom': 250.0},
        'buildings': <String, dynamic>{},
        'unlockedGods': ['hermes'],
        'lastUpdate': DateTime.now().toIso8601String(),
        'totalCatsEarned': 0,
        'unlockedAchievements': [],
        'completedResearch': [],
        'conqueredTerritories': [],
      };

      final state = GameState.fromJson(json);
      expect(state.resources[ResourceType.wisdom], 250.0);
    });

    // Task 7: Add Prophecy State to GameState tests
    test('GameState initializes with empty prophecy state', () {
      final state = GameState.initial();
      expect(state.prophecyState, isNotNull);
      expect(state.prophecyState.cooldowns, isEmpty);
    });

    test('GameState can activate prophecy', () {
      final state = GameState.initial().copyWith(
        resources: {ResourceType.wisdom: 100},
      );

      final now = DateTime.now();
      final updated = state.activateProphecy(ProphecyType.solarBlessing, now);

      expect(updated.resources[ResourceType.wisdom], 0); // 100 - 100 = 0
      expect(updated.prophecyState.isOnCooldown(ProphecyType.solarBlessing), true);
    });

    test('Cannot activate prophecy with insufficient Wisdom', () {
      final state = GameState.initial().copyWith(
        resources: {ResourceType.wisdom: 50},
      );

      expect(
        () => state.activateProphecy(ProphecyType.solarBlessing, DateTime.now()),
        throwsA(isA<InsufficientResourcesException>()),
      );
    });

    test('Cannot activate prophecy on cooldown', () {
      final now = DateTime.now();
      final state = GameState.initial()
          .copyWith(resources: {ResourceType.wisdom: 200})
          .activateProphecy(ProphecyType.solarBlessing, now);

      expect(
        () => state.activateProphecy(ProphecyType.solarBlessing, now),
        throwsA(isA<ProphecyOnCooldownException>()),
      );
    });

    // Task 1: Add Random Event Fields to GameState tests
    test('GameState has random event fields with correct defaults', () {
      final state = GameState.initial();

      expect(state.activeRandomEvent, isNull);
      expect(state.randomEventEndTime, isNull);
      expect(state.lastRandomEventSpawnTime, isNotNull);
      expect(state.lastRandomEventSpawnTime!.year, 2000);
    });

    test('GameState.hasActiveRandomEvent returns correct values', () {
      final stateWithoutEvent = GameState.initial();
      expect(stateWithoutEvent.hasActiveRandomEvent, false);

      final stateWithEvent = GameState.initial().copyWith(
        activeRandomEvent: RandomEventDefinitions.divineCatAppears,
      );
      expect(stateWithEvent.hasActiveRandomEvent, true);
    });

    test('GameState.hasActiveRandomEventMultiplier checks type and expiration', () {
      // No active event
      final stateNoEvent = GameState.initial();
      expect(stateNoEvent.hasActiveRandomEventMultiplier, false);

      // Bonus event (not multiplier type)
      final stateBonusEvent = GameState.initial().copyWith(
        activeRandomEvent: RandomEventDefinitions.divineCatAppears,
        randomEventEndTime: DateTime.now().add(Duration(seconds: 30)),
      );
      expect(stateBonusEvent.hasActiveRandomEventMultiplier, false);

      // Multiplier event (not expired)
      final stateActiveMultiplier = GameState.initial().copyWith(
        activeRandomEvent: RandomEventDefinitions.divineFavor,
        randomEventEndTime: DateTime.now().add(Duration(seconds: 30)),
      );
      expect(stateActiveMultiplier.hasActiveRandomEventMultiplier, true);

      // Multiplier event (expired)
      final stateExpiredMultiplier = GameState.initial().copyWith(
        activeRandomEvent: RandomEventDefinitions.divineFavor,
        randomEventEndTime: DateTime.now().subtract(Duration(seconds: 1)),
      );
      expect(stateExpiredMultiplier.hasActiveRandomEventMultiplier, false);
    });
  });
}
