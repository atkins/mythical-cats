import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/widgets/territory_card.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class ConquestScreen extends ConsumerWidget {
  const ConquestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final cpAvailable = gameState.getResource(ResourceType.conquestPoints);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech, size: 32),
              const SizedBox(width: 8),
              Text(
                'Conquest Points: ${NumberFormatter.format(cpAvailable)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ConquestDefinitions.all.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TerritoryCard(
                  territory: ConquestDefinitions.all[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
