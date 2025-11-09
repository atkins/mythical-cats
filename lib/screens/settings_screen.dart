import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/services/save_service.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/models/game_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Stats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Statistics'),
          _StatTile(
            label: 'Total Cats Earned',
            value: NumberFormatter.format(gameState.totalCatsEarned),
          ),
          _StatTile(
            label: 'Total Buildings',
            value: gameState.buildings.values.fold<int>(
              0, (sum, count) => sum + count,
            ).toString(),
          ),
          _StatTile(
            label: 'Gods Unlocked',
            value: '${gameState.unlockedGods.length} / 12',
          ),
          _StatTile(
            label: 'Achievements Unlocked',
            value: '${gameState.unlockedAchievements.length}',
          ),

          const Divider(),

          _SectionHeader(title: 'Actions'),
          _ActionTile(
            icon: Icons.save,
            label: 'Manual Save',
            onTap: () async {
              await SaveService.save(gameState);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game saved!')),
                );
              }
            },
          ),
          _ActionTile(
            icon: Icons.delete_forever,
            label: 'Reset Game',
            color: Colors.red,
            onTap: () => _showResetDialog(context, ref),
          ),

          const Divider(),

          _SectionHeader(title: 'About'),
          const _InfoTile(
            label: 'Version',
            value: '0.2.0 (Phase 2)',
          ),
          const _InfoTile(
            label: 'Framework',
            value: 'Flutter + Riverpod',
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text(
          'This will permanently delete all progress. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SaveService.deleteSave();
              ref.read(gameProvider.notifier).loadState(GameState.initial());
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game reset!')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
