import 'package:flutter/material.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class BuildingCard extends StatelessWidget {
  final BuildingType type;
  final int owned;
  final Map<ResourceType, double> cost;
  final bool canAfford;
  final bool isUnlocked;
  final VoidCallback onBuy;

  const BuildingCard({
    super.key,
    required this.type,
    required this.owned,
    required this.cost,
    required this.canAfford,
    required this.isUnlocked,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final definition = BuildingDefinitions.get(type);

    if (!isUnlocked) {
      return _LockedCard(type: type);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: canAfford ? 4 : 1,
      child: InkWell(
        onTap: canAfford ? onBuy : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Owned: $owned',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Production:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${NumberFormatter.formatRate(definition.baseProduction)} ${definition.productionType.icon}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cost:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      ...cost.entries.map((entry) => Text(
                        '${NumberFormatter.format(entry.value)} ${entry.key.icon}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: canAfford ? Colors.black : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final BuildingType type;

  const _LockedCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Requires: ${type.requiredGod?.displayName ?? "Unknown"}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
