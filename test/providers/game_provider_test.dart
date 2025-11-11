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
import 'package:mythical_cats/models/prophecy.dart';

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

  // Task 5: Wisdom generation tests
  group('Wisdom Production', () {
    test('Game loop generates Wisdom from Athena buildings', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 1, // 0.1 Wisdom/sec
        },
      );

      final initialWisdom = notifier.state.getResource(ResourceType.wisdom);
      notifier.testUpdateGame(10.0); // 10 seconds
      final finalWisdom = notifier.state.getResource(ResourceType.wisdom);

      expect(finalWisdom - initialWisdom, closeTo(1.0, 0.01)); // 0.1 * 10 = 1.0
    });

    test('Game loop generates Wisdom from Apollo buildings', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.templeOfDelphi: 1, // 2.0 Wisdom/sec
        },
      );

      final initialWisdom = notifier.state.getResource(ResourceType.wisdom);
      notifier.testUpdateGame(5.0); // 5 seconds
      final finalWisdom = notifier.state.getResource(ResourceType.wisdom);

      expect(finalWisdom - initialWisdom, closeTo(10.0, 0.01)); // 2.0 * 5 = 10.0
    });

    test('Wisdom accumulates over multiple ticks', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.academyOfAthens: 1, // 0.8 Wisdom/sec
        },
      );

      notifier.testUpdateGame(5.0); // +4.0 Wisdom
      expect(notifier.state.getResource(ResourceType.wisdom), closeTo(4.0, 0.01));

      notifier.testUpdateGame(5.0); // +4.0 Wisdom
      expect(notifier.state.getResource(ResourceType.wisdom), closeTo(8.0, 0.01));
    });

    test('Multiple Wisdom buildings produce correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // 10 * 0.1 = 1.0
          BuildingType.templeOfDelphi: 2, // 2 * 2.0 = 4.0
          // Total: 5.0 Wisdom/sec
        },
      );

      notifier.testUpdateGame(10.0);
      expect(notifier.state.getResource(ResourceType.wisdom), closeTo(50.0, 0.01));
    });

    test('Wisdom production applies tier 2 primordial bonuses', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // Base: 1.0 Wisdom/sec
        },
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_1', 'erebus_1'}, // +10% building, +15% tier2
        ),
      );

      // Base: 1.0, Building: 1.1x, Tier2: 1.15x = 1.0 * 1.1 * 1.15 = 1.265
      final production = notifier.getProductionRate(ResourceType.wisdom);
      expect(production, closeTo(1.265, 0.01));
    });
  });

  // Task 8: Timed Boost Application
  group('Prophecy Timed Boost Application', () {
    test('Solar Blessing applies +50% cat production', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 100},
        buildings: {BuildingType.smallShrine: 10}, // Base: 10 * 0.1 = 1.0 cats/sec
      );

      // Activate Solar Blessing
      notifier.state = notifier.state.activateProphecy(ProphecyType.solarBlessing, now);

      // Check production rate with boost
      final boostedRate = notifier.getProductionRate(ResourceType.cats);
      expect(boostedRate, closeTo(1.5, 0.01)); // 1.0 * 1.5 = 1.5
    });

    test('Solar Blessing boost expires after duration', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 100},
        buildings: {BuildingType.smallShrine: 10}, // Base: 1.0 cats/sec
      );

      // Activate Solar Blessing
      notifier.state = notifier.state.activateProphecy(ProphecyType.solarBlessing, now);

      // Production should be boosted
      expect(notifier.getProductionRate(ResourceType.cats), closeTo(1.5, 0.01));

      // After boost expires (15 min + 1 sec)
      final expired = now.add(Duration(minutes: 15, seconds: 1));
      notifier.state = notifier.state.updateProphecyEffects(expired);

      final normalRate = notifier.getProductionRate(ResourceType.cats);
      expect(normalRate, closeTo(1.0, 0.01)); // Back to normal
    });

    test('Prophecy of Abundance applies +100% to all resources', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 250},
        buildings: {
          BuildingType.smallShrine: 10, // 1.0 cats/sec
          BuildingType.hallOfWisdom: 10, // 1.0 wisdom/sec
        },
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

      expect(notifier.getProductionRate(ResourceType.cats), closeTo(2.0, 0.01)); // 1.0 * 2.0
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(2.0, 0.01)); // 1.0 * 2.0
    });

    test('Celestial Surge applies +200% cat production', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 750},
        buildings: {BuildingType.smallShrine: 10}, // Base: 1.0 cats/sec
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.celestialSurge, now);

      // Check production rate with boost
      final boostedRate = notifier.getProductionRate(ResourceType.cats);
      expect(boostedRate, closeTo(3.0, 0.01)); // 1.0 * 3.0 = 3.0
    });

    test('Celestial Surge only affects cats, not other resources', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 750},
        buildings: {
          BuildingType.smallShrine: 10, // 1.0 cats/sec
          BuildingType.hallOfWisdom: 10, // 1.0 wisdom/sec
        },
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.celestialSurge, now);

      expect(notifier.getProductionRate(ResourceType.cats), closeTo(3.0, 0.01));
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.0, 0.01)); // No boost
    });

    test('Apollo\'s Grand Vision applies +150% to all resources', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 2000},
        buildings: {
          BuildingType.smallShrine: 10, // 1.0 cats/sec
          BuildingType.hallOfWisdom: 10, // 1.0 wisdom/sec
        },
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.apollosGrandVision, now);

      expect(notifier.getProductionRate(ResourceType.cats), closeTo(2.5, 0.01)); // 1.0 * 2.5
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(2.5, 0.01)); // 1.0 * 2.5
    });

    test('Timed boost does not apply after expiry', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 250},
        buildings: {BuildingType.smallShrine: 10}, // 1.0 cats/sec
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

      // Verify boost is active
      expect(notifier.getProductionRate(ResourceType.cats), closeTo(2.0, 0.01));

      // Simulate expiration (30 minutes + 1 second)
      final expired = now.add(Duration(minutes: 30, seconds: 1));
      notifier.state = notifier.state.updateProphecyEffects(expired);

      // Should be back to normal
      expect(notifier.getProductionRate(ResourceType.cats), closeTo(1.0, 0.01));
    });

    test('updateProphecyEffects clears expired boosts', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 100},
        buildings: {BuildingType.smallShrine: 10},
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.solarBlessing, now);

      // Verify active boost
      expect(notifier.state.prophecyState.activeTimedBoost, ProphecyType.solarBlessing);
      expect(notifier.state.prophecyState.activeTimedBoostExpiry, isNotNull);

      // Expire the boost
      final expired = now.add(Duration(minutes: 16));
      notifier.state = notifier.state.updateProphecyEffects(expired);

      // Should clear active boost
      expect(notifier.state.prophecyState.activeTimedBoost, isNull);
      expect(notifier.state.prophecyState.activeTimedBoostExpiry, isNull);
    });

    test('updateProphecyEffects does not clear active boosts', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 100},
        buildings: {BuildingType.smallShrine: 10},
      );

      notifier.state = notifier.state.activateProphecy(ProphecyType.solarBlessing, now);

      // Check while still active (5 minutes in)
      final stillActive = now.add(Duration(minutes: 5));
      notifier.state = notifier.state.updateProphecyEffects(stillActive);

      // Should still have active boost
      expect(notifier.state.prophecyState.activeTimedBoost, ProphecyType.solarBlessing);
      expect(notifier.state.prophecyState.activeTimedBoostExpiry, isNotNull);
    });

    test('Timed boost applies in actual game tick', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 250, ResourceType.cats: 0},
        buildings: {BuildingType.smallShrine: 10}, // 1.0 cats/sec base
      );

      // Activate boost
      notifier.state = notifier.state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

      // Simulate 10 seconds of game time
      // With +100% boost: 1.0 * 2.0 * 10 = 20 cats
      notifier.testUpdateGame(10.0);

      expect(notifier.state.getResource(ResourceType.cats), closeTo(20.0, 0.1));
    });

    test('Boost combines with primordial bonuses', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 100},
        buildings: {BuildingType.smallShrine: 10}, // Base: 1.0 cats/sec
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_1'}, // +10% building production
        ),
      );

      // Without boost: 1.0 * 1.1 = 1.1 cats/sec
      expect(notifier.getProductionRate(ResourceType.cats), closeTo(1.1, 0.01));

      // Activate Solar Blessing (+50%)
      notifier.state = notifier.state.activateProphecy(ProphecyType.solarBlessing, now);

      // With boost: 1.0 * 1.1 (primordial) * 1.5 (boost) = 1.65 cats/sec
      expect(notifier.getProductionRate(ResourceType.cats), closeTo(1.65, 0.01));
    });
  });

  // Task 10: Research Bonuses Application
  group('Research Bonuses to Wisdom Production', () {
    test('Scholarly Pursuit I adds +10% Wisdom production', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {BuildingType.hallOfWisdom: 10}, // Base: 1.0 Wisdom/sec
        completedResearch: {'scholarly_pursuit_i'},
      );

      // Base: 1.0, +10% = 1.1
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.1, 0.01));
    });

    test('Scholarly Pursuit II adds +15% Wisdom production', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {BuildingType.hallOfWisdom: 10}, // Base: 1.0 Wisdom/sec
        completedResearch: {'scholarly_pursuit_ii'},
      );

      // Base: 1.0, +15% = 1.15
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.15, 0.01));
    });

    test('Scholarly Pursuit III adds +20% Wisdom production', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {BuildingType.hallOfWisdom: 10}, // Base: 1.0 Wisdom/sec
        completedResearch: {'scholarly_pursuit_iii'},
      );

      // Base: 1.0, +20% = 1.2
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.2, 0.01));
    });

    test('Scholarly Pursuit bonuses stack multiplicatively', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {BuildingType.hallOfWisdom: 10}, // Base: 1.0 Wisdom/sec
        completedResearch: {
          'scholarly_pursuit_i', // +10%
          'scholarly_pursuit_ii', // +15%
          'scholarly_pursuit_iii', // +20%
        },
      );

      // 1.0 * 1.10 * 1.15 * 1.20 = 1.518
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.518, 0.01));
    });

    test('Divine Insight adds +25% to Athena buildings only', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // 1.0 Wisdom/sec (Athena)
          BuildingType.templeOfDelphi: 1, // 2.0 Wisdom/sec (Apollo)
        },
        completedResearch: {'divine_insight'},
      );

      // Athena: 1.0 * 1.25 = 1.25
      // Apollo: 2.0 * 1.0 = 2.0
      // Total: 3.25
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(3.25, 0.01));
    });

    test('Divine Insight applies to all Athena buildings', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // 1.0 Wisdom/sec
          BuildingType.academyOfAthens: 5, // 5 * 0.8 = 4.0 Wisdom/sec
          BuildingType.strategyChamber: 2, // 2 * 5.0 = 10.0 Wisdom/sec
          BuildingType.oraclesArchive: 1, // 1 * 25.0 = 25.0 Wisdom/sec
          // Total base: 40.0 Wisdom/sec
        },
        completedResearch: {'divine_insight'},
      );

      // All Athena buildings: 40.0 * 1.25 = 50.0
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(50.0, 0.01));
    });

    test('Divine Insight and Scholarly Pursuit stack correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // 1.0 Wisdom/sec
        },
        completedResearch: {
          'divine_insight', // +25% to Athena buildings
          'scholarly_pursuit_i', // +10% global
        },
      );

      // Building bonus: 1.0 * 1.25 = 1.25
      // Global bonus: 1.25 * 1.10 = 1.375
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.375, 0.01));
    });

    test('All research bonuses stack correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // 1.0 Wisdom/sec (Athena)
          BuildingType.templeOfDelphi: 1, // 2.0 Wisdom/sec (Apollo)
        },
        completedResearch: {
          'divine_insight', // +25% to Athena buildings
          'scholarly_pursuit_i', // +10% global
          'scholarly_pursuit_ii', // +15% global
          'scholarly_pursuit_iii', // +20% global
        },
      );

      // Athena: 1.0 * 1.25 (divine insight) = 1.25
      // Apollo: 2.0
      // Total base: 3.25
      // Apply Scholarly Pursuit: 3.25 * 1.10 * 1.15 * 1.20 = 4.9335
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(4.9335, 0.01));
    });

    test('Research bonuses combine with primordial bonuses', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // Base: 1.0 Wisdom/sec
        },
        completedResearch: {'scholarly_pursuit_i'}, // +10%
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_1', 'erebus_1'}, // +10% building, +15% tier2
        ),
      );

      // Base: 1.0
      // Primordial: 1.0 * 1.10 (Gaia) * 1.15 (Erebus tier2) = 1.265
      // Research: 1.265 * 1.10 (Scholarly Pursuit I) = 1.3915
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.3915, 0.01));
    });

    test('Research bonuses combine with prophecy boosts', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 250},
        buildings: {
          BuildingType.hallOfWisdom: 10, // Base: 1.0 Wisdom/sec
        },
        completedResearch: {'scholarly_pursuit_i'}, // +10%
      );

      // Activate Prophecy of Abundance (+100%)
      notifier.state = notifier.state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

      // Base: 1.0
      // Research: 1.0 * 1.10 = 1.1
      // Prophecy: 1.1 * 2.0 = 2.2
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(2.2, 0.01));
    });

    test('Research bonuses apply in game loop', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // Base: 1.0 Wisdom/sec
        },
        completedResearch: {'scholarly_pursuit_i'}, // +10%
      );

      final initialWisdom = notifier.state.getResource(ResourceType.wisdom);
      notifier.testUpdateGame(10.0); // 10 seconds
      final finalWisdom = notifier.state.getResource(ResourceType.wisdom);

      // Production: 1.0 * 1.10 * 10 = 11.0
      expect(finalWisdom - initialWisdom, closeTo(11.0, 0.1));
    });

    test('Divine Insight only affects Athena buildings, not Apollo', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Test Apollo buildings without Divine Insight
      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.templeOfDelphi: 1, // 2.0 Wisdom/sec (Apollo)
          BuildingType.sunChariotStable: 1, // 12.0 Wisdom/sec (Apollo)
        },
        completedResearch: {'divine_insight'},
      );

      // Divine Insight should NOT affect Apollo buildings
      // Total: 2.0 + 12.0 = 14.0 (no bonus)
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(14.0, 0.01));
    });

    test('No research bonuses without completed research', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        buildings: {
          BuildingType.hallOfWisdom: 10, // Base: 1.0 Wisdom/sec
        },
        completedResearch: {},
      );

      // No bonuses, should be base production
      expect(notifier.getProductionRate(ResourceType.wisdom), closeTo(1.0, 0.01));
    });

    test('Prophetic Connection reduces prophecy costs by 15%', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 500},
        completedResearch: {'prophetic_connection'},
      );

      // Prophecy of Abundance normally costs 250 Wisdom
      // With -15%, it costs 212.5 Wisdom
      notifier.state = notifier.state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

      // Should have 500 - 212.5 = 287.5 Wisdom remaining
      expect(notifier.state.getResource(ResourceType.wisdom), closeTo(287.5, 0.1));
    });

    test('Prophetic Connection applies to all prophecies', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 1000},
        completedResearch: {'prophetic_connection'},
      );

      // Solar Blessing normally costs 100 Wisdom
      // With -15%, it costs 85 Wisdom
      notifier.state = notifier.state.activateProphecy(ProphecyType.solarBlessing, now);

      // Should have 1000 - 85 = 915 Wisdom remaining
      expect(notifier.state.getResource(ResourceType.wisdom), closeTo(915.0, 0.1));
    });

    test('Prophecy costs without Prophetic Connection', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.wisdom: 500},
        completedResearch: {}, // No prophetic connection
      );

      // Prophecy of Abundance normally costs 250 Wisdom
      notifier.state = notifier.state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

      // Should have 500 - 250 = 250 Wisdom remaining
      expect(notifier.state.getResource(ResourceType.wisdom), closeTo(250.0, 0.1));
    });
  });
}
