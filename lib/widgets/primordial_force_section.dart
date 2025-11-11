import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';
import 'package:mythical_cats/widgets/primordial_upgrade_card.dart';

class PrimordialForceSection extends StatelessWidget {
  final PrimordialForce force;
  final Set<String> ownedUpgradeIds;
  final int availablePE;
  final Function(String upgradeId) onPurchase;

  const PrimordialForceSection({
    super.key,
    required this.force,
    required this.ownedUpgradeIds,
    required this.availablePE,
    required this.onPurchase,
  });

  Color get _forceColor {
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

  @override
  Widget build(BuildContext context) {
    final upgrades = PrimordialUpgradeDefinitions.getForceUpgrades(force);
    final ownedCount = upgrades.where((u) => ownedUpgradeIds.contains(u.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${force.icon} ${force.displayName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _forceColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                force.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$ownedCount/5 upgrades owned',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _forceColor,
                    ),
              ),
            ],
          ),
        ),
        // Divider
        Divider(
          color: _forceColor,
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
        const SizedBox(height: 8),
        // Upgrade cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: upgrades.map((upgrade) {
              final isOwned = ownedUpgradeIds.contains(upgrade.id);
              final isLocked = upgrade.tier > 1 &&
                  !ownedUpgradeIds.contains('${force.name}_${upgrade.tier - 1}');
              final canAfford = availablePE >= upgrade.cost;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PrimordialUpgradeCard(
                  upgradeId: upgrade.id,
                  force: force,
                  tier: upgrade.tier,
                  name: upgrade.name,
                  effect: upgrade.effect,
                  cost: upgrade.cost,
                  isOwned: isOwned,
                  canAfford: canAfford,
                  isLocked: isLocked,
                  onPurchase: () => onPurchase(upgrade.id),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
