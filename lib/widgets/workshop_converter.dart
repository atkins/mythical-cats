import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/building_type.dart';
import '../models/resource_type.dart';
import '../providers/game_provider.dart';
import '../utils/number_formatter.dart';

class WorkshopConverter extends ConsumerStatefulWidget {
  const WorkshopConverter({super.key});

  @override
  ConsumerState<WorkshopConverter> createState() => _WorkshopConverterState();
}

class _WorkshopConverterState extends ConsumerState<WorkshopConverter> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final hasWorkshop = gameState.getBuildingCount(BuildingType.workshop) > 0;
    final offerings = gameState.getResource(ResourceType.offerings);
    final hasDivineAlchemy = gameState.hasCompletedResearch('divine_alchemy');
    final conversionRatio = hasDivineAlchemy ? 8.0 : 10.0;

    if (!hasWorkshop) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Build a Workshop to convert Offerings into Divine Essence'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workshop Conversion',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Convert Offerings to Divine Essence (${conversionRatio.toStringAsFixed(0)}:1 ratio)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (hasDivineAlchemy)
              Text(
                'Divine Alchemy research active: Improved ratio!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            Text('Available Offerings: ${NumberFormatter.format(offerings)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Offerings to convert',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: offerings > 0
                      ? () {
                          final amount = double.tryParse(_controller.text);
                          if (amount != null && amount > 0) {
                            final success = ref
                                .read(gameProvider.notifier)
                                .convertInWorkshop(amount);
                            if (success) {
                              _controller.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Converted ${NumberFormatter.format(amount)} Offerings to '
                                    '${NumberFormatter.format(amount / conversionRatio)} Divine Essence',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Conversion failed'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Convert'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
