import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/conquest_territory.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';

final conquestProvider = Provider<ConquestNotifier>((ref) {
  return ConquestNotifier(ref);
});

class ConquestNotifier {
  final Ref ref;

  ConquestNotifier(this.ref);

  /// Get the actual cost of a territory with achievement bonuses applied
  double getTerritoryCost(ConquestTerritory territory) {
    final gameState = ref.read(gameProvider);
    double cost = territory.cost.toDouble();

    // Master of Knowledge: -10% conquest costs
    if (gameState.hasUnlockedAchievement('master_of_knowledge')) {
      cost *= 0.90;
    }

    return cost;
  }

  /// Check if player can afford a territory
  bool _canAffordTerritory(ConquestTerritory territory) {
    final gameState = ref.read(gameProvider);
    final actualCost = getTerritoryCost(territory);
    return gameState.getResource(ResourceType.conquestPoints) >= actualCost;
  }

  /// Check if prerequisites are met for a territory
  bool _prerequisitesMet(ConquestTerritory territory) {
    final gameState = ref.read(gameProvider);

    if (territory.prerequisite == null) {
      return true;
    }

    return gameState.hasConqueredTerritory(territory.prerequisite!);
  }

  /// Check if player can conquer a territory
  bool canConquerTerritory(ConquestTerritory territory) {
    final gameState = ref.read(gameProvider);

    // Already conquered
    if (gameState.hasConqueredTerritory(territory.id)) {
      return false;
    }

    // Check prerequisites
    if (!_prerequisitesMet(territory)) {
      return false;
    }

    // Check affordability
    return _canAffordTerritory(territory);
  }

  /// Conquer a territory
  bool conquerTerritory(ConquestTerritory territory) {
    if (!canConquerTerritory(territory)) {
      return false;
    }

    final game = ref.read(gameProvider.notifier);
    final actualCost = getTerritoryCost(territory);

    // Deduct cost (with achievement discount applied)
    game.addResource(ResourceType.conquestPoints, -actualCost);

    // Mark as conquered
    final currentState = ref.read(gameProvider);
    final newConquered = Set<String>.from(currentState.conqueredTerritories)
      ..add(territory.id);

    game.updateState(currentState.copyWith(
      conqueredTerritories: newConquered,
    ));

    // Check achievements after conquering
    game.checkAchievementsPublic();

    return true;
  }

  /// Get all territories that can be conquered
  List<ConquestTerritory> getAvailableTerritories() {
    final gameState = ref.read(gameProvider);

    return ConquestDefinitions.all.where((territory) {
      // Not already conquered
      if (gameState.hasConqueredTerritory(territory.id)) {
        return false;
      }

      // Prerequisites met
      return _prerequisitesMet(territory);
    }).toList();
  }

  /// Get total production bonus from all conquered territories
  Map<ResourceType, double> getTotalProductionBonus() {
    final gameState = ref.read(gameProvider);
    final bonuses = <ResourceType, double>{};

    for (final territory in ConquestDefinitions.all) {
      if (gameState.hasConqueredTerritory(territory.id)) {
        for (final entry in territory.productionBonus.entries) {
          bonuses[entry.key] = (bonuses[entry.key] ?? 0) + entry.value;
        }
      }
    }

    return bonuses;
  }
}
