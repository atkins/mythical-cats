import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Full reincarnation cycle preserves research and achievements', () {
      final notifier = container.read(gameProvider.notifier);

      // Set up pre-reincarnation state
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        completedResearch: {'divine_architecture_1', 'essence_refinement'},
        unlockedAchievements: {'cats_100', 'cats_1k'},
        buildings: {BuildingType.smallShrine: 10},
        resources: {ResourceType.cats: 50000000},
      );

      // Reincarnate
      notifier.reincarnate(PrimordialForce.chaos);

      // Verify reset
      expect(notifier.state.getResource(ResourceType.cats), 0);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 0);

      // Verify persistence
      expect(notifier.state.completedResearch.length, 2);
      expect(notifier.state.unlockedAchievements.length, 2);
      expect(notifier.state.reincarnationState.totalReincarnations, 1);
      expect(notifier.state.reincarnationState.availablePrimordialEssence, 20);
      expect(notifier.state.reincarnationState.activePatron, PrimordialForce.chaos);
    });

    test('Patron bonuses apply correctly after reincarnation', () {
      final notifier = container.read(gameProvider.notifier);

      // Buy Chaos I (costs 10 PE, gives +10% click)
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 20,
        ),
      );

      notifier.purchasePrimordialUpgrade('chaos_1');
      notifier.reincarnate(PrimordialForce.chaos);

      // Chaos I: +10% permanent
      // Chaos patron with 1 tier: +50% + 10% = 60%
      // Total: 1.7x
      expect(notifier.getClickPowerMultiplier(), closeTo(1.7, 0.01));

      notifier.performRitual();
      expect(notifier.state.getResource(ResourceType.cats), closeTo(1.7, 0.01));
    });

    test('Multiple reincarnations accumulate PE correctly', () {
      final notifier = container.read(gameProvider.notifier);

      // First reincarnation at 1B cats
      notifier.state = notifier.state.copyWith(totalCatsEarned: 1000000000);
      notifier.reincarnate(PrimordialForce.chaos);
      expect(notifier.state.reincarnationState.totalPrimordialEssence, 20);

      // Second reincarnation at 5B cats
      notifier.state = notifier.state.copyWith(totalCatsEarned: 5000000000);
      notifier.reincarnate(PrimordialForce.gaia);
      expect(notifier.state.reincarnationState.totalPrimordialEssence, 50); // 20 + 30
    });

    test('Upgrade prerequisite chain works across tiers', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 500,
        ),
      );

      // Can buy tier 1
      expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), true);

      // Cannot buy tier 2 yet
      expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), false);

      // Buy tier 1
      notifier.purchasePrimordialUpgrade('chaos_1');

      // Now can buy tier 2
      expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), true);

      // Buy tier 2
      notifier.purchasePrimordialUpgrade('chaos_2');

      // Now can buy tier 3
      expect(notifier.canPurchasePrimordialUpgrade('chaos_3'), true);
    });

    test('Gaia cost reduction applies to building purchases', () {
      final notifier = container.read(gameProvider.notifier);

      // Buy Gaia III and IV for -15% cost
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.cats: 1000},
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'gaia_3', 'gaia_4'},
        ),
      );

      // Small shrine costs 15 cats normally, -15% = 12.75
      notifier.buyBuilding(BuildingType.smallShrine);

      // Should have spent 12.75 cats
      expect(notifier.state.getResource(ResourceType.cats), closeTo(987.25, 0.1));
    });

    test('All 4 forces can be maxed independently', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 2000, // Enough for everything
        ),
      );

      // Max Chaos tree (385 PE total: 10+25+50+100+200)
      notifier.purchasePrimordialUpgrade('chaos_1');
      notifier.purchasePrimordialUpgrade('chaos_2');
      notifier.purchasePrimordialUpgrade('chaos_3');
      notifier.purchasePrimordialUpgrade('chaos_4');
      notifier.purchasePrimordialUpgrade('chaos_5');

      // Verify 5 chaos upgrades owned
      final chaosUpgrades = notifier.state.reincarnationState.ownedUpgradeIds
          .where((id) => id.startsWith('chaos_'))
          .length;
      expect(chaosUpgrades, 5);
      expect(notifier.state.reincarnationState.availablePrimordialEssence, 2000 - 385);

      // Max Gaia tree
      notifier.purchasePrimordialUpgrade('gaia_1');
      notifier.purchasePrimordialUpgrade('gaia_2');
      notifier.purchasePrimordialUpgrade('gaia_3');
      notifier.purchasePrimordialUpgrade('gaia_4');
      notifier.purchasePrimordialUpgrade('gaia_5');

      // Verify 5 gaia upgrades owned
      final gaiaUpgrades = notifier.state.reincarnationState.ownedUpgradeIds
          .where((id) => id.startsWith('gaia_'))
          .length;
      expect(gaiaUpgrades, 5);
    });

    test('Tier 5 upgrades increase PE earnings', () {
      final notifier = container.read(gameProvider.notifier);

      // With no tier 5 upgrades
      expect(notifier.calculatePrimordialEssence(1000000000), 20);

      // With all 4 tier 5 upgrades (+40% PE)
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'chaos_5', 'gaia_5', 'nyx_5', 'erebus_5'},
        ),
      );

      expect(notifier.calculatePrimordialEssence(1000000000), 28); // 20 * 1.4
    });

    test('Nyx upgrades increase offline cap', () {
      final notifier = container.read(gameProvider.notifier);

      // Default cap is 24 hours
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

    test('Erebus bonuses apply to Tier 2 resources only', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          ownedUpgradeIds: {'erebus_1', 'erebus_2'}, // +45% tier 2
          activePatron: PrimordialForce.erebus, // +70% tier 2
        ),
      );

      // Tier 2 multiplier should be 2.15x (1.0 + 0.45 + 0.7)
      expect(notifier.getTier2ProductionMultiplier(), closeTo(2.15, 0.01));

      // Regular building multiplier should be 1.0 (no Gaia bonuses)
      expect(notifier.getBuildingProductionMultiplier(), 1.0);
    });

    test('Switching patrons changes active bonuses', () {
      final notifier = container.read(gameProvider.notifier);

      // Buy upgrades for both Chaos and Gaia
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1', 'gaia_1'},
        ),
      );

      // Set Chaos as patron
      notifier.reincarnate(PrimordialForce.chaos);

      // Should have Chaos patron bonus
      expect(notifier.getClickPowerMultiplier(), greaterThan(1.1)); // More than just permanent 10%

      // Reincarnate again with Gaia as patron
      notifier.state = notifier.state.copyWith(totalCatsEarned: 1000000000);
      notifier.reincarnate(PrimordialForce.gaia);

      // Should now have Gaia patron bonus
      expect(notifier.getBuildingProductionMultiplier(), greaterThan(1.1)); // More than just permanent 10%
    });
  });
}
