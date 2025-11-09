import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';

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
  });
}
