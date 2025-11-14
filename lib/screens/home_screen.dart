import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/screens/buildings_screen.dart';
import 'package:mythical_cats/screens/divine_powers_screen.dart';
import 'package:mythical_cats/screens/settings_screen.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/widgets/resource_panel.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Tab indices as constants to avoid magic numbers
  static const int _homeTabIndex = 0;
  static const int _buildingsTabIndex = 1;
  static const int _divinePowersTabIndex = 2;
  static const int _reincarnationTabIndex = 3;
  static const int _settingsTabIndex = 4;

  int _selectedIndex = _homeTabIndex;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Public API for programmatic navigation from child widgets
  void navigateToTab(int index) {
    _onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    // Build screens for IndexedStack
    final screens = [
      const _HomeTab(),
      const BuildingsScreen(),
      const DivinePowersScreen(),
      const ReincarnationScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment),
            label: 'Buildings',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Divine Powers',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew),
            label: 'Reincarnation',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  God? _getNextGod(gameState) {
    final currentGodIndex = gameState.unlockedGods.last.index;
    if (currentGodIndex < God.values.length - 1) {
      return God.values[currentGodIndex + 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final cats = gameState.getResource(ResourceType.cats);
    final catsPerSecond = gameNotifier.catsPerSecond;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mythical Cats'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
              // Resource display
              _ResourceDisplay(
                icon: ResourceType.cats.icon,
                label: ResourceType.cats.displayName,
                value: cats,
                rate: catsPerSecond,
              ),
              const SizedBox(height: 16),

              // All resources panel
              const ResourcePanel(),
              const SizedBox(height: 24),

              // Prestige stats (if player has reincarnated)
              if (gameState.reincarnationState.totalReincarnations > 0)
                PrestigeStatsPanel(
                  availablePE: gameState.reincarnationState.availablePrimordialEssence,
                  totalPE: gameState.reincarnationState.totalPrimordialEssence,
                  reincarnations: gameState.reincarnationState.totalReincarnations,
                  activePatron: gameState.reincarnationState.activePatron,
                  ownedUpgradeIds: gameState.reincarnationState.ownedUpgradeIds,
                  onTap: () {
                    // Navigate to Reincarnation tab
                    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                    homeScreenState?.navigateToTab(_HomeScreenState._reincarnationTabIndex);
                  },
                ),
              if (gameState.reincarnationState.totalReincarnations > 0)
                const SizedBox(height: 24),

              // Ritual button (click to generate cats)
              _RitualButton(
                onPressed: () => gameNotifier.performRitual(),
              ),

              const SizedBox(height: 24),

              // Quick stats
              _QuickStats(
                currentGod: gameState.unlockedGods.last.displayName,
                totalEarned: gameState.totalCatsEarned,
                nextGod: _getNextGod(gameState),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResourceDisplay extends StatelessWidget {
  final String icon;
  final String label;
  final double value;
  final double rate;

  const _ResourceDisplay({
    required this.icon,
    required this.label,
    required this.value,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.format(value),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          if (rate > 0) ...[
            const SizedBox(height: 4),
            Text(
              NumberFormatter.formatRate(rate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.amber.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RitualButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RitualButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 48),
            const SizedBox(height: 8),
            Text(
              'Perform Ritual',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '+1 ${ResourceType.cats.icon}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final String currentGod;
  final double totalEarned;
  final God? nextGod;

  const _QuickStats({
    required this.currentGod,
    required this.totalEarned,
    this.nextGod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatRow(
            label: 'Current God',
            value: currentGod,
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Total Cats Earned',
            value: NumberFormatter.format(totalEarned),
          ),
          if (nextGod != null) ...[
            const SizedBox(height: 8),
            _StatRow(
              label: 'Next God',
              value:
                  '${nextGod!.displayName} (${NumberFormatter.format(nextGod!.unlockRequirement!)})',
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (totalEarned / nextGod!.unlockRequirement!).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
