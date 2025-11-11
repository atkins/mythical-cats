import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ResearchDefinitions', () {
    test('divineArchitecture1 has correct properties', () {
      const node = ResearchDefinitions.divineArchitecture1;
      expect(node.id, 'divine_architecture_1');
      expect(node.name, 'Divine Architecture I');
      expect(node.branch, ResearchBranch.foundation);
      expect(node.cost[ResourceType.cats], 5000);
      expect(node.cost[ResourceType.prayers], 1000);
      expect(node.prerequisites.isEmpty, true);
    });

    test('sacredGeometry requires divineArchitecture1', () {
      const node = ResearchDefinitions.sacredGeometry;
      expect(node.id, 'sacred_geometry');
      expect(node.prerequisites, ['divine_architecture_1']);
    });

    test('essenceRefinement has correct cost', () {
      const node = ResearchDefinitions.essenceRefinement;
      expect(node.cost[ResourceType.cats], 25000);
      expect(node.cost[ResourceType.prayers], 5000);
      expect(node.branch, ResearchBranch.resource);
    });

    test('all Foundation branch nodes exist', () {
      expect(ResearchDefinitions.divineArchitecture1, isNotNull);
      expect(ResearchDefinitions.sacredGeometry, isNotNull);
      expect(ResearchDefinitions.divineArchitecture2, isNotNull);
      expect(ResearchDefinitions.immortalCraftsmanship, isNotNull);
    });

    test('all Resource branch nodes exist', () {
      expect(ResearchDefinitions.essenceRefinement, isNotNull);
      expect(ResearchDefinitions.divineAlchemy, isNotNull);
      expect(ResearchDefinitions.nectarBrewing, isNotNull);
      expect(ResearchDefinitions.ambrosiaInfusion, isNotNull);
    });

    test('getById returns correct node', () {
      final node = ResearchDefinitions.getById('divine_architecture_1');
      expect(node?.id, 'divine_architecture_1');
    });

    test('getById returns null for invalid id', () {
      final node = ResearchDefinitions.getById('invalid_id');
      expect(node, isNull);
    });

    test('all nodes have unique IDs', () {
      final ids = ResearchDefinitions.all.map((n) => n.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });

    test('phase3Nodes returns Foundation and Resource branches only', () {
      final phase3 = ResearchDefinitions.phase3Nodes;
      expect(phase3.length, 8);

      final branches = phase3.map((n) => n.branch).toSet();
      expect(branches.contains(ResearchBranch.foundation), true);
      expect(branches.contains(ResearchBranch.resource), true);
      expect(branches.contains(ResearchBranch.automation), false);
    });
  });

  group('Knowledge Branch (Phase 5)', () {
    test('divineScholarship has correct properties', () {
      const node = ResearchDefinitions.divineScholarship;
      expect(node.id, 'divine_scholarship');
      expect(node.name, 'Divine Scholarship');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 75000);
      expect(node.cost[ResourceType.wisdom], 25);
      expect(node.prerequisites.isEmpty, true);
    });

    test('wisdomRefinement1 has correct properties and prerequisites', () {
      const node = ResearchDefinitions.wisdomRefinement1;
      expect(node.id, 'wisdom_refinement_1');
      expect(node.name, 'Wisdom Refinement I');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 200000);
      expect(node.cost[ResourceType.wisdom], 50);
      expect(node.prerequisites, contains('divine_scholarship'));
    });

    test('wisdomRefinement2 has correct properties and prerequisites', () {
      const node = ResearchDefinitions.wisdomRefinement2;
      expect(node.id, 'wisdom_refinement_2');
      expect(node.name, 'Wisdom Refinement II');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 1000000);
      expect(node.cost[ResourceType.wisdom], 150);
      expect(node.prerequisites, contains('wisdom_refinement_1'));
    });

    test('wisdomRefinement3 has correct properties and prerequisites', () {
      const node = ResearchDefinitions.wisdomRefinement3;
      expect(node.id, 'wisdom_refinement_3');
      expect(node.name, 'Wisdom Refinement III');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 5000000);
      expect(node.cost[ResourceType.wisdom], 500);
      expect(node.cost[ResourceType.divineEssence], 1000);
      expect(node.prerequisites, contains('wisdom_refinement_2'));
    });

    test('prophecyMastery1 has correct properties and prerequisites', () {
      const node = ResearchDefinitions.prophecyMastery1;
      expect(node.id, 'prophecy_mastery_1');
      expect(node.name, 'Prophecy Mastery I');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 500000);
      expect(node.cost[ResourceType.wisdom], 100);
      expect(node.prerequisites, contains('wisdom_refinement_1'));
    });

    test('prophecyMastery2 has correct properties and prerequisites', () {
      const node = ResearchDefinitions.prophecyMastery2;
      expect(node.id, 'prophecy_mastery_2');
      expect(node.name, 'Prophecy Mastery II');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 3000000);
      expect(node.cost[ResourceType.wisdom], 300);
      expect(node.cost[ResourceType.divineEssence], 500);
      expect(node.prerequisites, contains('prophecy_mastery_1'));
    });

    test('oraclesInsight has correct properties and prerequisites', () {
      const node = ResearchDefinitions.oraclesInsight;
      expect(node.id, 'oracles_insight');
      expect(node.name, 'Oracle\'s Insight');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 10000000);
      expect(node.cost[ResourceType.wisdom], 1000);
      expect(node.cost[ResourceType.divineEssence], 5000);
      expect(node.prerequisites, contains('prophecy_mastery_2'));
    });

    test('celestialMathematics has correct properties and prerequisites', () {
      const node = ResearchDefinitions.celestialMathematics;
      expect(node.id, 'celestial_mathematics');
      expect(node.name, 'Celestial Mathematics');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 15000000);
      expect(node.cost[ResourceType.wisdom], 2000);
      expect(node.cost[ResourceType.divineEssence], 10000);
      expect(node.prerequisites, contains('wisdom_refinement_3'));
    });

    test('all Knowledge branch nodes exist', () {
      expect(ResearchDefinitions.divineScholarship, isNotNull);
      expect(ResearchDefinitions.wisdomRefinement1, isNotNull);
      expect(ResearchDefinitions.wisdomRefinement2, isNotNull);
      expect(ResearchDefinitions.wisdomRefinement3, isNotNull);
      expect(ResearchDefinitions.prophecyMastery1, isNotNull);
      expect(ResearchDefinitions.prophecyMastery2, isNotNull);
      expect(ResearchDefinitions.oraclesInsight, isNotNull);
      expect(ResearchDefinitions.celestialMathematics, isNotNull);
    });

    test('Knowledge branch forms proper dependency chain', () {
      // Divine Scholarship is root (no prereqs)
      expect(ResearchDefinitions.divineScholarship.prerequisites.isEmpty, true);

      // First tier branches from Divine Scholarship
      expect(ResearchDefinitions.wisdomRefinement1.prerequisites,
          contains('divine_scholarship'));
      expect(ResearchDefinitions.prophecyMastery1.prerequisites,
          contains('wisdom_refinement_1'));

      // Second tier continues both paths
      expect(ResearchDefinitions.wisdomRefinement2.prerequisites,
          contains('wisdom_refinement_1'));
      expect(ResearchDefinitions.prophecyMastery2.prerequisites,
          contains('prophecy_mastery_1'));

      // Third tier culminates both paths
      expect(ResearchDefinitions.wisdomRefinement3.prerequisites,
          contains('wisdom_refinement_2'));
      expect(ResearchDefinitions.oraclesInsight.prerequisites,
          contains('prophecy_mastery_2'));
      expect(ResearchDefinitions.celestialMathematics.prerequisites,
          contains('wisdom_refinement_3'));
    });
  });
}
