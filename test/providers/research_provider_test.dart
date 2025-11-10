import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/research_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';

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
}
