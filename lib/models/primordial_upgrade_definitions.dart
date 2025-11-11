import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/primordial_upgrade.dart';

class PrimordialUpgradeDefinitions {
  // Chaos upgrades - Active Play / Click Power
  static const chaosI = PrimordialUpgrade(
    id: 'chaos_1',
    force: PrimordialForce.chaos,
    tier: 1,
    cost: 10,
    name: 'Chaotic Touch',
    effect: 'Cats gain +50% click power',
  );

  static const chaosII = PrimordialUpgrade(
    id: 'chaos_2',
    force: PrimordialForce.chaos,
    tier: 2,
    cost: 25,
    name: 'Frenzy Claws',
    effect: 'Cats gain +100% click power',
  );

  static const chaosIII = PrimordialUpgrade(
    id: 'chaos_3',
    force: PrimordialForce.chaos,
    tier: 3,
    cost: 50,
    name: 'Storm of Paws',
    effect: 'Cats gain +200% click power',
  );

  static const chaosIV = PrimordialUpgrade(
    id: 'chaos_4',
    force: PrimordialForce.chaos,
    tier: 4,
    cost: 100,
    name: 'Chaos Incarnate',
    effect: 'Cats gain +500% click power',
  );

  static const chaosV = PrimordialUpgrade(
    id: 'chaos_5',
    force: PrimordialForce.chaos,
    tier: 5,
    cost: 200,
    name: 'Primordial Fury',
    effect: 'Cats gain +1000% click power',
  );

  // Gaia upgrades - Building Production & Efficiency
  static const gaiaI = PrimordialUpgrade(
    id: 'gaia_1',
    force: PrimordialForce.gaia,
    tier: 1,
    cost: 10,
    name: 'Fertile Ground',
    effect: 'All buildings produce +25% resources',
  );

  static const gaiaII = PrimordialUpgrade(
    id: 'gaia_2',
    force: PrimordialForce.gaia,
    tier: 2,
    cost: 25,
    name: 'Abundant Harvest',
    effect: 'All buildings produce +50% resources',
  );

  static const gaiaIII = PrimordialUpgrade(
    id: 'gaia_3',
    force: PrimordialForce.gaia,
    tier: 3,
    cost: 50,
    name: 'Nature\'s Bounty',
    effect: 'All buildings produce +100% resources',
  );

  static const gaiaIV = PrimordialUpgrade(
    id: 'gaia_4',
    force: PrimordialForce.gaia,
    tier: 4,
    cost: 100,
    name: 'Verdant Empire',
    effect: 'All buildings produce +250% resources',
  );

  static const gaiaV = PrimordialUpgrade(
    id: 'gaia_5',
    force: PrimordialForce.gaia,
    tier: 5,
    cost: 200,
    name: 'Eternal Spring',
    effect: 'All buildings produce +500% resources',
  );

  // Nyx upgrades - Offline Progression & Time
  static const nyxI = PrimordialUpgrade(
    id: 'nyx_1',
    force: PrimordialForce.nyx,
    tier: 1,
    cost: 10,
    name: 'Twilight Dreams',
    effect: 'Offline production +50% faster',
  );

  static const nyxII = PrimordialUpgrade(
    id: 'nyx_2',
    force: PrimordialForce.nyx,
    tier: 2,
    cost: 25,
    name: 'Moonlit Vigil',
    effect: 'Offline production +100% faster',
  );

  static const nyxIII = PrimordialUpgrade(
    id: 'nyx_3',
    force: PrimordialForce.nyx,
    tier: 3,
    cost: 50,
    name: 'Starfall Blessing',
    effect: 'Offline production +200% faster',
  );

  static const nyxIV = PrimordialUpgrade(
    id: 'nyx_4',
    force: PrimordialForce.nyx,
    tier: 4,
    cost: 100,
    name: 'Cosmic Timekeeper',
    effect: 'Offline production +500% faster',
  );

  static const nyxV = PrimordialUpgrade(
    id: 'nyx_5',
    force: PrimordialForce.nyx,
    tier: 5,
    cost: 200,
    name: 'Endless Night',
    effect: 'Offline production +1000% faster',
  );

  // Erebus upgrades - Tier 2 Resources & Wealth
  static const erebusI = PrimordialUpgrade(
    id: 'erebus_1',
    force: PrimordialForce.erebus,
    tier: 1,
    cost: 10,
    name: 'Shadow Wealth',
    effect: 'Tier 2 resources +25% more valuable',
  );

  static const erebusII = PrimordialUpgrade(
    id: 'erebus_2',
    force: PrimordialForce.erebus,
    tier: 2,
    cost: 25,
    name: 'Dark Prosperity',
    effect: 'Tier 2 resources +50% more valuable',
  );

  static const erebusIII = PrimordialUpgrade(
    id: 'erebus_3',
    force: PrimordialForce.erebus,
    tier: 3,
    cost: 50,
    name: 'Void Treasury',
    effect: 'Tier 2 resources +100% more valuable',
  );

  static const erebusIV = PrimordialUpgrade(
    id: 'erebus_4',
    force: PrimordialForce.erebus,
    tier: 4,
    cost: 100,
    name: 'Abyssal Riches',
    effect: 'Tier 2 resources +250% more valuable',
  );

  static const erebusV = PrimordialUpgrade(
    id: 'erebus_5',
    force: PrimordialForce.erebus,
    tier: 5,
    cost: 200,
    name: 'Primordial Fortune',
    effect: 'Tier 2 resources +500% more valuable',
  );

  // Getter for all upgrades
  static List<PrimordialUpgrade> get all => [
        chaosI,
        chaosII,
        chaosIII,
        chaosIV,
        chaosV,
        gaiaI,
        gaiaII,
        gaiaIII,
        gaiaIV,
        gaiaV,
        nyxI,
        nyxII,
        nyxIII,
        nyxIV,
        nyxV,
        erebusI,
        erebusII,
        erebusIII,
        erebusIV,
        erebusV,
      ];

  // Get upgrades for a specific force
  static List<PrimordialUpgrade> getForceUpgrades(PrimordialForce force) {
    return all.where((upgrade) => upgrade.force == force).toList();
  }

  // Get upgrade by ID
  static PrimordialUpgrade? getById(String id) {
    try {
      return all.firstWhere((upgrade) => upgrade.id == id);
    } catch (e) {
      return null;
    }
  }
}
