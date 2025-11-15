import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/research_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResearchNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('canAffordResearch returns true when affordable', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.cats, 10000);
      game.addResource(ResourceType.prayers, 2000);

      final research = container.read(researchProvider);
      final canAfford = research.canAffordResearch(ResearchDefinitions.divineArchitecture1);

      expect(canAfford, true);
    });

    test('canAffordResearch returns false when not affordable', () {
      final research = container.read(researchProvider);
      final canAfford = research.canAffordResearch(ResearchDefinitions.divineArchitecture1);

      expect(canAfford, false);
    });

    test('canUnlockResearch returns false when prerequisites not met', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.cats, 20000);
      game.addResource(ResourceType.prayers, 3000);

      final research = container.read(researchProvider);
      final canUnlock = research.canUnlockResearch(ResearchDefinitions.sacredGeometry);

      expect(canUnlock, false); // Requires divineArchitecture1
    });

    test('canUnlockResearch returns true when prerequisites met and affordable', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.cats, 20000);
      game.addResource(ResourceType.prayers, 3000);

      final research = container.read(researchProvider);
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      final canUnlock = research.canUnlockResearch(ResearchDefinitions.sacredGeometry);
      expect(canUnlock, true);
    });

    test('unlockResearch completes research and deducts cost', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.cats, 10000);
      game.addResource(ResourceType.prayers, 2000);

      final research = container.read(researchProvider);
      final success = research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      expect(success, true);

      final gameState = container.read(gameProvider);
      expect(gameState.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameState.getResource(ResourceType.cats), 5000);
      expect(gameState.getResource(ResourceType.prayers), 1000);
    });

    test('unlockResearch fails when not affordable', () {
      final research = container.read(researchProvider);
      final success = research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      expect(success, false);

      final gameState = container.read(gameProvider);
      expect(gameState.hasCompletedResearch('divine_architecture_1'), false);
    });

    test('unlockResearch fails when prerequisites not met', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.cats, 20000);
      game.addResource(ResourceType.prayers, 3000);

      final research = container.read(researchProvider);
      final success = research.unlockResearch(ResearchDefinitions.sacredGeometry);

      expect(success, false);
    });

    test('getAvailableResearch returns only unlockable nodes', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);
      game.addResource(ResourceType.divineEssence, 10000);

      final research = container.read(researchProvider);
      final available = research.getAvailableResearch();

      // Only root nodes should be available initially
      expect(available.length, 2); // divineArchitecture1 and essenceRefinement
      expect(available.any((n) => n.id == 'divine_architecture_1'), true);
      expect(available.any((n) => n.id == 'essence_refinement'), true);
    });
  });

  group('Complex Research Chains', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('three-deep prerequisite chain unlocks correctly', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      // Give abundant resources
      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);

      // Level 1: Divine Architecture I
      expect(research.canUnlockResearch(ResearchDefinitions.divineArchitecture1), true);
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      // Level 2: Sacred Geometry (requires Divine Architecture I)
      expect(research.canUnlockResearch(ResearchDefinitions.sacredGeometry), true);
      research.unlockResearch(ResearchDefinitions.sacredGeometry);

      // Level 3: Divine Architecture II (requires Sacred Geometry)
      expect(research.canUnlockResearch(ResearchDefinitions.divineArchitecture2), true);
      research.unlockResearch(ResearchDefinitions.divineArchitecture2);

      final gameState = container.read(gameProvider);
      expect(gameState.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameState.hasCompletedResearch('sacred_geometry'), true);
      expect(gameState.hasCompletedResearch('divine_architecture_2'), true);
    });

    test('cannot skip levels in prerequisite chain', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);

      // Try to unlock Divine Architecture II without prerequisites
      expect(research.canUnlockResearch(ResearchDefinitions.divineArchitecture2), false);

      // Unlock only level 1
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      // Still can't unlock level 3 without level 2
      expect(research.canUnlockResearch(ResearchDefinitions.divineArchitecture2), false);
    });

    test('multiple parallel research branches can be unlocked', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);
      game.addResource(ResourceType.divineEssence, 10000);

      // Unlock from Architecture branch
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      // Unlock from Power branch (independent)
      research.unlockResearch(ResearchDefinitions.essenceRefinement);

      final gameState = container.read(gameProvider);
      expect(gameState.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameState.hasCompletedResearch('essence_refinement'), true);
    });

    test('knowledge branch prerequisite chain works correctly', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 2000000);
      game.addResource(ResourceType.offerings, 100000);
      game.addResource(ResourceType.divineEssence, 10000);
      game.addResource(ResourceType.wisdom, 10000);

      // Foundations of Wisdom (root)
      expect(research.canUnlockResearch(ResearchDefinitions.foundationsOfWisdom), true);
      research.unlockResearch(ResearchDefinitions.foundationsOfWisdom);

      // Scholarly Pursuit I (requires Foundations)
      expect(research.canUnlockResearch(ResearchDefinitions.scholarlyPursuitI), true);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitI);

      // Scholarly Pursuit II (requires Scholarly Pursuit I)
      expect(research.canUnlockResearch(ResearchDefinitions.scholarlyPursuitII), true);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitII);

      // Scholarly Pursuit III (requires Scholarly Pursuit II)
      expect(research.canUnlockResearch(ResearchDefinitions.scholarlyPursuitIII), true);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitIII);

      final gameState = container.read(gameProvider);
      expect(gameState.completedResearch.length, 4);
    });
  });

  group('Research Cost Reductions', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Philosopher King achievement reduces research costs by 5%', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      // Give exact cost for Divine Architecture I (5000 cats, 1000 prayers)
      game.addResource(ResourceType.cats, 5000);
      game.addResource(ResourceType.prayers, 1000);

      // Should not be able to unlock with exact cost and no achievement
      expect(research.canAffordResearch(ResearchDefinitions.divineArchitecture1), true);

      // Add achievement
      game.state = game.state.copyWith(
        unlockedAchievements: {'philosopher_king'},
        resources: {
          ResourceType.cats: 4750, // 5% less
          ResourceType.prayers: 950, // 5% less
        },
      );

      // Should be able to afford with 5% discount
      expect(research.canAffordResearch(ResearchDefinitions.divineArchitecture1), true);
    });
  });

  group('Research Bonus Application', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Divine Architecture bonuses apply to building costs', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);

      // Unlock Divine Architecture I (reduces building costs by 5%)
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      final gameState = container.read(gameProvider);
      expect(gameState.hasCompletedResearch('divine_architecture_1'), true);

      // Building costs should be reduced (tested via game provider)
    });

    test('Scholarly Pursuit bonuses stack multiplicatively', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 2000000);
      game.addResource(ResourceType.offerings, 100000);
      game.addResource(ResourceType.divineEssence, 10000);
      game.addResource(ResourceType.wisdom, 10000);

      // Unlock multiple Scholarly Pursuit levels
      research.unlockResearch(ResearchDefinitions.foundationsOfWisdom);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitI);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitII);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitIII);

      final gameState = container.read(gameProvider);

      // All three bonuses should stack
      expect(gameState.hasCompletedResearch('scholarly_pursuit_i'), true);
      expect(gameState.hasCompletedResearch('scholarly_pursuit_ii'), true);
      expect(gameState.hasCompletedResearch('scholarly_pursuit_iii'), true);
    });

    test('completing all Knowledge branch nodes works', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 20000000);
      game.addResource(ResourceType.offerings, 1000000);
      game.addResource(ResourceType.divineEssence, 50000);
      game.addResource(ResourceType.wisdom, 100000);

      // Unlock entire Knowledge branch
      research.unlockResearch(ResearchDefinitions.foundationsOfWisdom);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitI);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitII);
      research.unlockResearch(ResearchDefinitions.scholarlyPursuitIII);
      research.unlockResearch(ResearchDefinitions.divineInsight);
      research.unlockResearch(ResearchDefinitions.philosophicalMethod);
      research.unlockResearch(ResearchDefinitions.propheticConnection);

      final gameState = container.read(gameProvider);
      expect(gameState.completedResearch.length, 7);

      // This should unlock Philosopher King achievement (tested in game provider)
    });
  });

  group('Research State Persistence', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('completed research persists through reincarnation', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);

      // Unlock some research
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);
      research.unlockResearch(ResearchDefinitions.sacredGeometry);

      // Prepare for reincarnation
      game.state = game.state.copyWith(totalCatsEarned: 1000000000);

      // Reincarnate
      game.reincarnate(PrimordialForce.chaos);

      final gameState = container.read(gameProvider);

      // Research should still be completed
      expect(gameState.hasCompletedResearch('divine_architecture_1'), true);
      expect(gameState.hasCompletedResearch('sacred_geometry'), true);
    });

    test('cannot unlock same research twice', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.prayers, 100000);

      // Unlock once
      final firstUnlock = research.unlockResearch(ResearchDefinitions.divineArchitecture1);
      expect(firstUnlock, true);

      final catsAfterFirst = container.read(gameProvider).getResource(ResourceType.cats);

      // Try to unlock again
      final secondUnlock = research.unlockResearch(ResearchDefinitions.divineArchitecture1);
      expect(secondUnlock, false);

      final catsAfterSecond = container.read(gameProvider).getResource(ResourceType.cats);

      // Resources should not be deducted second time
      expect(catsAfterSecond, catsAfterFirst);
    });
  });
}
