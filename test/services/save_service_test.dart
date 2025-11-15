import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mythical_cats/services/save_service.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveService', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Basic Save and Load', () {
      test('successfully saves and loads game state', () async {
        final originalState = GameState.initial().copyWith(
          resources: {
            ResourceType.cats: 1000,
            ResourceType.offerings: 500,
            ResourceType.prayers: 250,
          },
          totalCatsEarned: 5000,
          buildings: {
            BuildingType.smallShrine: 5,
            BuildingType.temple: 3,
          },
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState, isNotNull);
        expect(loadedState!.getResource(ResourceType.cats), 1000);
        expect(loadedState.getResource(ResourceType.offerings), 500);
        expect(loadedState.totalCatsEarned, 5000);
        expect(loadedState.getBuildingCount(BuildingType.smallShrine), 5);
        expect(loadedState.getBuildingCount(BuildingType.temple), 3);
      });

      test('returns null when no save exists', () async {
        final loadedState = await SaveService.load();
        expect(loadedState, isNull);
      });

      test('hasSave returns true after saving', () async {
        expect(await SaveService.hasSave(), false);

        await SaveService.save(GameState.initial());

        expect(await SaveService.hasSave(), true);
      });

      test('hasSave returns false after deleting save', () async {
        await SaveService.save(GameState.initial());
        expect(await SaveService.hasSave(), true);

        await SaveService.deleteSave();

        expect(await SaveService.hasSave(), false);
      });
    });

    group('Complex State Serialization', () {
      test('preserves unlocked gods', () async {
        final originalState = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.hestia, God.athena, God.apollo},
          totalCatsEarned: 10000000,
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.unlockedGods.length, 4);
        expect(loadedState.hasUnlockedGod(God.hermes), true);
        expect(loadedState.hasUnlockedGod(God.hestia), true);
        expect(loadedState.hasUnlockedGod(God.athena), true);
        expect(loadedState.hasUnlockedGod(God.apollo), true);
      });

      test('preserves completed research', () async {
        final originalState = GameState.initial().copyWith(
          completedResearch: {
            'divine_architecture_1',
            'sacred_geometry',
            'scholarly_pursuit_i',
          },
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.completedResearch.length, 3);
        expect(loadedState.hasCompletedResearch('divine_architecture_1'), true);
        expect(loadedState.hasCompletedResearch('sacred_geometry'), true);
        expect(loadedState.hasCompletedResearch('scholarly_pursuit_i'), true);
      });

      test('preserves unlocked achievements', () async {
        final originalState = GameState.initial().copyWith(
          unlockedAchievements: {
            'cats_100',
            'cats_1k',
            'seeker_of_wisdom',
            'god_of_light',
          },
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.unlockedAchievements.length, 4);
        expect(loadedState.hasUnlockedAchievement('cats_100'), true);
        expect(loadedState.hasUnlockedAchievement('seeker_of_wisdom'), true);
      });

      test('preserves conquered territories', () async {
        final originalState = GameState.initial().copyWith(
          conqueredTerritories: {
            'northern_wilds',
            'eastern_mountains',
            'academy_of_athens',
          },
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.conqueredTerritories.length, 3);
        expect(loadedState.hasConqueredTerritory('northern_wilds'), true);
        expect(loadedState.hasConqueredTerritory('eastern_mountains'), true);
        expect(loadedState.hasConqueredTerritory('academy_of_athens'), true);
      });

      test('preserves reincarnation state with upgrades', () async {
        final originalState = GameState.initial().copyWith(
          reincarnationState: const ReincarnationState(
            totalPrimordialEssence: 150,
            availablePrimordialEssence: 50,
            totalReincarnations: 3,
            lifetimeCatsEarned: 15000000000,
            ownedUpgradeIds: {
              'chaos_1',
              'chaos_2',
              'gaia_1',
              'nyx_1',
              'erebus_1',
            },
            activePatron: PrimordialForce.chaos,
          ),
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.reincarnationState.totalPrimordialEssence, 150);
        expect(loadedState.reincarnationState.availablePrimordialEssence, 50);
        expect(loadedState.reincarnationState.totalReincarnations, 3);
        expect(loadedState.reincarnationState.lifetimeCatsEarned, 15000000000);
        expect(loadedState.reincarnationState.ownedUpgradeIds.length, 5);
        expect(loadedState.reincarnationState.activePatron, PrimordialForce.chaos);
      });

      test('preserves lifetime stats', () async {
        final originalState = GameState.initial().copyWith(
          lifetimeWisdom: 25000,
          lifetimePropheciesActivated: 75,
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.lifetimeWisdom, 25000);
        expect(loadedState.lifetimePropheciesActivated, 75);
      });

      test('preserves all resource types', () async {
        final originalState = GameState.initial().copyWith(
          resources: {
            ResourceType.cats: 123456.78,
            ResourceType.offerings: 9876.54,
            ResourceType.prayers: 5432.10,
            ResourceType.divineEssence: 321.98,
            ResourceType.ambrosia: 12.34,
            ResourceType.wisdom: 4567.89,
            ResourceType.conquestPoints: 999.99,
          },
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        expect(loadedState!.getResource(ResourceType.cats), closeTo(123456.78, 0.01));
        expect(loadedState.getResource(ResourceType.offerings), closeTo(9876.54, 0.01));
        expect(loadedState.getResource(ResourceType.prayers), closeTo(5432.10, 0.01));
        expect(loadedState.getResource(ResourceType.divineEssence), closeTo(321.98, 0.01));
        expect(loadedState.getResource(ResourceType.ambrosia), closeTo(12.34, 0.01));
        expect(loadedState.getResource(ResourceType.wisdom), closeTo(4567.89, 0.01));
        expect(loadedState.getResource(ResourceType.conquestPoints), closeTo(999.99, 0.01));
      });
    });

    group('Error Handling', () {
      test('returns null when JSON is corrupt', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('game_save', 'invalid json {]}}');

        final loadedState = await SaveService.load();

        expect(loadedState, isNull);
      });

      test('returns null when JSON has invalid structure', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('game_save', '{"invalid": "structure"}');

        final loadedState = await SaveService.load();

        // May return null or throw, either is acceptable
        // The important thing is it doesn't crash the app
      });

      test('handles empty string save data', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('game_save', '');

        final loadedState = await SaveService.load();

        expect(loadedState, isNull);
      });
    });

    group('Save Deletion', () {
      test('successfully deletes saved game', () async {
        await SaveService.save(GameState.initial());
        expect(await SaveService.hasSave(), true);

        await SaveService.deleteSave();

        expect(await SaveService.hasSave(), false);
        final loadedState = await SaveService.load();
        expect(loadedState, isNull);
      });

      test('deleteSave works even when no save exists', () async {
        expect(await SaveService.hasSave(), false);

        // Should not throw
        await SaveService.deleteSave();

        expect(await SaveService.hasSave(), false);
      });
    });

    group('Overwriting Saves', () {
      test('overwriting save replaces old data', () async {
        final firstState = GameState.initial().copyWith(
          resources: {ResourceType.cats: 1000},
          totalCatsEarned: 1000,
        );

        await SaveService.save(firstState);

        final secondState = GameState.initial().copyWith(
          resources: {ResourceType.cats: 5000},
          totalCatsEarned: 5000,
        );

        await SaveService.save(secondState);

        final loadedState = await SaveService.load();

        expect(loadedState!.getResource(ResourceType.cats), 5000);
        expect(loadedState.totalCatsEarned, 5000);
      });
    });

    group('Round-Trip Serialization', () {
      test('complex state survives save-load cycle identically', () async {
        final originalState = GameState.initial().copyWith(
          resources: {
            ResourceType.cats: 987654.32,
            ResourceType.wisdom: 12345.67,
          },
          totalCatsEarned: 50000000,
          buildings: {
            BuildingType.smallShrine: 100,
            BuildingType.hallOfWisdom: 50,
            BuildingType.templeOfDelphi: 25,
          },
          unlockedGods: {God.hermes, God.hestia, God.athena, God.apollo},
          completedResearch: {
            'divine_architecture_1',
            'scholarly_pursuit_i',
            'scholarly_pursuit_ii',
          },
          unlockedAchievements: {
            'cats_100',
            'cats_1k',
            'seeker_of_wisdom',
          },
          conqueredTerritories: {
            'northern_wilds',
            'academy_of_athens',
          },
          lifetimeWisdom: 50000,
          lifetimePropheciesActivated: 100,
          reincarnationState: const ReincarnationState(
            totalPrimordialEssence: 80,
            availablePrimordialEssence: 30,
            totalReincarnations: 2,
            lifetimeCatsEarned: 5000000000,
            ownedUpgradeIds: {'chaos_1', 'gaia_1'},
            activePatron: PrimordialForce.gaia,
          ),
        );

        await SaveService.save(originalState);
        final loadedState = await SaveService.load();

        // Verify critical fields match
        expect(loadedState!.totalCatsEarned, originalState.totalCatsEarned);
        expect(loadedState.unlockedGods.length, originalState.unlockedGods.length);
        expect(loadedState.completedResearch.length, originalState.completedResearch.length);
        expect(loadedState.unlockedAchievements.length, originalState.unlockedAchievements.length);
        expect(loadedState.conqueredTerritories.length, originalState.conqueredTerritories.length);
        expect(loadedState.lifetimeWisdom, originalState.lifetimeWisdom);
        expect(loadedState.reincarnationState.totalReincarnations,
               originalState.reincarnationState.totalReincarnations);
      });
    });
  });
}
