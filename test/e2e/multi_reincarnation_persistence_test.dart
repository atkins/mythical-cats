import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/providers/research_provider.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-Reincarnation Persistence Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('achievements persist across multiple reincarnations', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // Unlock some achievements
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 100,
        unlockedAchievements: {'cats_100'},
      );

      expect(gameNotifier.state.hasUnlockedAchievement('cats_100'), true);

      // First reincarnation
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 1000000000);
      gameNotifier.reincarnate(PrimordialForce.chaos);

      expect(gameNotifier.state.hasUnlockedAchievement('cats_100'), true);

      // Unlock more achievements
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 1000,
        unlockedAchievements: {'cats_100', 'cats_1k'},
      );

      // Second reincarnation
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 2000000000);
      gameNotifier.reincarnate(PrimordialForce.gaia);

      // All achievements should persist
      expect(gameNotifier.state.hasUnlockedAchievement('cats_100'), true);
      expect(gameNotifier.state.hasUnlockedAchievement('cats_1k'), true);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 2);
    });

    test('research persists across multiple reincarnations', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final researchNotifier = container.read(researchProvider);

      // Complete some research
      gameNotifier.state = gameNotifier.state.copyWith(
        resources: {
          ResourceType.cats: 1000000,
          ResourceType.prayers: 100000,
        },
      );

      researchNotifier.unlockResearch(ResearchDefinitions.divineArchitecture1);
      researchNotifier.unlockResearch(ResearchDefinitions.sacredGeometry);

      expect(gameNotifier.state.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameNotifier.state.hasCompletedResearch('sacred_geometry'), true);

      // First reincarnation
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 1000000000);
      gameNotifier.reincarnate(PrimordialForce.chaos);

      expect(gameNotifier.state.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameNotifier.state.hasCompletedResearch('sacred_geometry'), true);

      // Complete more research
      gameNotifier.state = gameNotifier.state.copyWith(
        resources: {
          ResourceType.cats: 1000000,
          ResourceType.prayers: 100000,
        },
      );
      researchNotifier.unlockResearch(ResearchDefinitions.divineArchitecture2);

      // Second reincarnation
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 2000000000);
      gameNotifier.reincarnate(PrimordialForce.gaia);

      // All research should persist
      expect(gameNotifier.state.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameNotifier.state.hasCompletedResearch('sacred_geometry'), true);
      expect(gameNotifier.state.hasCompletedResearch('divine_architecture_2'), true);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 2);
    });

    test('primordial upgrades persist and accumulate across reincarnations', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // First reincarnation - buy some upgrades
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 1000000000);
      gameNotifier.reincarnate(PrimordialForce.chaos);

      gameNotifier.state = gameNotifier.state.copyWith(
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          ownedUpgradeIds: {'chaos_1', 'chaos_2'},
        ),
      );

      expect(gameNotifier.state.reincarnationState.ownedUpgradeIds.length, 2);

      // Second reincarnation - buy more upgrades
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 4000000000);
      gameNotifier.reincarnate(PrimordialForce.gaia);

      gameNotifier.state = gameNotifier.state.copyWith(
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          ownedUpgradeIds: {'chaos_1', 'chaos_2', 'gaia_1', 'gaia_2'},
        ),
      );

      expect(gameNotifier.state.reincarnationState.ownedUpgradeIds.length, 4);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 2);

      // Third reincarnation - add even more
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 9000000000);
      gameNotifier.reincarnate(PrimordialForce.nyx);

      gameNotifier.state = gameNotifier.state.copyWith(
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          ownedUpgradeIds: {
            'chaos_1',
            'chaos_2',
            'gaia_1',
            'gaia_2',
            'nyx_1',
            'nyx_2',
          },
        ),
      );

      // All upgrades should persist
      expect(gameNotifier.state.reincarnationState.ownedUpgradeIds.length, 6);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 3);
      expect(gameNotifier.state.reincarnationState.ownedUpgradeIds.contains('chaos_1'), true);
      expect(gameNotifier.state.reincarnationState.ownedUpgradeIds.contains('gaia_1'), true);
      expect(gameNotifier.state.reincarnationState.ownedUpgradeIds.contains('nyx_1'), true);
    });

    test('primordial essence accumulates correctly over multiple reincarnations', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // First reincarnation at 1B cats
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 1000000000);
      gameNotifier.reincarnate(PrimordialForce.chaos);

      final firstPE = gameNotifier.state.reincarnationState.totalPrimordialEssence;
      expect(firstPE, greaterThan(0));
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 1);

      // Second reincarnation at 4B cats
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 4000000000,
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          lifetimeCatsEarned: 4000000000,
        ),
      );
      gameNotifier.reincarnate(PrimordialForce.gaia);

      final secondPE = gameNotifier.state.reincarnationState.totalPrimordialEssence;
      expect(secondPE, greaterThan(firstPE));
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 2);

      // Third reincarnation at 9B cats
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 9000000000,
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          lifetimeCatsEarned: 9000000000,
        ),
      );
      gameNotifier.reincarnate(PrimordialForce.nyx);

      final thirdPE = gameNotifier.state.reincarnationState.totalPrimordialEssence;
      expect(thirdPE, greaterThan(secondPE));
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 3);

      // PE should keep growing
      expect(thirdPE, greaterThan(firstPE * 2));
    });

    test('resources and buildings reset but bonuses persist', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final researchNotifier = container.read(researchProvider);

      // Build up resources and buildings
      gameNotifier.state = gameNotifier.state.copyWith(
        buildings: {
          BuildingType.smallShrine: 100,
          BuildingType.temple: 50,
          BuildingType.hallOfWisdom: 25,
        },
        resources: {
          ResourceType.cats: 1000000,
          ResourceType.offerings: 500000,
          ResourceType.wisdom: 10000,
        },
      );

      // Complete research
      gameNotifier.state = gameNotifier.state.copyWith(
        resources: {
          ResourceType.cats: 10000000,
          ResourceType.prayers: 1000000,
        },
      );
      researchNotifier.unlockResearch(ResearchDefinitions.divineArchitecture1);

      // Reincarnate
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 1000000000);
      gameNotifier.reincarnate(PrimordialForce.chaos);

      // Buildings should be reset
      expect(gameNotifier.state.getBuildingCount(BuildingType.smallShrine), 0);
      expect(gameNotifier.state.getBuildingCount(BuildingType.temple), 0);

      // Current resources should be reset
      expect(gameNotifier.state.getResource(ResourceType.cats), 0);
      expect(gameNotifier.state.getResource(ResourceType.offerings), 0);

      // Research should persist
      expect(gameNotifier.state.hasCompletedResearch('divine_architecture_1'), true);

      // Can use primordial bonuses for faster rebuild
      expect(gameNotifier.state.reincarnationState.totalPrimordialEssence, greaterThan(0));
    });

    test('conquered territories reset but can be reconquered', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final conquestNotifier = container.read(conquestProvider);

      // Conquer territories
      gameNotifier.state = gameNotifier.state.copyWith(
        resources: {ResourceType.conquestPoints: 100000},
      );

      conquestNotifier.conquerTerritory(ConquestDefinitions.northernWilds);
      conquestNotifier.conquerTerritory(ConquestDefinitions.easternMountains);

      expect(gameNotifier.state.conqueredTerritories.length, 2);

      // Reincarnate
      gameNotifier.state = gameNotifier.state.copyWith(totalCatsEarned: 1000000000);
      gameNotifier.reincarnate(PrimordialForce.chaos);

      // Territories should be reset
      expect(gameNotifier.state.conqueredTerritories.isEmpty, true);

      // Can reconquer them
      gameNotifier.state = gameNotifier.state.copyWith(
        resources: {ResourceType.conquestPoints: 100000},
      );
      conquestNotifier.conquerTerritory(ConquestDefinitions.northernWilds);

      expect(gameNotifier.state.hasConqueredTerritory('northern_wilds'), true);
    });

    test('complete multi-reincarnation cycle with all systems', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final researchNotifier = container.read(researchProvider);
      final conquestNotifier = container.read(conquestProvider);

      // Reincarnation 1: Chaos focus
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedAchievements: {'cats_100', 'cats_1k'},
        resources: {
          ResourceType.cats: 1000000,
          ResourceType.prayers: 100000,
        },
      );
      researchNotifier.unlockResearch(ResearchDefinitions.divineArchitecture1);

      gameNotifier.reincarnate(PrimordialForce.chaos);

      expect(gameNotifier.state.reincarnationState.activePatron, PrimordialForce.chaos);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 1);

      // Reincarnation 2: Gaia focus
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 3000000000,
        unlockedAchievements: {'cats_100', 'cats_1k', 'cats_10k'},
        resources: {
          ResourceType.cats: 1000000,
          ResourceType.prayers: 100000,
          ResourceType.conquestPoints: 10000,
        },
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          lifetimeCatsEarned: 3000000000,
        ),
      );
      researchNotifier.unlockResearch(ResearchDefinitions.sacredGeometry);
      conquestNotifier.conquerTerritory(ConquestDefinitions.northernWilds);

      gameNotifier.reincarnate(PrimordialForce.gaia);

      expect(gameNotifier.state.reincarnationState.activePatron, PrimordialForce.gaia);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 2);

      // Reincarnation 3: Nyx focus
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 6000000000,
        unlockedGods: {God.hermes, God.hestia, God.athena},
        reincarnationState: gameNotifier.state.reincarnationState.copyWith(
          lifetimeCatsEarned: 6000000000,
        ),
      );

      gameNotifier.reincarnate(PrimordialForce.nyx);

      expect(gameNotifier.state.reincarnationState.activePatron, PrimordialForce.nyx);
      expect(gameNotifier.state.reincarnationState.totalReincarnations, 3);

      // Verify persistence
      expect(gameNotifier.state.hasUnlockedAchievement('cats_100'), true);
      expect(gameNotifier.state.hasUnlockedAchievement('cats_1k'), true);
      expect(gameNotifier.state.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameNotifier.state.hasCompletedResearch('sacred_geometry'), true);
      expect(gameNotifier.state.reincarnationState.totalPrimordialEssence, greaterThan(50));

      // Temporary state reset
      expect(gameNotifier.state.conqueredTerritories.isEmpty, true);
      expect(gameNotifier.state.getResource(ResourceType.cats), 0);
    });

    test('lifetime stats accumulate correctly across reincarnations', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set initial lifetime stats
      gameNotifier.state = gameNotifier.state.copyWith(
        lifetimeWisdom: 1000,
        lifetimePropheciesActivated: 10,
        totalCatsEarned: 1000000000,
      );

      gameNotifier.reincarnate(PrimordialForce.chaos);

      // Lifetime stats should persist
      expect(gameNotifier.state.lifetimeWisdom, 1000);
      expect(gameNotifier.state.lifetimePropheciesActivated, 10);

      // Add more lifetime stats
      gameNotifier.state = gameNotifier.state.copyWith(
        lifetimeWisdom: 2500,
        lifetimePropheciesActivated: 25,
        totalCatsEarned: 3000000000,
      );

      gameNotifier.reincarnate(PrimordialForce.gaia);

      // Should still be accumulated
      expect(gameNotifier.state.lifetimeWisdom, 2500);
      expect(gameNotifier.state.lifetimePropheciesActivated, 25);
      // lifetimeCatsEarned should be 1B (from first run) + 3B (from second run) = 4B
      expect(gameNotifier.state.reincarnationState.lifetimeCatsEarned, 4000000000);
    });
  });
}
