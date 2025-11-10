import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/conquest_territory.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class TerritoryCard extends ConsumerWidget {
  final ConquestTerritory territory;

  const TerritoryCard({
    super.key,
    required this.territory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final conquest = ref.watch(conquestProvider);

    final isConquered = gameState.hasConqueredTerritory(territory.id);
    final canConquer = conquest.canConquerTerritory(territory);
    final cpAvailable = gameState.getResource(ResourceType.conquestPoints);

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isConquered ? Icons.flag : Icons.outlined_flag,
          color: isConquered
              ? Colors.amber
              : canConquer
                  ? Colors.blue
                  : Colors.grey,
        ),
        title: Text(
          territory.name,
          style: TextStyle(
            fontWeight: isConquered ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost: ⚔️ ${NumberFormatter.format(territory.cost)}',
              style: TextStyle(
                color: cpAvailable >= territory.cost ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bonus: ${_formatBonuses(territory.productionBonus)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isConquered
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: canConquer
                    ? () {
                        ref.read(conquestProvider).conquerTerritory(territory);
                      }
                    : null,
                child: const Text('Conquer'),
              ),
      ),
    );
  }

  String _formatBonuses(Map<ResourceType, double> bonuses) {
    return bonuses.entries
        .map((e) => '${e.key.icon} +${(e.value * 100).toStringAsFixed(0)}%')
        .join(', ');
  }
}
