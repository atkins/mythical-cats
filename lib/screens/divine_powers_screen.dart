import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class DivinePowersScreen extends ConsumerWidget {
  const DivinePowersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    // Check if any divine gods are unlocked (not Hermes)
    final hasAthena = gameState.hasUnlockedGod(God.athena);
    final hasAres = gameState.hasUnlockedGod(God.ares);
    final hasApollo = gameState.hasUnlockedGod(God.apollo);
    final hasDivineGods = hasAthena || hasAres || hasApollo;

    if (!hasDivineGods) {
      return _buildTeaserContent(context, gameState);
    }

    return _buildDivinePowersContent(context, gameState);
  }

  Widget _buildTeaserContent(BuildContext context, gameState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divine Powers'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock gods to access their powers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildGodTeaserCard(
                context,
                god: God.athena,
                description: 'Goddess of Wisdom - Unlock powerful research abilities',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
              const SizedBox(height: 16),
              _buildGodTeaserCard(
                context,
                god: God.ares,
                description: 'God of War - Conquer territories for bonuses',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
              const SizedBox(height: 16),
              _buildGodTeaserCard(
                context,
                god: God.apollo,
                description: 'God of Prophecy - Unlock divine foresight',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGodTeaserCard(
    BuildContext context, {
    required God god,
    required String description,
    required double totalCatsEarned,
  }) {
    final requirement = god.unlockRequirement ?? 0;
    final progress = (totalCatsEarned / requirement).clamp(0.0, 1.0);
    final isLocked = totalCatsEarned < requirement;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? Colors.grey.shade400 : Colors.amber.shade700,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock,
                color: isLocked ? Colors.grey.shade600 : Colors.amber.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                god.displayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isLocked ? Colors.grey.shade700 : Colors.amber.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isLocked ? Colors.grey.shade600 : Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock at ${NumberFormatter.format(requirement)} total cats',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLocked ? Colors.grey.shade500 : Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${NumberFormatter.format(totalCatsEarned)} / ${NumberFormatter.format(requirement)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivinePowersContent(BuildContext context, gameState) {
    // Placeholder for now
    return const Scaffold(
      body: Center(child: Text('Divine Powers Content')),
    );
  }
}
