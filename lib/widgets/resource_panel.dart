import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resource_type.dart';
import '../providers/game_provider.dart';
import '../utils/number_formatter.dart';

class ResourcePanel extends ConsumerWidget {
  const ResourcePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    // Get all resources that have a non-zero value or are important to display
    final resourcesToShow = [
      ResourceType.cats,
      ResourceType.prayers,
      ResourceType.offerings,
      ResourceType.divineEssence,
      ResourceType.ambrosia,
      ResourceType.wisdom,
      ResourceType.conquestPoints,
    ].where((type) {
      final value = gameState.getResource(type);
      // Always show cats, prayers, and offerings
      // Show others only if they have a value > 0
      return type == ResourceType.cats ||
          type == ResourceType.prayers ||
          type == ResourceType.offerings ||
          value > 0;
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Resources',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: resourcesToShow.map((type) {
                final value = gameState.getResource(type);
                return _ResourceChip(
                  icon: type.icon,
                  label: type.displayName,
                  value: value,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceChip extends StatelessWidget {
  final String icon;
  final String label;
  final double value;

  const _ResourceChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
              ),
              Text(
                NumberFormatter.format(value),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
