import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    GameNotifier getNotifier() => container.read(gameProvider.notifier);

    test('initial state has Hermes unlocked', () {
      final notifier = getNotifier();
      expect(notifier.state.hasUnlockedGod(God.hermes), true);
      expect(notifier.state.getResource(ResourceType.cats), 0);
    });

    test('performRitual adds 1 cat', () {
      final notifier = getNotifier();
      notifier.performRitual();
      expect(notifier.state.getResource(ResourceType.cats), 1);
      expect(notifier.state.totalCatsEarned, 1);
    });

    test('buyBuilding succeeds when affordable', () {
      final notifier = getNotifier();
      // Give enough cats to buy a small shrine (costs 15)
      notifier.performRitual();
      for (int i = 0; i < 14; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.getResource(ResourceType.cats), 15);

      final success = notifier.buyBuilding(BuildingType.smallShrine);
      expect(success, true);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 1);
      expect(notifier.state.getResource(ResourceType.cats), 0);
    });

    test('buyBuilding fails when not affordable', () {
      final notifier = getNotifier();
      final success = notifier.buyBuilding(BuildingType.smallShrine);
      expect(success, false);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 0);
    });

    test('buyBuilding can buy multiple at once', () {
      final notifier = getNotifier();
      // Give enough cats
      for (int i = 0; i < 50; i++) {
        notifier.performRitual();
      }

      final success = notifier.buyBuilding(BuildingType.smallShrine, amount: 2);
      expect(success, true);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 2);
    });

    test('catsPerSecond calculates correctly', () {
      final notifier = getNotifier();
      // Manually set a building to check calculation
      final newBuildings = {BuildingType.smallShrine: 10};
      notifier.state = notifier.state.copyWith(buildings: newBuildings);

      // Small shrine produces 0.1 cats/sec, 10 of them = 1.0 cats/sec
      expect(notifier.catsPerSecond, 1.0);
    });

    test('god unlocks when requirement met', () {
      final notifier = getNotifier();
      expect(notifier.state.hasUnlockedGod(God.hestia), false);

      // Set total cats earned to unlock Hestia (requires 1000)
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000,
        resources: {ResourceType.cats: 1000},
      );
      notifier.performRitual(); // Trigger unlock check

      expect(notifier.state.hasUnlockedGod(God.hestia), true);
    });

    test('buildings produce prayers correctly', () {
      final notifier = getNotifier();
      // Give resources to buy harvest field
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 10000,
          ResourceType.offerings: 1000,
        },
        unlockedGods: {God.hermes, God.hestia, God.demeter},
        lastUpdate: DateTime.now().subtract(const Duration(seconds: 100)),
      );

      // Buy harvest field (produces prayers at 1.0 per second)
      notifier.buyBuilding(BuildingType.harvestField);

      expect(notifier.state.getBuildingCount(BuildingType.harvestField), 1);
      expect(notifier.state.getResource(ResourceType.prayers), 0.0);

      // Trigger automatic production by simulating 100 seconds of offline time
      notifier.applyOfflineProgress();

      // Should have produced 100 prayers (1.0 per second * 100 seconds)
      expect(notifier.state.getResource(ResourceType.prayers), 100.0);
    });

    test('achievements unlock at correct milestones', () {
      final notifier = getNotifier();
      // Click to 100 cats
      for (int i = 0; i < 100; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.hasUnlockedAchievement('cats_100'), true);
      expect(notifier.state.hasUnlockedAchievement('cats_1k'), false);

      // Click to 1000 total
      for (int i = 0; i < 900; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.hasUnlockedAchievement('cats_1k'), true);
    });

    test('building achievement unlocks correctly', () {
      final notifier = getNotifier();
      // Give cats to buy buildings
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.cats: 10000},
      );

      // Buy 10 small shrines
      for (int i = 0; i < 10; i++) {
        notifier.buyBuilding(BuildingType.smallShrine);
      }

      expect(notifier.state.hasUnlockedAchievement('buildings_10'), true);
    });

    test('production calculation includes conquest bonuses', () {
      final notifier = getNotifier();

      // Set up initial resources and buildings
      notifier.addResource(ResourceType.cats, 1000);
      notifier.buyBuilding(BuildingType.smallShrine, amount: 1);

      // Base production: 0.1 cats/sec
      final baseProduction = notifier.getProductionRate(ResourceType.cats);
      expect(baseProduction, closeTo(0.1, 0.01));

      // Conquer territory with +5% cats
      notifier.addResource(ResourceType.conquestPoints, 150);
      final conquest = container.read(conquestProvider);
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      // Should now be 0.1 * 1.05 = 0.105
      final boostedProduction = notifier.getProductionRate(ResourceType.cats);
      expect(boostedProduction, closeTo(0.105, 0.01));
    });

    test('production calculation includes Divine Essence refinery', () {
      final notifier = getNotifier();

      notifier.addResource(ResourceType.cats, 200000);
      notifier.addResource(ResourceType.offerings, 20000);
      notifier.buyBuilding(BuildingType.essenceRefinery, amount: 1);

      final production = notifier.getProductionRate(ResourceType.divineEssence);
      expect(production, closeTo(0.5, 0.01));
    });

    test('convertInWorkshop exchanges offerings for divine essence', () {
      final notifier = getNotifier();

      notifier.addResource(ResourceType.offerings, 1000);
      notifier.addResource(ResourceType.cats, 500000);
      notifier.addResource(ResourceType.divineEssence, 200);
      notifier.buyBuilding(BuildingType.workshop, amount: 1);

      final success = notifier.convertInWorkshop(100);

      expect(success, true);

      final state = container.read(gameProvider);
      expect(state.getResource(ResourceType.offerings), 900);
      expect(state.getResource(ResourceType.divineEssence), 110); // 200 - 100 (workshop cost) + 10 (100/10)
    });

    test('convertInWorkshop fails without workshop', () {
      final notifier = getNotifier();

      notifier.addResource(ResourceType.offerings, 1000);

      final success = notifier.convertInWorkshop(100);

      expect(success, false);
    });

    test('convertInWorkshop fails with insufficient offerings', () {
      final notifier = getNotifier();

      notifier.addResource(ResourceType.offerings, 50);
      notifier.addResource(ResourceType.cats, 500000);
      notifier.addResource(ResourceType.divineEssence, 200);
      notifier.buyBuilding(BuildingType.workshop, amount: 1);

      final success = notifier.convertInWorkshop(100);

      expect(success, false);
    });

    test('convertInWorkshop uses improved ratio with divine alchemy research', () {
      final notifier = getNotifier();

      notifier.addResource(ResourceType.offerings, 1000);
      notifier.addResource(ResourceType.cats, 500000);
      notifier.addResource(ResourceType.divineEssence, 200);
      notifier.buyBuilding(BuildingType.workshop, amount: 1);

      // Add Divine Alchemy research
      final currentState = container.read(gameProvider);
      final newCompleted = Set<String>.from(currentState.completedResearch)
        ..add('divine_alchemy');
      notifier.updateState(currentState.copyWith(
        completedResearch: newCompleted,
      ));

      final success = notifier.convertInWorkshop(80);

      expect(success, true);

      final state = container.read(gameProvider);
      expect(state.getResource(ResourceType.offerings), 920); // 1000 - 80
      expect(state.getResource(ResourceType.divineEssence), 110); // 200 - 100 (workshop cost) + 10 (80/8)
    });
  });

  group('GameNotifier Primordial Essence', () {
    test('calculatePrimordialEssence returns 0 below threshold', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      expect(notifier.calculatePrimordialEssence(999999999), 0);
      expect(notifier.calculatePrimordialEssence(500000000), 0);
    });

    test('calculatePrimordialEssence returns correct base values', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      expect(notifier.calculatePrimordialEssence(1000000000), 20); // 1B
      expect(notifier.calculatePrimordialEssence(10000000000), 30); // 10B
      expect(notifier.calculatePrimordialEssence(100000000000), 40); // 100B
      expect(notifier.calculatePrimordialEssence(1000000000000), 50); // 1T
    });

    test('calculatePrimordialEssence applies tier 5 bonuses', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Buy all 4 tier 5 upgrades (+40% PE total)
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_5', 'gaia_5', 'nyx_5', 'erebus_5'},
        ),
      );

      // 1B cats = 20 base PE * 1.4 = 28 PE
      expect(notifier.calculatePrimordialEssence(1000000000), 28);
    });

    test('calculatePrimordialEssence with partial tier 5 bonuses', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Buy 2 tier 5 upgrades (+20% PE)
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_5', 'gaia_5'},
        ),
      );

      // 1B cats = 20 base PE * 1.2 = 24 PE
      expect(notifier.calculatePrimordialEssence(1000000000), 24);
    });
  });

  group('GameNotifier Bonus Calculations', () {
    test('getClickPowerMultiplier with no upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      expect(notifier.getClickPowerMultiplier(), 1.0);
    });

    test('getClickPowerMultiplier with Chaos upgrades only', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_1', 'chaos_2', 'chaos_3'},
        ),
      );

      // 10% + 25% + 50% = 85% = 1.85x
      expect(notifier.getClickPowerMultiplier(), closeTo(1.85, 0.01));
    });

    test('getClickPowerMultiplier with Chaos patron bonus', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_1', 'chaos_2', 'chaos_3'},
          activePatron: PrimordialForce.chaos,
        ),
      );

      // Permanent: 85%, Patron: 50% + 30% (3 tiers) = 80%
      // Total: 1.85 + 0.8 = 2.65x
      expect(notifier.getClickPowerMultiplier(), closeTo(2.65, 0.01));
    });

    test('getBuildingProductionMultiplier with Gaia upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_1', 'gaia_2'},
        ),
      );

      // 10% + 25% = 35% = 1.35x
      expect(notifier.getBuildingProductionMultiplier(), closeTo(1.35, 0.01));
    });

    test('getBuildingCostReduction with Gaia upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_3', 'gaia_4'},
        ),
      );

      // Gaia III: -10%, Gaia IV: -15% (total -15% because IV replaces III)
      expect(notifier.getBuildingCostReduction(), 0.15);
    });

    test('getOfflineProgressionMultiplier with Nyx upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'nyx_1', 'nyx_2', 'nyx_3'},
        ),
      );

      // 25% + 50% + 100% = 175% = 2.75x
      expect(notifier.getOfflineProgressionMultiplier(), closeTo(2.75, 0.01));
    });

    test('getOfflineCapHours with Nyx upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Default cap
      expect(notifier.getOfflineCapHours(), 24);

      // With Nyx III
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'nyx_3'},
        ),
      );
      expect(notifier.getOfflineCapHours(), 48);

      // With Nyx IV
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'nyx_4'},
        ),
      );
      expect(notifier.getOfflineCapHours(), 72);
    });

    test('getTier2ProductionMultiplier with Erebus upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'erebus_1', 'erebus_2'},
        ),
      );

      // 15% + 30% = 45% = 1.45x
      expect(notifier.getTier2ProductionMultiplier(), closeTo(1.45, 0.01));
    });
  });

  group('GameNotifier Production with Primordial Bonuses', () {
    test('performRitual uses Chaos click power multiplier', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_1'}, // +10% = 1.1x
        ),
      );

      notifier.performRitual();

      expect(notifier.state.getResource(ResourceType.cats), closeTo(1.1, 0.01));
    });

    test('performRitual uses Chaos patron bonus', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_1', 'chaos_2'}, // 2 tiers
          activePatron: PrimordialForce.chaos, // +50% + 20% = 70%
        ),
      );

      // Permanent: 10% + 25% = 35%
      // Patron: 70%
      // Total: 1.35 + 0.7 = 2.05x
      notifier.performRitual();
      expect(notifier.state.getResource(ResourceType.cats), closeTo(2.05, 0.01));
    });

    test('building production uses Gaia multiplier', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Give player a building and resources
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.cats: 1000},
        buildings: {},
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_1'}, // +10% building production
        ),
      );

      // Buy a small shrine (produces 0.1 cats/sec)
      notifier.buyBuilding(BuildingType.smallShrine);

      // Simulate 10 seconds of production
      // 0.1 * 10 * 1.1 (Gaia I) = 1.1 cats
      final initialCats = notifier.state.getResource(ResourceType.cats);
      notifier.testUpdateGame(10.0);
      final finalCats = notifier.state.getResource(ResourceType.cats);

      expect(finalCats - initialCats, closeTo(1.1, 0.1));
    });
  });

  group('GameNotifier Reincarnation', () {
    test('reincarnate resets resources to zero', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        resources: {
          ResourceType.cats: 50000000,
          ResourceType.offerings: 10000,
        },
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.getResource(ResourceType.cats), 0);
      expect(notifier.state.getResource(ResourceType.offerings), 0);
    });

    test('reincarnate resets buildings', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        buildings: {BuildingType.smallShrine: 10, BuildingType.temple: 5},
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 0);
      expect(notifier.state.getBuildingCount(BuildingType.temple), 0);
    });

    test('reincarnate resets gods to just Hermes', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedGods: {God.hermes, God.hestia, God.athena},
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.unlockedGods.length, 1);
      expect(notifier.state.unlockedGods.contains(God.hermes), true);
    });

    test('reincarnate preserves research', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        completedResearch: {'divine_architecture_1', 'essence_refinement'},
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.completedResearch.length, 2);
      expect(notifier.state.hasCompletedResearch('divine_architecture_1'), true);
    });

    test('reincarnate preserves achievements', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedAchievements: {'cats_100', 'cats_1k'},
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.unlockedAchievements.length, 2);
      expect(notifier.state.hasUnlockedAchievement('cats_100'), true);
    });

    test('reincarnate awards PE and sets patron', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.reincarnationState.totalPrimordialEssence, 20);
      expect(notifier.state.reincarnationState.availablePrimordialEssence, 20);
      expect(notifier.state.reincarnationState.activePatron, PrimordialForce.chaos);
    });

    test('reincarnate increments reincarnation count', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
      );

      notifier.reincarnate(PrimordialForce.chaos);
      expect(notifier.state.reincarnationState.totalReincarnations, 1);

      notifier.state = notifier.state.copyWith(totalCatsEarned: 5000000000);
      notifier.reincarnate(PrimordialForce.gaia);
      expect(notifier.state.reincarnationState.totalReincarnations, 2);
    });

    test('reincarnate accumulates lifetimeCatsEarned', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(totalCatsEarned: 2000000000);
      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.reincarnationState.lifetimeCatsEarned, 2000000000);

      notifier.state = notifier.state.copyWith(totalCatsEarned: 3000000000);
      notifier.reincarnate(PrimordialForce.gaia);

      expect(notifier.state.reincarnationState.lifetimeCatsEarned, 5000000000);
    });

    test('reincarnate preserves purchased upgrades', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_1', 'gaia_1'},
        ),
      );

      notifier.reincarnate(PrimordialForce.nyx);

      expect(notifier.state.reincarnationState.ownedUpgradeIds.contains('chaos_1'), true);
      expect(notifier.state.reincarnationState.ownedUpgradeIds.contains('gaia_1'), true);
    });

    test('reincarnate resets conquered territories', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        conqueredTerritories: {'northern_wilds', 'eastern_mountains'},
      );

      notifier.reincarnate(PrimordialForce.chaos);

      expect(notifier.state.conqueredTerritories.isEmpty, true);
    });

    test('canPurchasePrimordialUpgrade returns false when insufficient PE', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 5,
        ),
      );

      expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), false);
    });

    test('canPurchasePrimordialUpgrade returns true when affordable', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 20,
        ),
      );

      expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), true);
    });

    test('canPurchasePrimordialUpgrade returns false when missing prerequisite', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
        ),
      );

      // Can't buy tier 2 without tier 1
      expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), false);
    });

    test('canPurchasePrimordialUpgrade returns true with prerequisite met', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1'},
        ),
      );

      expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), true);
    });

    test('canPurchasePrimordialUpgrade returns false when already purchased', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1'},
        ),
      );

      expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), false);
    });

    test('purchasePrimordialUpgrade deducts PE and adds upgrade', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 20,
        ),
      );

      notifier.purchasePrimordialUpgrade('chaos_1');

      expect(notifier.state.reincarnationState.ownedUpgradeIds.contains('chaos_1'), true);
      expect(notifier.state.reincarnationState.availablePrimordialEssence, 10);
    });

    test('purchasePrimordialUpgrade fails when not affordable', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 5,
        ),
      );

      notifier.purchasePrimordialUpgrade('chaos_1');

      // Should not purchase
      expect(notifier.state.reincarnationState.ownedUpgradeIds.contains('chaos_1'), false);
      expect(notifier.state.reincarnationState.availablePrimordialEssence, 5);
    });
  });

  group('Patron Management', () {
    test('setActivePatron updates patron', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up state with some PE
      notifier.state = notifier.state.copyWith(
        reincarnationState: ReincarnationState(
          totalPrimordialEssence: 100,
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1'},
        ),
      );

      // Set patron
      notifier.setActivePatron(PrimordialForce.chaos);

      expect(
        notifier.state.reincarnationState.activePatron,
        PrimordialForce.chaos,
      );

      // Change patron
      notifier.setActivePatron(PrimordialForce.gaia);

      expect(
        notifier.state.reincarnationState.activePatron,
        PrimordialForce.gaia,
      );

      container.dispose();
    });

    test('setActivePatron can set patron to null', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      notifier.setActivePatron(null);

      expect(notifier.state.reincarnationState.activePatron, null);

      container.dispose();
    });
  });
}
