import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/models/resource_type.dart';

class ResearchDefinitions {
  // Foundation Branch
  static const divineArchitecture1 = ResearchNode(
    id: 'divine_architecture_1',
    name: 'Divine Architecture I',
    description: 'Unlock advanced shrine designs and construction techniques.',
    branch: ResearchBranch.foundation,
    cost: {
      ResourceType.cats: 5000,
      ResourceType.prayers: 1000,
    },
    prerequisites: [],
  );

  static const sacredGeometry = ResearchNode(
    id: 'sacred_geometry',
    name: 'Sacred Geometry',
    description: 'Required for god-specific buildings. Unlock the mathematical principles of divine construction.',
    branch: ResearchBranch.foundation,
    cost: {
      ResourceType.cats: 10000,
      ResourceType.prayers: 2000,
    },
    prerequisites: ['divine_architecture_1'],
  );

  static const divineArchitecture2 = ResearchNode(
    id: 'divine_architecture_2',
    name: 'Divine Architecture II',
    description: 'Unlock the highest tier of shrines and temples.',
    branch: ResearchBranch.foundation,
    cost: {
      ResourceType.cats: 50000,
      ResourceType.prayers: 5000,
    },
    prerequisites: ['sacred_geometry'],
  );

  static const immortalCraftsmanship = ResearchNode(
    id: 'immortal_craftsmanship',
    name: 'Immortal Craftsmanship',
    description: 'Unlock Workshops for resource conversion.',
    branch: ResearchBranch.foundation,
    cost: {
      ResourceType.cats: 100000,
      ResourceType.prayers: 10000,
      ResourceType.divineEssence: 1000,
    },
    prerequisites: ['divine_architecture_2'],
  );

  // Resource Branch
  static const essenceRefinement = ResearchNode(
    id: 'essence_refinement',
    name: 'Essence Refinement',
    description: 'Unlock Divine Essence production through Essence Refineries.',
    branch: ResearchBranch.resource,
    cost: {
      ResourceType.cats: 25000,
      ResourceType.prayers: 5000,
    },
    prerequisites: [],
  );

  static const divineAlchemy = ResearchNode(
    id: 'divine_alchemy',
    name: 'Divine Alchemy',
    description: '+25% Divine Essence conversion efficiency in Workshops.',
    branch: ResearchBranch.resource,
    cost: {
      ResourceType.cats: 100000,
      ResourceType.divineEssence: 50,
    },
    prerequisites: ['essence_refinement'],
  );

  static const nectarBrewing = ResearchNode(
    id: 'nectar_brewing',
    name: 'Nectar Brewing',
    description: 'Unlock Ambrosia production through Nectar Breweries.',
    branch: ResearchBranch.resource,
    cost: {
      ResourceType.cats: 500000,
      ResourceType.divineEssence: 500,
    },
    prerequisites: ['divine_alchemy'],
  );

  static const ambrosiaInfusion = ResearchNode(
    id: 'ambrosia_infusion',
    name: 'Ambrosia Infusion',
    description: '+50% Ambrosia production in Nectar Breweries.',
    branch: ResearchBranch.resource,
    cost: {
      ResourceType.cats: 1000000,
      ResourceType.ambrosia: 100,
    },
    prerequisites: ['nectar_brewing'],
  );

  // Knowledge Branch (Phase 5)
  static const foundationsOfWisdom = ResearchNode(
    id: 'foundations_of_wisdom',
    name: 'Foundations of Wisdom',
    description: 'Begin your journey into divine knowledge',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 10000,
      ResourceType.offerings: 100,
    },
    prerequisites: [],
  );

  static const scholarlyPursuitI = ResearchNode(
    id: 'scholarly_pursuit_i',
    name: 'Scholarly Pursuit I',
    description: 'Enhance your pursuit of wisdom. +10% Wisdom production',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 50000,
      ResourceType.offerings: 500,
      ResourceType.wisdom: 50,
    },
    prerequisites: ['foundations_of_wisdom'],
  );

  static const scholarlyPursuitII = ResearchNode(
    id: 'scholarly_pursuit_ii',
    name: 'Scholarly Pursuit II',
    description: 'Deepen your intellectual commitment. +15% Wisdom production',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 250000,
      ResourceType.offerings: 2000,
      ResourceType.wisdom: 200,
    },
    prerequisites: ['scholarly_pursuit_i'],
  );

  static const scholarlyPursuitIII = ResearchNode(
    id: 'scholarly_pursuit_iii',
    name: 'Scholarly Pursuit III',
    description: 'Master the art of knowledge accumulation. +20% Wisdom production',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 1000000,
      ResourceType.divineEssence: 5000,
      ResourceType.wisdom: 500,
    },
    prerequisites: ['scholarly_pursuit_ii'],
  );

  static const divineInsight = ResearchNode(
    id: 'divine_insight',
    name: 'Divine Insight',
    description: 'Channel Athena\'s divine intellect. Athena buildings +25% Wisdom',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 500000,
      ResourceType.divineEssence: 1000,
      ResourceType.wisdom: 50,
    },
    prerequisites: ['scholarly_pursuit_ii'],
  );

  static const philosophicalMethod = ResearchNode(
    id: 'philosophical_method',
    name: 'Philosophical Method',
    description: 'Wisdom flows from enlightened deeds. Unlock passive Wisdom from achievements',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 2000000,
      ResourceType.divineEssence: 5000,
      ResourceType.wisdom: 200,
    },
    prerequisites: ['divine_insight'],
  );

  static const propheticConnection = ResearchNode(
    id: 'prophetic_connection',
    name: 'Prophetic Connection',
    description: 'Bridge mortal wisdom to divine foresight. Prophecy costs -15%',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 8000000,
      ResourceType.divineEssence: 20000,
      ResourceType.wisdom: 1000,
    },
    prerequisites: ['philosophical_method'],
  );

  // Extension Nodes (Phase 5)
  static const wisdomAutomation = ResearchNode(
    id: 'wisdom_automation',
    name: 'Wisdom Automation',
    description: 'Athena and Apollo buildings gain +50% offline efficiency. Wisdom buildings +50% offline',
    branch: ResearchBranch.automation,
    cost: {
      ResourceType.cats: 3000000,
      ResourceType.divineEssence: 10000,
      ResourceType.wisdom: 300,
    },
    prerequisites: [], // Will be set when automation branch exists
  );

  static const athenasBlessing = ResearchNode(
    id: 'athenas_blessing',
    name: 'Athena\'s Blessing',
    description: 'Channel the goddess of wisdom. +10% cats when Wisdom > 1000',
    branch: ResearchBranch.godFavor,
    cost: {
      ResourceType.cats: 2500000,
      ResourceType.divineEssence: 8000,
      ResourceType.wisdom: 250,
    },
    prerequisites: [], // Will be set when god favor branch exists
  );

  static const essenceToWisdomConversion = ResearchNode(
    id: 'essence_to_wisdom_conversion',
    name: 'Essence to Wisdom Conversion',
    description: 'Transform essence into knowledge. Unlock Workshop converter: 100 Divine Essence → 10 Wisdom',
    branch: ResearchBranch.resource,
    cost: {
      ResourceType.cats: 5000000,
      ResourceType.divineEssence: 15000,
      ResourceType.wisdom: 500,
    },
    prerequisites: ['divine_alchemy'],
  );

  /// All research nodes
  static List<ResearchNode> get all => [
        divineArchitecture1,
        sacredGeometry,
        divineArchitecture2,
        immortalCraftsmanship,
        essenceRefinement,
        divineAlchemy,
        nectarBrewing,
        ambrosiaInfusion,
        foundationsOfWisdom,
        scholarlyPursuitI,
        scholarlyPursuitII,
        scholarlyPursuitIII,
        divineInsight,
        philosophicalMethod,
        propheticConnection,
        wisdomAutomation,
        athenasBlessing,
        essenceToWisdomConversion,
      ];

  /// Get node by ID
  static ResearchNode? getById(String id) {
    try {
      return all.firstWhere((node) => node.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Phase 3 nodes (Foundation + Resource branches only)
  static List<ResearchNode> get phase3Nodes => all.where((node) {
        return node.branch == ResearchBranch.foundation ||
            node.branch == ResearchBranch.resource;
      }).toList();
}
