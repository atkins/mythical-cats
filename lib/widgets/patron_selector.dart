import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PatronSelector extends StatelessWidget {
  final PrimordialForce? activePatron;
  final Set<String> ownedUpgradeIds;
  final Function(PrimordialForce) onPatronSelected;

  const PatronSelector({
    super.key,
    required this.activePatron,
    required this.ownedUpgradeIds,
    required this.onPatronSelected,
  });

  bool _hasUpgrades(PrimordialForce force) {
    return ownedUpgradeIds.any((id) => id.startsWith('${force.name}_'));
  }

  Color _getForceColor(PrimordialForce force) {
    switch (force) {
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

  String _getEffectText(PrimordialForce force) {
    switch (force) {
      case PrimordialForce.chaos:
        return 'click power';
      case PrimordialForce.gaia:
        return 'building production';
      case PrimordialForce.nyx:
        return 'offline progression';
      case PrimordialForce.erebus:
        return 'tier 2 production';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Patron',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (activePatron != null)
              Row(
                children: [
                  Text(
                    '${activePatron!.icon} ${activePatron!.displayName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getForceColor(activePatron!),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    ': +${((0.5 + (ownedUpgradeIds.where((id) => id.startsWith('${activePatron!.name}_')).length * 0.1)) * 100).toStringAsFixed(0)}% ${_getEffectText(activePatron!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getForceColor(activePatron!),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              )
            else
              Text(
                'No patron selected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            const SizedBox(height: 16),
            // Force buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PrimordialForce.values.map((force) {
                final hasUpgrades = _hasUpgrades(force);
                final isActive = force == activePatron;

                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: ElevatedButton(
                    onPressed: hasUpgrades ? () => onPatronSelected(force) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? _getForceColor(force)
                          : Colors.grey.shade200,
                      foregroundColor: isActive ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              force.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            Text(force.displayName),
                          ],
                        ),
                        if (isActive)
                          const Text(
                            'Active',
                            style: TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
