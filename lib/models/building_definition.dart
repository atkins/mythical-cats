import 'dart:math' as math;
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
        cost * math.pow(costMultiplier, currentCount),
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

  static const harvestField = BuildingDefinition(
    type: BuildingType.harvestField,
    baseCost: {ResourceType.cats: 5000, ResourceType.offerings: 500},
    baseProduction: 1.0,
    productionType: ResourceType.prayers,
  );

  static const festivalGrounds = BuildingDefinition(
    type: BuildingType.festivalGrounds,
    baseCost: {ResourceType.cats: 15000, ResourceType.prayers: 1000},
    baseProduction: 5.0,
    productionType: ResourceType.cats,
  );

  // Phase 3 buildings
  static const academy = BuildingDefinition(
    type: BuildingType.academy,
    baseCost: {ResourceType.cats: 50000, ResourceType.prayers: 5000},
    baseProduction: 1.0,
    productionType: ResourceType.cats,
  );

  static const essenceRefinery = BuildingDefinition(
    type: BuildingType.essenceRefinery,
    baseCost: {ResourceType.cats: 100000, ResourceType.offerings: 10000},
    costMultiplier: 1.20,
    baseProduction: 0.5,
    productionType: ResourceType.divineEssence,
  );

  static const nectarBrewery = BuildingDefinition(
    type: BuildingType.nectarBrewery,
    baseCost: {ResourceType.cats: 1000000, ResourceType.divineEssence: 500},
    costMultiplier: 1.25,
    baseProduction: 0.1,
    productionType: ResourceType.ambrosia,
  );

  static const workshop = BuildingDefinition(
    type: BuildingType.workshop,
    baseCost: {ResourceType.cats: 250000, ResourceType.divineEssence: 100},
    baseProduction: 0,
    productionType: ResourceType.divineEssence, // For conversion tracking
  );

  static const warMonument = BuildingDefinition(
    type: BuildingType.warMonument,
    baseCost: {ResourceType.cats: 5000000, ResourceType.ambrosia: 1000},
    baseProduction: 1.0,
    productionType: ResourceType.conquestPoints,
  );

  // Athena buildings (Phase 5)
  static const hallOfWisdom = BuildingDefinition(
    type: BuildingType.hallOfWisdom,
    baseCost: {ResourceType.cats: 75000},
    baseProduction: 0.1,
    productionType: ResourceType.wisdom,
  );

  static const academyOfAthens = BuildingDefinition(
    type: BuildingType.academyOfAthens,
    baseCost: {ResourceType.cats: 500000},
    baseProduction: 0.8,
    productionType: ResourceType.wisdom,
  );

  static const strategyChamber = BuildingDefinition(
    type: BuildingType.strategyChamber,
    baseCost: {ResourceType.cats: 3000000},
    baseProduction: 5.0,
    productionType: ResourceType.wisdom,
  );

  static const oraclesArchive = BuildingDefinition(
    type: BuildingType.oraclesArchive,
    baseCost: {ResourceType.cats: 15000000},
    baseProduction: 25.0,
    productionType: ResourceType.wisdom,
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
      case BuildingType.harvestField:
        return harvestField;
      case BuildingType.festivalGrounds:
        return festivalGrounds;
      case BuildingType.academy:
        return academy;
      case BuildingType.essenceRefinery:
        return essenceRefinery;
      case BuildingType.nectarBrewery:
        return nectarBrewery;
      case BuildingType.workshop:
        return workshop;
      case BuildingType.warMonument:
        return warMonument;
      case BuildingType.hallOfWisdom:
        return hallOfWisdom;
      case BuildingType.academyOfAthens:
        return academyOfAthens;
      case BuildingType.strategyChamber:
        return strategyChamber;
      case BuildingType.oraclesArchive:
        return oraclesArchive;
    }
  }

  /// All available building definitions
  static List<BuildingDefinition> get all => [
    smallShrine,
    temple,
    grandSanctuary,
    messengerWaystation,
    hearthAltar,
    harvestField,
    festivalGrounds,
    academy,
    essenceRefinery,
    nectarBrewery,
    workshop,
    warMonument,
    hallOfWisdom,
    academyOfAthens,
    strategyChamber,
    oraclesArchive,
  ];
}
