import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/prophecy.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/widgets/prophecy_card.dart';
import 'package:mythical_cats/models/game_state.dart';

class ProphecyScreen extends ConsumerWidget {
  const ProphecyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final currentWisdom = gameState.getResource(ResourceType.wisdom);
    final wisdomRate = gameNotifier.getProductionRate(ResourceType.wisdom);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prophecies'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wisdom balance
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.purple, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wisdom: ${NumberFormatter.format(currentWisdom)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          NumberFormatter.formatRate(wisdomRate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tier 1
            _buildTierSection(
              context,
              'Tier 1: Minor Prophecies',
              _getPropheciesByTier(1),
              gameState,
              currentWisdom,
              now,
              ref,
            ),
            const SizedBox(height: 24),

            // Tier 2
            _buildTierSection(
              context,
              'Tier 2: Standard Prophecies',
              _getPropheciesByTier(2),
              gameState,
              currentWisdom,
              now,
              ref,
            ),
            const SizedBox(height: 24),

            // Tier 3
            _buildTierSection(
              context,
              'Tier 3: Major Prophecies',
              _getPropheciesByTier(3),
              gameState,
              currentWisdom,
              now,
              ref,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSection(
    BuildContext context,
    String title,
    List<ProphecyType> prophecies,
    GameState gameState,
    double currentWisdom,
    DateTime now,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: prophecies.length,
          itemBuilder: (context, index) {
            final prophecy = prophecies[index];
            final isOnCooldown = gameState.prophecyState.isOnCooldown(prophecy, now);
            final cooldownRemaining =
                gameState.prophecyState.getCooldownRemaining(prophecy, now);
            final isActive = gameState.prophecyState.activeTimedBoost == prophecy &&
                gameState.prophecyState.activeTimedBoostExpiry != null &&
                now.isBefore(gameState.prophecyState.activeTimedBoostExpiry!);

            return ProphecyCard(
              prophecy: prophecy,
              currentWisdom: currentWisdom,
              isOnCooldown: isOnCooldown,
              cooldownRemaining: cooldownRemaining,
              isActive: isActive,
              onActivate: () {
                _activateProphecy(context, ref, prophecy);
              },
            );
          },
        ),
      ],
    );
  }

  List<ProphecyType> _getPropheciesByTier(int tier) {
    return ProphecyType.values.where((p) => p.tier == tier).toList();
  }

  void _activateProphecy(BuildContext context, WidgetRef ref, ProphecyType prophecy) {
    final notifier = ref.read(gameProvider.notifier);
    try {
      notifier.activateProphecy(prophecy);

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${prophecy.displayName} activated!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } on ProphecyOnCooldownException catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } on InsufficientResourcesException catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
