import 'package:mythical_cats/models/conquest_territory.dart';
import 'package:mythical_cats/models/resource_type.dart';

class ConquestDefinitions {
  static const northernWilds = ConquestTerritory(
    id: 'northern_wilds',
    name: 'Northern Wilds',
    cost: 100,
    productionBonus: {ResourceType.cats: 0.05},
    prerequisite: null,
  );

  static const easternMountains = ConquestTerritory(
    id: 'eastern_mountains',
    name: 'Eastern Mountains',
    cost: 500,
    productionBonus: {ResourceType.offerings: 0.10},
    prerequisite: 'northern_wilds',
  );

  static const southernSeas = ConquestTerritory(
    id: 'southern_seas',
    name: 'Southern Seas',
    cost: 2500,
    productionBonus: {
      ResourceType.cats: 0.25,
      ResourceType.offerings: 0.25,
      ResourceType.prayers: 0.25,
    },
    prerequisite: 'eastern_mountains',
  );

  static const westernDeserts = ConquestTerritory(
    id: 'western_deserts',
    name: 'Western Deserts',
    cost: 10000,
    productionBonus: {ResourceType.divineEssence: 0.15},
    prerequisite: 'southern_seas',
  );

  static const centralCitadel = ConquestTerritory(
    id: 'central_citadel',
    name: 'Central Citadel',
    cost: 50000,
    productionBonus: {ResourceType.cats: 0.50},
    prerequisite: 'western_deserts',
  );

  static const underworldGates = ConquestTerritory(
    id: 'underworld_gates',
    name: 'Underworld Gates',
    cost: 250000,
    productionBonus: {ResourceType.prayers: 0.30},
    prerequisite: 'central_citadel',
  );

  static const olympusFoothills = ConquestTerritory(
    id: 'olympus_foothills',
    name: 'Olympus Foothills',
    cost: 1000000,
    productionBonus: {
      ResourceType.cats: 0.75,
      ResourceType.offerings: 0.75,
      ResourceType.prayers: 0.75,
    },
    prerequisite: 'underworld_gates',
  );

  static const titansRealm = ConquestTerritory(
    id: 'titans_realm',
    name: "Titan's Realm",
    cost: 5000000,
    productionBonus: {
      ResourceType.cats: 1.0,
      ResourceType.offerings: 1.0,
      ResourceType.prayers: 1.0,
    },
    prerequisite: 'olympus_foothills',
  );

  // Phase 5 territories (unlocked when Apollo is unlocked)
  static const academyOfAthens = ConquestTerritory(
    id: 'academy_of_athens',
    name: 'Academy of Athens',
    cost: 10000000,
    productionBonus: {ResourceType.wisdom: 0.50}, // +50% Wisdom (200K per 1%)
    prerequisite: 'titans_realm',
  );

  static const oracleOfDelphi = ConquestTerritory(
    id: 'oracle_of_delphi',
    name: 'Oracle of Delphi',
    cost: 2500000,
    productionBonus: {ResourceType.wisdom: 0.10},
    prerequisite: 'titans_realm',
  );

  static const libraryOfAlexandria = ConquestTerritory(
    id: 'library_of_alexandria',
    name: 'Library of Alexandria',
    cost: 5000000,
    productionBonus: {ResourceType.wisdom: 0.25},
    prerequisite: 'titans_realm',
  );

  /// All territories
  static List<ConquestTerritory> get all => [
        northernWilds,
        easternMountains,
        southernSeas,
        westernDeserts,
        centralCitadel,
        underworldGates,
        olympusFoothills,
        titansRealm,
        academyOfAthens,
        oracleOfDelphi,
        libraryOfAlexandria,
      ];

  /// Get territory by ID
  static ConquestTerritory? getById(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
