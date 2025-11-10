import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/providers/research_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class ResearchNodeCard extends ConsumerWidget {
  final ResearchNode node;

  const ResearchNodeCard({
    super.key,
    required this.node,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final research = ref.watch(researchProvider);

    final isCompleted = gameState.hasCompletedResearch(node.id);
    final canUnlock = research.canUnlockResearch(node);

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.science,
          color: isCompleted
              ? Colors.green
              : canUnlock
                  ? Colors.blue
                  : Colors.grey,
        ),
        title: Text(
          node.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(node.description),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: node.cost.entries.map((entry) {
                final hasEnough = gameState.getResource(entry.key) >= entry.value;
                return Text(
                  '${entry.key.icon} ${NumberFormatter.format(entry.value)}',
                  style: TextStyle(
                    color: hasEnough ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.done, color: Colors.green)
            : ElevatedButton(
                onPressed: canUnlock
                    ? () {
                        ref.read(researchProvider).unlockResearch(node);
                      }
                    : null,
                child: const Text('Research'),
              ),
      ),
    );
  }
}
