import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/widgets/patron_selector.dart';
import 'package:mythical_cats/widgets/primordial_force_section.dart';
import 'package:mythical_cats/widgets/reincarnation_fab.dart';
import 'package:mythical_cats/screens/achievements_screen.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

enum ReincarnationTab { prestige, achievements }

class ReincarnationScreen extends ConsumerStatefulWidget {
  const ReincarnationScreen({super.key});

  @override
  ConsumerState<ReincarnationScreen> createState() => _ReincarnationScreenState();
}

class _ReincarnationScreenState extends ConsumerState<ReincarnationScreen> {
  ReincarnationTab _selectedTab = ReincarnationTab.prestige;

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
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final threshold = 1000000000.0; // 1B
    final isUnlocked = gameState.totalCatsEarned >= threshold;

    if (!isUnlocked) {
      return _buildTeaserContent(context, gameState);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reincarnation'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<ReincarnationTab>(
                segments: const [
                  ButtonSegment(
                    value: ReincarnationTab.prestige,
                    label: Text('Prestige'),
                  ),
                  ButtonSegment(
                    value: ReincarnationTab.achievements,
                    label: Text('Achievements'),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (Set<ReincarnationTab> selected) {
                  setState(() {
                    _selectedTab = selected.first;
                  });
                },
              ),
            ),
            Expanded(
              child: _selectedTab == ReincarnationTab.prestige
                  ? _buildPrestigeContent(context, gameState, gameNotifier)
                  : const AchievementsScreen(),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTab == ReincarnationTab.prestige
          ? _buildReincarnationFab(gameState, gameNotifier)
          : null,
    );
  }

  Widget _buildTeaserContent(BuildContext context, gameState) {
    final progress = (gameState.totalCatsEarned / 1000000000).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reincarnation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade700, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.autorenew, size: 32, color: Colors.purple.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Reincarnation',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reset your progress to gain Primordial Essence, a powerful currency that persists across reincarnations.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Benefits:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet(context, 'Permanent production multipliers'),
                    _buildBullet(context, 'Choose a Patron god for unique bonuses'),
                    _buildBullet(context, 'Unlock powerful permanent upgrades'),
                    _buildBullet(context, 'Progress faster with each reincarnation'),
                    const SizedBox(height: 24),
                    Text(
                      'Unlock Requirement:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1.00B total cats earned',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormatter.format(gameState.totalCatsEarned)} / 1.00B',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestigeContent(BuildContext context, gameState, gameNotifier) {
    final reincState = gameState.reincarnationState;

    return SafeArea(
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
    );
  }

  Widget _buildReincarnationFab(gameState, gameNotifier) {
    final peEarned =
        gameNotifier.calculatePrimordialEssence(gameState.totalCatsEarned);
    final threshold = 1000000000.0;
    final isEnabled = gameState.totalCatsEarned >= threshold;
    final catsRemaining =
        isEnabled ? 0.0 : threshold - gameState.totalCatsEarned;

    return ReincarnationFab(
      peEarned: peEarned,
      isEnabled: isEnabled,
      catsRemaining: catsRemaining,
      onPressed: () => _showReincarnationDialog(context, ref),
    );
  }
}
