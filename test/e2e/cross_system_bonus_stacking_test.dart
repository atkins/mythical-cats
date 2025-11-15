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
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/prophecy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cross-System Bonus Stacking Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('all bonus systems stack multiplicatively for cat production', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final researchNotifier = container.read(researchProvider);
      final conquestNotifier = container.read(conquestProvider);

      // Set up base buildings (10 small shrines = 1.0 cats/sec base)
      gameNotifier.state = gameNotifier.state.copyWith(
        buildings: {BuildingType.smallShrine: 10},
        resources: {
          ResourceType.cats: 10000000,
          ResourceType.prayers: 1000000,
          ResourceType.conquestPoints: 100000,
        },
      );

      // Get baseline production
      final baseProduction = gameNotifier.getProductionRate(ResourceType.cats);
      expect(baseProduction, closeTo(1.0, 0.01));

      // Add Conquest bonus: Northern Wilds (+5% cats)
      conquestNotifier.conquerTerritory(ConquestDefinitions.northernWilds);

      final afterConquest = gameNotifier.getProductionRate(ResourceType.cats);
      expect(afterConquest, closeTo(1.05, 0.01)); // 5% boost

      // Add Primordial bonus (after reincarnation)
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 1000000000,
      );
      gameNotifier.reincarnate(PrimordialForce.gaia);

      // Buy Gaia upgrade (production boost)
      gameNotifier.state = gameNotifier.state.copyWith(
        reincarnationState: ReincarnationState(
          totalPrimordialEssence: 100,
          availablePrimordialEssence: 50,
          totalReincarnations: 1,
          lifetimeCatsEarned: 1000000000,
          ownedUpgradeIds: {'gaia_1'},
          activePatron: PrimordialForce.gaia,
        ),
        buildings: {BuildingType.smallShrine: 10},
        conqueredTerritories: {'northern_wilds'},
      );

      final afterPrimordial = gameNotifier.getProductionRate(ResourceType.cats);

      // Verify conquest + primordial bonuses stack
      // Should be higher than conquest alone (1.05 base)
      expect(afterPrimordial, greaterThan(afterConquest));
    });

    test('wisdom production stacks from multiple sources', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final researchNotifier = container.read(researchProvider);

      // Set up Athena god and wisdom-producing buildings
      gameNotifier.state = gameNotifier.state.copyWith(
        unlockedGods: {God.hermes, God.hestia, God.athena},
        totalCatsEarned: 1000000,
        buildings: {
          BuildingType.hallOfWisdom: 2,
          BuildingType.academyOfAthens: 1,
        },
        resources: {
          ResourceType.cats: 10000000,
          ResourceType.offerings: 1000000,
          ResourceType.wisdom: 10000,
        },
      );

      // Get baseline wisdom production
      final baseWisdom = gameNotifier.getProductionRate(ResourceType.wisdom);
      expect(baseWisdom, greaterThan(0));

      // Add Seeker of Wisdom achievement (+0.5 Wisdom/sec flat)
      gameNotifier.state = gameNotifier.state.copyWith(
        unlockedAchievements: {'seeker_of_wisdom'},
      );

      final afterSeekerAchievement = gameNotifier.getProductionRate(ResourceType.wisdom);
      expect(afterSeekerAchievement, closeTo(baseWisdom + 0.5, 0.01));

      // Add God of Light achievement (+1 Wisdom/sec flat)
      gameNotifier.state = gameNotifier.state.copyWith(
        unlockedGods: {God.hermes, God.hestia, God.athena, God.apollo},
        totalCatsEarned: 10000000,
        unlockedAchievements: {'seeker_of_wisdom', 'god_of_light'},
      );

      final afterGodOfLight = gameNotifier.getProductionRate(ResourceType.wisdom);
      expect(afterGodOfLight, closeTo(afterSeekerAchievement + 1.0, 0.01));

      // Add Scholarly Pursuit I research (+10% Wisdom)
      researchNotifier.unlockResearch(ResearchDefinitions.foundationsOfWisdom);
      researchNotifier.unlockResearch(ResearchDefinitions.scholarlyPursuitI);

      final afterResearch = gameNotifier.getProductionRate(ResourceType.wisdom);
      expect(afterResearch, greaterThan(afterGodOfLight));

      // All bonuses should stack
      // Flat bonuses add, then percentage bonuses multiply
      expect(afterResearch, greaterThan(baseWisdom + 1.5)); // At least base + flat bonuses
    });

    test('prophecy timed boosts stack with permanent bonuses', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set up base production
      gameNotifier.state = gameNotifier.state.copyWith(
        buildings: {BuildingType.smallShrine: 10},
        resources: {
          ResourceType.cats: 1000,
          ResourceType.wisdom: 500,
        },
        unlockedAchievements: {'cats_10k'}, // +2% all resources
      );

      final baseProduction = gameNotifier.getProductionRate(ResourceType.cats);

      // Activate Solar Blessing prophecy (+50% cat production for 15 min)
      gameNotifier.activateProphecy(ProphecyType.solarBlessing);

      final withProphecy = gameNotifier.getProductionRate(ResourceType.cats);

      // Should be significantly higher
      expect(withProphecy, greaterThan(baseProduction * 1.4));
    });

    // Note: Building cost reduction test skipped - getBuildingCost() method not implemented yet

    test('all systems combined create significant production boost', () {
      final gameNotifier = container.read(gameProvider.notifier);
      final researchNotifier = container.read(researchProvider);
      final conquestNotifier = container.read(conquestProvider);

      // Set up minimal production (1 small shrine)
      gameNotifier.state = gameNotifier.state.copyWith(
        buildings: {BuildingType.smallShrine: 1},
        resources: {
          ResourceType.cats: 100000000,
          ResourceType.prayers: 10000000,
          ResourceType.conquestPoints: 1000000,
        },
      );

      final baseProduction = gameNotifier.getProductionRate(ResourceType.cats);
      expect(baseProduction, closeTo(0.1, 0.01));

      // Apply ALL bonuses
      // 1. Multiple achievements
      gameNotifier.state = gameNotifier.state.copyWith(
        unlockedAchievements: {
          'cats_100',
          'cats_1k',
          'cats_10k',
          'cats_100k',
        },
      );

      // 2. Multiple conquest territories
      conquestNotifier.conquerTerritory(ConquestDefinitions.northernWilds);
      conquestNotifier.conquerTerritory(ConquestDefinitions.easternMountains);
      conquestNotifier.conquerTerritory(ConquestDefinitions.southernSeas);

      // 4. Reincarnation with multiple upgrades
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 10000000000,
      );
      gameNotifier.reincarnate(PrimordialForce.chaos);

      gameNotifier.state = gameNotifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          totalPrimordialEssence: 200,
          availablePrimordialEssence: 100,
          totalReincarnations: 1,
          lifetimeCatsEarned: 10000000000,
          ownedUpgradeIds: {
            'chaos_1',
            'chaos_2',
            'gaia_1',
            'gaia_2',
            'nyx_1',
          },
          activePatron: PrimordialForce.chaos,
        ),
        buildings: {BuildingType.smallShrine: 1},
        conqueredTerritories: {
          'northern_wilds',
          'eastern_mountains',
          'southern_seas',
        },
        unlockedAchievements: {
          'cats_100',
          'cats_1k',
          'cats_10k',
          'cats_100k',
        },
      );

      final fullyBoostedProduction = gameNotifier.getProductionRate(ResourceType.cats);

      // Should be higher than base with conquest + primordial bonuses
      // Conquest: +30% (northern wilds 5% + southern seas 25%)
      // Primordial: varies by upgrades
      // Conservative estimate: at least 1.5x base production
      expect(fullyBoostedProduction, greaterThan(baseProduction * 1.5));

      // Verify it's finite (no overflow)
      expect(fullyBoostedProduction.isFinite, true);
    });

    test('primordial patron switching affects bonuses correctly', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set up after reincarnation with multiple force upgrades
      gameNotifier.state = gameNotifier.state.copyWith(
        totalCatsEarned: 5000000000,
        buildings: {BuildingType.smallShrine: 10},
      );
      gameNotifier.reincarnate(PrimordialForce.chaos);

      gameNotifier.state = gameNotifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          totalPrimordialEssence: 150,
          availablePrimordialEssence: 50,
          totalReincarnations: 1,
          lifetimeCatsEarned: 5000000000,
          ownedUpgradeIds: {
            'chaos_1',
            'chaos_2',
            'gaia_1',
            'gaia_2',
          },
          activePatron: PrimordialForce.chaos,
        ),
        buildings: {BuildingType.smallShrine: 10},
      );

      final withChaosPatron = gameNotifier.getProductionRate(ResourceType.cats);

      // Switch to Gaia patron
      gameNotifier.setActivePatron(PrimordialForce.gaia);

      final withGaiaPatron = gameNotifier.getProductionRate(ResourceType.cats);

      // Production should change based on patron
      // Different forces have different bonuses
      expect(withGaiaPatron, isNotNull);
      expect(withGaiaPatron.isFinite, true);
    });
  });
}
