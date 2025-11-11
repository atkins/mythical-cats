import 'package:mythical_cats/models/primordial_force.dart';

class PrimordialUpgrade {
  final String id;
  final PrimordialForce force;
  final int tier;
  final int cost;
  final String name;
  final String effect;

  const PrimordialUpgrade({
    required this.id,
    required this.force,
    required this.tier,
    required this.cost,
    required this.name,
    required this.effect,
  });
}
