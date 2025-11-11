import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ResearchNode', () {
    test('creates node with all properties', () {
      const node = ResearchNode(
        id: 'test_node',
        name: 'Test Node',
        description: 'A test research node',
        branch: ResearchBranch.foundation,
        cost: {ResourceType.cats: 1000},
        prerequisites: ['prerequisite_id'],
      );

      expect(node.id, 'test_node');
      expect(node.name, 'Test Node');
      expect(node.description, 'A test research node');
      expect(node.branch, ResearchBranch.foundation);
      expect(node.cost[ResourceType.cats], 1000);
      expect(node.prerequisites, ['prerequisite_id']);
    });

    test('node with no prerequisites', () {
      const node = ResearchNode(
        id: 'root_node',
        name: 'Root',
        description: 'Root node',
        branch: ResearchBranch.foundation,
        cost: {ResourceType.cats: 100},
        prerequisites: [],
      );

      expect(node.prerequisites.isEmpty, true);
    });
  });

  group('ResearchBranch', () {
    test('has all required branches', () {
      expect(ResearchBranch.foundation, isNotNull);
      expect(ResearchBranch.resource, isNotNull);
      expect(ResearchBranch.automation, isNotNull);
      expect(ResearchBranch.godFavor, isNotNull);
      expect(ResearchBranch.advanced, isNotNull);
      expect(ResearchBranch.knowledge, isNotNull);
    });

    test('has display names', () {
      expect(ResearchBranch.foundation.displayName, 'Foundation');
      expect(ResearchBranch.resource.displayName, 'Resource');
      expect(ResearchBranch.automation.displayName, 'Automation');
      expect(ResearchBranch.godFavor.displayName, 'God Favor');
      expect(ResearchBranch.advanced.displayName, 'Advanced');
      expect(ResearchBranch.knowledge.displayName, 'Knowledge');
    });
  });
}
