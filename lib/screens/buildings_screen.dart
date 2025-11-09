import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/widgets/building_card.dart';

class BuildingsScreen extends ConsumerWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buildings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: BuildingType.values.length,
        itemBuilder: (context, index) {
          final buildingType = BuildingType.values[index];
          final definition = BuildingDefinitions.get(buildingType);
          final owned = gameState.getBuildingCount(buildingType);
          final cost = definition.calculateCost(owned);

          // Check if unlocked
          final requiredGod = buildingType.requiredGod;
          final isUnlocked = requiredGod == null ||
                             gameState.hasUnlockedGod(requiredGod);

          // Check if can afford
          bool canAfford = true;
          for (final entry in cost.entries) {
            if (gameState.getResource(entry.key) < entry.value) {
              canAfford = false;
              break;
            }
          }

          return BuildingCard(
            type: buildingType,
            owned: owned,
            cost: cost,
            canAfford: canAfford,
            isUnlocked: isUnlocked,
            onBuy: () => gameNotifier.buyBuilding(buildingType),
          );
        },
      ),
    );
  }
}
