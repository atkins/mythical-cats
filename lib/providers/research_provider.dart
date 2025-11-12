import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';

final researchProvider = Provider<ResearchNotifier>((ref) {
  return ResearchNotifier(ref);
});

class ResearchNotifier {
  final Ref ref;

  ResearchNotifier(this.ref);

  /// Get the actual cost of a research node with achievement bonuses applied
  Map<ResourceType, double> getResearchCost(ResearchNode node) {
    final gameState = ref.read(gameProvider);
    final result = <ResourceType, double>{};

    for (final entry in node.cost.entries) {
      double cost = entry.value;

      // Philosopher King: -5% research costs
      if (gameState.hasUnlockedAchievement('philosopher_king')) {
        cost *= 0.95;
      }

      result[entry.key] = cost;
    }

    return result;
  }

  /// Check if player can afford a research node
  bool canAffordResearch(ResearchNode node) {
    final gameState = ref.read(gameProvider);
    final actualCost = getResearchCost(node);

    for (final entry in actualCost.entries) {
      if (gameState.getResource(entry.key) < entry.value) {
        return false;
      }
    }

    return true;
  }

  /// Check if prerequisites are met for a research node
  bool _prerequisitesMet(ResearchNode node) {
    final gameState = ref.read(gameProvider);

    for (final prereqId in node.prerequisites) {
      if (!gameState.hasCompletedResearch(prereqId)) {
        return false;
      }
    }

    return true;
  }

  /// Check if player can unlock a research node (affordable + prerequisites met)
  bool canUnlockResearch(ResearchNode node) {
    final gameState = ref.read(gameProvider);

    // Already completed
    if (gameState.hasCompletedResearch(node.id)) {
      return false;
    }

    // Check prerequisites
    if (!_prerequisitesMet(node)) {
      return false;
    }

    // Check affordability
    return canAffordResearch(node);
  }

  /// Unlock a research node
  bool unlockResearch(ResearchNode node) {
    if (!canUnlockResearch(node)) {
      return false;
    }

    final game = ref.read(gameProvider.notifier);
    final actualCost = getResearchCost(node);

    // Deduct costs (with achievement discount applied)
    for (final entry in actualCost.entries) {
      game.addResource(entry.key, -entry.value);
    }

    // Mark as completed
    final currentState = ref.read(gameProvider);
    final newCompleted = Set<String>.from(currentState.completedResearch)
      ..add(node.id);

    game.updateState(currentState.copyWith(
      completedResearch: newCompleted,
    ));

    return true;
  }

  /// Get all research nodes that can be unlocked (prerequisites met, not completed)
  List<ResearchNode> getAvailableResearch() {
    final gameState = ref.read(gameProvider);

    return ResearchDefinitions.phase3Nodes.where((node) {
      // Not already completed
      if (gameState.hasCompletedResearch(node.id)) {
        return false;
      }

      // Prerequisites met
      return _prerequisitesMet(node);
    }).toList();
  }
}
