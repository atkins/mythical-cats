import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/widgets/patron_selector.dart';
import 'package:mythical_cats/widgets/primordial_force_section.dart';
import 'package:mythical_cats/widgets/reincarnation_fab.dart';

class ReincarnationScreen extends ConsumerWidget {
  const ReincarnationScreen({super.key});

  void _showReincarnationDialog(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final peEarned =
        gameNotifier.calculatePrimordialEssence(gameState.totalCatsEarned);
    final activePatron = gameState.reincarnationState.activePatron;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reincarnate?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You will gain:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('  • +$peEarned Primordial Essence'),
              const SizedBox(height: 12),
              Text(
                'Active patron:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                activePatron != null
                    ? '  • ${activePatron.icon} ${activePatron.displayName}'
                    : '  • None',
              ),
              const SizedBox(height: 12),
              Text(
                'You will reset:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Text('  • Cats, Offerings, Prayers, Divine Essence, Ambrosia'),
              const Text('  • All Buildings'),
              const Text('  • God unlocks (except Hermes)'),
              const Text('  • Conquered territories'),
              const SizedBox(height: 12),
              Text(
                'You will keep:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Text('  • Research progress'),
              const Text('  • Achievements'),
              const Text('  • Primordial upgrades'),
              const Text('  • Total PE earned'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (activePatron != null) {
                gameNotifier.reincarnate(activePatron);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reincarnated! Earned $peEarned PE'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reincarnate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final reincState = gameState.reincarnationState;
    final peEarned =
        gameNotifier.calculatePrimordialEssence(gameState.totalCatsEarned);
    final threshold = 1000000000.0;
    final isEnabled = gameState.totalCatsEarned >= threshold;
    final catsRemaining =
        isEnabled ? 0.0 : threshold - gameState.totalCatsEarned;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Patron Selector
              PatronSelector(
                activePatron: reincState.activePatron,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                onPatronSelected: (force) =>
                    gameNotifier.setActivePatron(force),
              ),
              const SizedBox(height: 8),
              // Force Sections
              PrimordialForceSection(
                force: PrimordialForce.chaos,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              PrimordialForceSection(
                force: PrimordialForce.gaia,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              PrimordialForceSection(
                force: PrimordialForce.nyx,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              PrimordialForceSection(
                force: PrimordialForce.erebus,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              // Bottom padding for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: ReincarnationFab(
        peEarned: peEarned,
        isEnabled: isEnabled,
        catsRemaining: catsRemaining,
        onPressed: () => _showReincarnationDialog(context, ref),
      ),
    );
  }
}
