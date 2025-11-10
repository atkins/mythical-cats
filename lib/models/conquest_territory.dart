import 'package:mythical_cats/models/resource_type.dart';

/// A territory that can be conquered for production bonuses
class ConquestTerritory {
  final String id;
  final String name;
  final double cost; // Conquest Points required
  final Map<ResourceType, double> productionBonus; // Multiplier bonuses
  final String? prerequisite; // Territory ID that must be conquered first

  const ConquestTerritory({
    required this.id,
    required this.name,
    required this.cost,
    required this.productionBonus,
    this.prerequisite,
  });
}
