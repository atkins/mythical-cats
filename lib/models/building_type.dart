import 'package:mythical_cats/models/god.dart';

/// Types of buildings available in the game
enum BuildingType {
  // Generic shrine tiers
  smallShrine,
  temple,
  grandSanctuary,

  // God-specific buildings (Phase 1: just Hermes and Hestia)
  messengerWaystation, // Hermes
  hearthAltar, // Hestia
  harvestField, // Demeter
  festivalGrounds, // Dionysus

  // Phase 3 buildings
  academy,
  essenceRefinery,
  nectarBrewery,
  workshop,
  warMonument;

  /// Display name
  String get displayName {
    switch (this) {
      case BuildingType.smallShrine:
        return 'Small Shrine';
      case BuildingType.temple:
        return 'Temple';
      case BuildingType.grandSanctuary:
        return 'Grand Sanctuary';
      case BuildingType.messengerWaystation:
        return 'Messenger Waystation';
      case BuildingType.hearthAltar:
        return 'Hearth Altar';
      case BuildingType.harvestField:
        return 'Harvest Field';
      case BuildingType.festivalGrounds:
        return 'Festival Grounds';
      case BuildingType.academy:
        return 'Academy';
      case BuildingType.essenceRefinery:
        return 'Essence Refinery';
      case BuildingType.nectarBrewery:
        return 'Nectar Brewery';
      case BuildingType.workshop:
        return 'Workshop';
      case BuildingType.warMonument:
        return 'War Monument';
    }
  }

  /// Description
  String get description {
    switch (this) {
      case BuildingType.smallShrine:
        return 'A modest shrine that attracts divine cats';
      case BuildingType.temple:
        return 'An impressive temple dedicated to the gods';
      case BuildingType.grandSanctuary:
        return 'A magnificent sanctuary of divine power';
      case BuildingType.messengerWaystation:
        return 'Boosts offline progression efficiency';
      case BuildingType.hearthAltar:
        return 'Generates offerings from the hearth';
      case BuildingType.harvestField:
        return 'Fields blessed by Demeter that generate prayers';
      case BuildingType.festivalGrounds:
        return 'Celebration grounds that boost cat generation';
      case BuildingType.academy:
        return 'A center of learning that produces cats through knowledge';
      case BuildingType.essenceRefinery:
        return 'Refines offerings into divine essence';
      case BuildingType.nectarBrewery:
        return 'Brews divine essence into ambrosia';
      case BuildingType.workshop:
        return 'Converts offerings into divine essence';
      case BuildingType.warMonument:
        return 'A monument to divine warfare that generates conquest points';
    }
  }

  /// God required to unlock (null if available from start)
  God? get requiredGod {
    switch (this) {
      case BuildingType.smallShrine:
      case BuildingType.temple:
      case BuildingType.grandSanctuary:
        return null; // Available from start
      case BuildingType.messengerWaystation:
        return God.hermes;
      case BuildingType.hearthAltar:
        return God.hestia;
      case BuildingType.harvestField:
        return God.demeter;
      case BuildingType.festivalGrounds:
        return God.dionysus;
      case BuildingType.academy:
        return God.athena;
      case BuildingType.essenceRefinery:
        return God.athena;
      case BuildingType.nectarBrewery:
        return God.apollo;
      case BuildingType.workshop:
        return God.hephaestus;
      case BuildingType.warMonument:
        return God.ares;
    }
  }
}
