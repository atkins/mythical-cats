import 'package:flutter/material.dart';
import 'package:mythical_cats/models/prophecy.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class ProphecyCard extends StatelessWidget {
  final ProphecyType prophecy;
  final double currentWisdom;
  final bool isOnCooldown;
  final Duration cooldownRemaining;
  final bool isActive;
  final VoidCallback onActivate;

  const ProphecyCard({
    super.key,
    required this.prophecy,
    required this.currentWisdom,
    required this.isOnCooldown,
    required this.cooldownRemaining,
    required this.isActive,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = currentWisdom >= prophecy.wisdomCost;
    final canActivate = !isOnCooldown && canAfford;

    return Card(
      elevation: isActive ? 4 : 2,
      color: isActive ? Colors.amber.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active indicator
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isActive) const SizedBox(height: 8),

            // Prophecy name
            Text(
              prophecy.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
            ),
            const SizedBox(height: 4),

            // Description
            Expanded(
              child: Text(
                prophecy.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),

            // Wisdom cost
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.purple, size: 16),
                const SizedBox(width: 4),
                Text(
                  NumberFormatter.format(prophecy.wisdomCost),
                  style: TextStyle(
                    color: canAfford ? Colors.black : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Cooldown or Activate button
            if (isOnCooldown)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatCooldown(cooldownRemaining),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: canActivate ? onActivate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Activate'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCooldown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
