import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PrestigeStatsPanel extends StatelessWidget {
  final int availablePE;
  final int totalPE;
  final int reincarnations;
  final PrimordialForce? activePatron;
  final Set<String> ownedUpgradeIds;
  final VoidCallback onTap;

  const PrestigeStatsPanel({
    super.key,
    required this.availablePE,
    required this.totalPE,
    required this.reincarnations,
    required this.activePatron,
    required this.ownedUpgradeIds,
    required this.onTap,
  });

  Color? _getPatronColor() {
    if (activePatron == null) return null;
    switch (activePatron!) {
      case PrimordialForce.chaos:
        return Colors.deepPurple;
      case PrimordialForce.gaia:
        return Colors.green;
      case PrimordialForce.nyx:
        return Colors.indigo;
      case PrimordialForce.erebus:
        return Colors.amber;
    }
  }

  String _getPatronBonusText() {
    if (activePatron == null) return 'No patron selected';

    final tier = ownedUpgradeIds
        .where((id) => id.startsWith('${activePatron!.name}_'))
        .length;
    final bonus = (0.5 + (tier * 0.1)) * 100;

    String effectText;
    switch (activePatron!) {
      case PrimordialForce.chaos:
        effectText = 'click power';
        break;
      case PrimordialForce.gaia:
        effectText = 'building production';
        break;
      case PrimordialForce.nyx:
        effectText = 'offline progression';
        break;
      case PrimordialForce.erebus:
        effectText = 'tier 2 production';
        break;
    }

    return '${activePatron!.icon} ${activePatron!.displayName}: +${bonus.toStringAsFixed(0)}% $effectText';
  }

  @override
  Widget build(BuildContext context) {
    // Hide panel if never reincarnated
    if (reincarnations == 0) {
      return const SizedBox.shrink();
    }

    final patronColor = _getPatronColor();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: patronColor != null
            ? BorderSide(color: patronColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.autorenew, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Prestige Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatRow(
                label: 'Available PE:',
                value: '$availablePE / $totalPE Total',
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: 'Reincarnations:',
                value: '$reincarnations',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: patronColor?.withOpacity(0.1) ?? Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getPatronBonusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: patronColor ?? Colors.grey.shade600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 11),
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
