import 'dart:math' as Math;
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/resource_type.dart';

/// Defines the properties of a building type
class BuildingDefinition {
  final BuildingType type;
  final Map<ResourceType, double> baseCost;
  final double costMultiplier;
  final double baseProduction;
  final ResourceType productionType;

  const BuildingDefinition({
    required this.type,
    required this.baseCost,
    this.costMultiplier = 1.15,
    required this.baseProduction,
    this.productionType = ResourceType.cats,
  });

  /// Calculate cost for buying the next building of this type
  Map<ResourceType, double> calculateCost(int currentCount) {
    return baseCost.map(
      (resource, cost) => MapEntry(
        resource,
        cost * Math.pow(costMultiplier, currentCount),
      ),
    );
  }

  /// Calculate cost for buying multiple buildings
  Map<ResourceType, double> calculateBulkCost(int currentCount, int amount) {
    final costs = <ResourceType, double>{};

    for (int i = 0; i < amount; i++) {
      final nextCost = calculateCost(currentCount + i);
      for (final entry in nextCost.entries) {
        costs[entry.key] = (costs[entry.key] ?? 0) + entry.value;
      }
    }

    return costs;
  }
}

/// All building definitions
class BuildingDefinitions {
  static const smallShrine = BuildingDefinition(
    type: BuildingType.smallShrine,
    baseCost: {ResourceType.cats: 15},
    baseProduction: 0.1,
  );

  static const temple = BuildingDefinition(
    type: BuildingType.temple,
    baseCost: {ResourceType.cats: 100},
    baseProduction: 1.0,
  );

  static const grandSanctuary = BuildingDefinition(
    type: BuildingType.grandSanctuary,
    baseCost: {ResourceType.cats: 1000},
    baseProduction: 8.0,
  );

  static const messengerWaystation = BuildingDefinition(
    type: BuildingType.messengerWaystation,
    baseCost: {ResourceType.cats: 500, ResourceType.offerings: 100},
    baseProduction: 2.0,
  );

  static const hearthAltar = BuildingDefinition(
    type: BuildingType.hearthAltar,
    baseCost: {ResourceType.cats: 2000, ResourceType.offerings: 250},
    baseProduction: 0.5,
    productionType: ResourceType.offerings,
  );

  /// Get definition by type
  static BuildingDefinition get(BuildingType type) {
    switch (type) {
      case BuildingType.smallShrine:
        return smallShrine;
      case BuildingType.temple:
        return temple;
      case BuildingType.grandSanctuary:
        return grandSanctuary;
      case BuildingType.messengerWaystation:
        return messengerWaystation;
      case BuildingType.hearthAltar:
        return hearthAltar;
    }
  }

  /// All available building definitions
  static List<BuildingDefinition> get all => [
    smallShrine,
    temple,
    grandSanctuary,
    messengerWaystation,
    hearthAltar,
  ];
}
