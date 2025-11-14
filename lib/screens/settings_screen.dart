import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/services/save_service.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mythical_cats/widgets/compact_resource_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const String _devModeKey = 'developer_mode_enabled';
  static const String _cheatCode = 'idkfa';

  final TextEditingController _cheatCodeController = TextEditingController();
  bool _devModeEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevModeState();
    _cheatCodeController.addListener(_checkCheatCode);
  }

  @override
  void dispose() {
    _cheatCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadDevModeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _devModeEnabled = prefs.getBool(_devModeKey) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleDevMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModeKey, enabled);
    setState(() {
      _devModeEnabled = enabled;
    });
  }

  void _checkCheatCode() {
    if (_cheatCodeController.text.toLowerCase() == _cheatCode) {
      _toggleDevMode(true);
      _cheatCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Developer mode activated!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gameState = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Stats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const CompactResourceBar(),
          Expanded(
            child: ListView(
              children: [
          const _SectionHeader(title: 'Statistics'),
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

          const _SectionHeader(title: 'Actions'),
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

          // Developer Tools Section (only visible when unlocked)
          if (_devModeEnabled) ...[
            const Divider(),
            _DeveloperSection(
              onLock: () => _toggleDevMode(false),
            ),
          ],

          const Divider(),

          const _SectionHeader(title: 'About'),
          const _InfoTile(
            label: 'Version',
            value: '0.2.0 (Phase 2)',
          ),
          const _InfoTile(
            label: 'Framework',
            value: 'Flutter + Riverpod',
          ),

          // Hidden cheat code input (only visible when NOT in dev mode)
          if (!_devModeEnabled)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _cheatCodeController,
                decoration: const InputDecoration(
                  hintText: 'Enter code...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                autocorrect: false,
                enableSuggestions: false,
              ),
            ),
              ],
            ),
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

class _DeveloperSection extends ConsumerWidget {
  final VoidCallback onLock;

  const _DeveloperSection({required this.onLock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Header with lock button
        Container(
          color: Colors.orange.shade100,
          child: ListTile(
            leading: const Icon(Icons.code, color: Colors.orange),
            title: const Text(
              'Developer Tools',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.lock, color: Colors.orange),
              onPressed: onLock,
              tooltip: 'Lock Developer Tools',
            ),
          ),
        ),

        // Preset Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quick Presets',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetButton(
                    label: 'Early Game',
                    icon: Icons.play_arrow,
                    onPressed: () => _applyPreset(ref, _Preset.earlyGame),
                  ),
                  _PresetButton(
                    label: 'Mid Game',
                    icon: Icons.forward,
                    onPressed: () => _applyPreset(ref, _Preset.midGame),
                  ),
                  _PresetButton(
                    label: 'Late Game',
                    icon: Icons.fast_forward,
                    onPressed: () => _applyPreset(ref, _Preset.lateGame),
                  ),
                  _PresetButton(
                    label: 'Endgame',
                    icon: Icons.star,
                    onPressed: () => _applyPreset(ref, _Preset.endgame),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(),

        // Resource Controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Resources',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _ResourceButton(
                label: '+1K Cats',
                onPressed: () => _addResource(ref, ResourceType.cats, 1000),
              ),
              _ResourceButton(
                label: '+1M Cats',
                onPressed: () => _addResource(ref, ResourceType.cats, 1000000),
              ),
              _ResourceButton(
                label: '+1B Cats',
                onPressed: () => _addResource(ref, ResourceType.cats, 1000000000),
              ),
              _ResourceButton(
                label: '+1K Prayers',
                onPressed: () => _addResource(ref, ResourceType.prayers, 1000),
              ),
              _ResourceButton(
                label: '+1K Offerings',
                onPressed: () => _addResource(ref, ResourceType.offerings, 1000),
              ),
              _ResourceButton(
                label: '+100 Wisdom',
                onPressed: () => _addResource(ref, ResourceType.wisdom, 100),
              ),
            ],
          ),
        ),

        const Divider(),

        // Quick Unlock Actions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _unlockAllGods(ref),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Unlock All Gods'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _maxOutBuildings(ref),
                icon: const Icon(Icons.apartment),
                label: const Text('Max All Buildings (x10 each)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyPreset(WidgetRef ref, _Preset preset) {
    final notifier = ref.read(gameProvider.notifier);
    final currentState = ref.read(gameProvider);

    GameState newState;
    switch (preset) {
      case _Preset.earlyGame:
        newState = currentState.copyWith(
          resources: {
            ResourceType.cats: 1000,
            ResourceType.prayers: 100,
            ResourceType.offerings: 50,
            ResourceType.wisdom: 0,
          },
          totalCatsEarned: 1000,
        );
        break;
      case _Preset.midGame:
        newState = currentState.copyWith(
          resources: {
            ResourceType.cats: 1000000,
            ResourceType.prayers: 10000,
            ResourceType.offerings: 5000,
            ResourceType.wisdom: 100,
          },
          totalCatsEarned: 5000000,
          unlockedGods: {God.hermes, God.athena},
        );
        break;
      case _Preset.lateGame:
        newState = currentState.copyWith(
          resources: {
            ResourceType.cats: 1000000000,
            ResourceType.prayers: 1000000,
            ResourceType.offerings: 500000,
            ResourceType.wisdom: 1000,
          },
          totalCatsEarned: 5000000000,
          unlockedGods: {God.hermes, God.athena, God.apollo},
        );
        break;
      case _Preset.endgame:
        newState = currentState.copyWith(
          resources: {
            ResourceType.cats: 1000000000000,
            ResourceType.prayers: 10000000,
            ResourceType.offerings: 5000000,
            ResourceType.wisdom: 10000,
          },
          totalCatsEarned: 10000000000000,
          unlockedGods: God.values.toSet(),
        );
        break;
    }

    notifier.loadState(newState);
  }

  void _addResource(WidgetRef ref, ResourceType type, double amount) {
    final notifier = ref.read(gameProvider.notifier);
    final currentState = ref.read(gameProvider);

    final updatedResources = Map<ResourceType, double>.from(currentState.resources);
    updatedResources[type] = (updatedResources[type] ?? 0) + amount;

    final newState = currentState.copyWith(
      resources: updatedResources,
      totalCatsEarned: type == ResourceType.cats
          ? currentState.totalCatsEarned + amount
          : currentState.totalCatsEarned,
    );

    notifier.loadState(newState);
  }

  void _unlockAllGods(WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final currentState = ref.read(gameProvider);

    final newState = currentState.copyWith(
      unlockedGods: God.values.toSet(),
    );

    notifier.loadState(newState);
  }

  void _maxOutBuildings(WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final currentState = ref.read(gameProvider);

    final maxedBuildings = <BuildingType, int>{};
    for (final building in BuildingType.values) {
      maxedBuildings[building] = 10;
    }

    final newState = currentState.copyWith(
      buildings: maxedBuildings,
    );

    notifier.loadState(newState);
  }
}

enum _Preset {
  earlyGame,
  midGame,
  lateGame,
  endgame,
}

class _PresetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PresetButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade200,
        foregroundColor: Colors.black87,
      ),
    );
  }
}

class _ResourceButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ResourceButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade100,
        ),
        child: Text(label),
      ),
    );
  }
}
