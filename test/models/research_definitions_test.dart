import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ResearchDefinitions', () {
    test('divineArchitecture1 has correct properties', () {
      final node = ResearchDefinitions.divineArchitecture1;
      expect(node.id, 'divine_architecture_1');
      expect(node.name, 'Divine Architecture I');
      expect(node.branch, ResearchBranch.foundation);
      expect(node.cost[ResourceType.cats], 5000);
      expect(node.cost[ResourceType.prayers], 1000);
      expect(node.prerequisites.isEmpty, true);
    });

    test('sacredGeometry requires divineArchitecture1', () {
      final node = ResearchDefinitions.sacredGeometry;
      expect(node.id, 'sacred_geometry');
      expect(node.prerequisites, ['divine_architecture_1']);
    });

    test('essenceRefinement has correct cost', () {
      final node = ResearchDefinitions.essenceRefinement;
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
}
