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

  // Knowledge Branch (Phase 5: Athena & Apollo)
  static const divineScholarship = ResearchNode(
    id: 'divine_scholarship',
    name: 'Divine Scholarship',
    description: 'Begin your journey into divine knowledge. Unlocks at Athena.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 75000,
      ResourceType.wisdom: 25,
    },
    prerequisites: [],
  );

  static const wisdomRefinement1 = ResearchNode(
    id: 'wisdom_refinement_1',
    name: 'Wisdom Refinement I',
    description: '+10% Wisdom production from all buildings.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 200000,
      ResourceType.wisdom: 50,
    },
    prerequisites: ['divine_scholarship'],
  );

  static const wisdomRefinement2 = ResearchNode(
    id: 'wisdom_refinement_2',
    name: 'Wisdom Refinement II',
    description: '+15% Wisdom production from all buildings.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 1000000,
      ResourceType.wisdom: 150,
    },
    prerequisites: ['wisdom_refinement_1'],
  );

  static const wisdomRefinement3 = ResearchNode(
    id: 'wisdom_refinement_3',
    name: 'Wisdom Refinement III',
    description: '+20% Wisdom production from all buildings.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 5000000,
      ResourceType.wisdom: 500,
      ResourceType.divineEssence: 1000,
    },
    prerequisites: ['wisdom_refinement_2'],
  );

  static const prophecyMastery1 = ResearchNode(
    id: 'prophecy_mastery_1',
    name: 'Prophecy Mastery I',
    description: 'Reduce prophecy Wisdom costs by 10%.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 500000,
      ResourceType.wisdom: 100,
    },
    prerequisites: ['wisdom_refinement_1'],
  );

  static const prophecyMastery2 = ResearchNode(
    id: 'prophecy_mastery_2',
    name: 'Prophecy Mastery II',
    description: 'Reduce prophecy cooldowns by 15%.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 3000000,
      ResourceType.wisdom: 300,
      ResourceType.divineEssence: 500,
    },
    prerequisites: ['prophecy_mastery_1'],
  );

  static const oraclesInsight = ResearchNode(
    id: 'oracles_insight',
    name: 'Oracle\'s Insight',
    description: 'Prophecies have a 25% chance to not trigger cooldown.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 10000000,
      ResourceType.wisdom: 1000,
      ResourceType.divineEssence: 5000,
    },
    prerequisites: ['prophecy_mastery_2'],
  );

  static const celestialMathematics = ResearchNode(
    id: 'celestial_mathematics',
    name: 'Celestial Mathematics',
    description: 'Athena and Apollo buildings produce +30% Wisdom.',
    branch: ResearchBranch.knowledge,
    cost: {
      ResourceType.cats: 15000000,
      ResourceType.wisdom: 2000,
      ResourceType.divineEssence: 10000,
    },
    prerequisites: ['wisdom_refinement_3'],
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
        divineScholarship,
        wisdomRefinement1,
        wisdomRefinement2,
        wisdomRefinement3,
        prophecyMastery1,
        prophecyMastery2,
        oraclesInsight,
        celestialMathematics,
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
