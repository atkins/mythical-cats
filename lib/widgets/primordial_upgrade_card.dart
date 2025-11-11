import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PrimordialUpgradeCard extends StatelessWidget {
  final String upgradeId;
  final PrimordialForce force;
  final int tier;
  final String name;
  final String effect;
  final int cost;
  final bool isOwned;
  final bool canAfford;
  final bool isLocked;
  final VoidCallback onPurchase;

  const PrimordialUpgradeCard({
    super.key,
    required this.upgradeId,
    required this.force,
    required this.tier,
    required this.name,
    required this.effect,
    required this.cost,
    required this.isOwned,
    required this.canAfford,
    required this.isLocked,
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
    return SizedBox(
      width: 140,
      height: 170,
      child: Card(
        elevation: isOwned ? 2 : (canAfford && !isLocked ? 4 : 1),
        color: isOwned ? _forceColor.withOpacity(0.2) : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLocked)
                    Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _forceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tier $tier',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Effect
              Text(
                effect,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Cost/Status
              if (isOwned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _forceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: _forceColor),
                      const SizedBox(width: 4),
                      const Text(
                        'Owned',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isLocked)
                Text(
                  'Requires Tier ${tier - 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Column(
                  children: [
                    Text(
                      '$cost PE',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford ? onPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _forceColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        child: const Text('Purchase'),
                      ),
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
