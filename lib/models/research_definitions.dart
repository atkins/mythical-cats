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
