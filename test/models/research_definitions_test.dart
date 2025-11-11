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
      // Note: This now includes essenceToWisdomConversion (Phase 5 extension)
      expect(phase3.length, 9);

      final branches = phase3.map((n) => n.branch).toSet();
      expect(branches.contains(ResearchBranch.foundation), true);
      expect(branches.contains(ResearchBranch.resource), true);
      expect(branches.contains(ResearchBranch.automation), false);
    });
  });

  group('Knowledge Branch', () {
    test('foundationsOfWisdom has correct properties', () {
      const node = ResearchDefinitions.foundationsOfWisdom;
      expect(node.id, 'foundations_of_wisdom');
      expect(node.name, 'Foundations of Wisdom');
      expect(node.description, 'Begin your journey into divine knowledge');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 10000);
      expect(node.cost[ResourceType.offerings], 100);
      expect(node.prerequisites.isEmpty, true);
    });

    test('scholarlyPursuitI has correct properties', () {
      const node = ResearchDefinitions.scholarlyPursuitI;
      expect(node.id, 'scholarly_pursuit_i');
      expect(node.name, 'Scholarly Pursuit I');
      expect(node.description, 'Enhance your pursuit of wisdom. +10% Wisdom production');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 50000);
      expect(node.cost[ResourceType.offerings], 500);
      expect(node.cost[ResourceType.wisdom], 50);
      expect(node.prerequisites, ['foundations_of_wisdom']);
    });

    test('scholarlyPursuitII has correct properties', () {
      const node = ResearchDefinitions.scholarlyPursuitII;
      expect(node.id, 'scholarly_pursuit_ii');
      expect(node.name, 'Scholarly Pursuit II');
      expect(node.description, 'Deepen your intellectual commitment. +15% Wisdom production');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 250000);
      expect(node.cost[ResourceType.offerings], 2000);
      expect(node.cost[ResourceType.wisdom], 200);
      expect(node.prerequisites, ['scholarly_pursuit_i']);
    });

    test('scholarlyPursuitIII has correct properties', () {
      const node = ResearchDefinitions.scholarlyPursuitIII;
      expect(node.id, 'scholarly_pursuit_iii');
      expect(node.name, 'Scholarly Pursuit III');
      expect(node.description, 'Master the art of knowledge accumulation. +20% Wisdom production');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 1000000);
      expect(node.cost[ResourceType.divineEssence], 5000);
      expect(node.cost[ResourceType.wisdom], 500);
      expect(node.prerequisites, ['scholarly_pursuit_ii']);
    });

    test('divineInsight has correct properties', () {
      const node = ResearchDefinitions.divineInsight;
      expect(node.id, 'divine_insight');
      expect(node.name, 'Divine Insight');
      expect(node.description, 'Channel Athena\'s divine intellect. Athena buildings +25% Wisdom');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 500000);
      expect(node.cost[ResourceType.divineEssence], 1000);
      expect(node.cost[ResourceType.wisdom], 50);
      expect(node.prerequisites, ['scholarly_pursuit_ii']);
    });

    test('philosophicalMethod has correct properties', () {
      const node = ResearchDefinitions.philosophicalMethod;
      expect(node.id, 'philosophical_method');
      expect(node.name, 'Philosophical Method');
      expect(node.description, 'Wisdom flows from enlightened deeds. Unlock passive Wisdom from achievements');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 2000000);
      expect(node.cost[ResourceType.divineEssence], 5000);
      expect(node.cost[ResourceType.wisdom], 200);
      expect(node.prerequisites, ['divine_insight']);
    });

    test('propheticConnection has correct properties', () {
      const node = ResearchDefinitions.propheticConnection;
      expect(node.id, 'prophetic_connection');
      expect(node.name, 'Prophetic Connection');
      expect(node.description, 'Bridge mortal wisdom to divine foresight. Prophecy costs -15%');
      expect(node.branch, ResearchBranch.knowledge);
      expect(node.cost[ResourceType.cats], 8000000);
      expect(node.cost[ResourceType.divineEssence], 20000);
      expect(node.cost[ResourceType.wisdom], 1000);
      expect(node.prerequisites, ['philosophical_method']);
    });
  });

  group('Extension Nodes', () {
    test('wisdomAutomation extends Automation branch', () {
      const node = ResearchDefinitions.wisdomAutomation;
      expect(node.id, 'wisdom_automation');
      expect(node.name, 'Wisdom Automation');
      expect(node.description, 'Athena and Apollo buildings gain +50% offline efficiency. Wisdom buildings +50% offline');
      expect(node.branch, ResearchBranch.automation);
      expect(node.cost[ResourceType.cats], 3000000);
      expect(node.cost[ResourceType.divineEssence], 10000);
      expect(node.cost[ResourceType.wisdom], 300);
      // Prerequisites will be set when automation branch is implemented
      expect(node.prerequisites.isEmpty, true);
    });

    test('athenasBlessing extends God Favor branch', () {
      const node = ResearchDefinitions.athenasBlessing;
      expect(node.id, 'athenas_blessing');
      expect(node.name, 'Athena\'s Blessing');
      expect(node.description, 'Channel the goddess of wisdom. +10% cats when Wisdom > 1000');
      expect(node.branch, ResearchBranch.godFavor);
      expect(node.cost[ResourceType.cats], 2500000);
      expect(node.cost[ResourceType.divineEssence], 8000);
      expect(node.cost[ResourceType.wisdom], 250);
      // Prerequisites will be set when god favor branch is implemented
      expect(node.prerequisites.isEmpty, true);
    });

    test('essenceToWisdomConversion extends Resource branch', () {
      const node = ResearchDefinitions.essenceToWisdomConversion;
      expect(node.id, 'essence_to_wisdom_conversion');
      expect(node.name, 'Essence to Wisdom Conversion');
      expect(node.description, 'Transform essence into knowledge. Unlock Workshop converter: 100 Divine Essence → 10 Wisdom');
      expect(node.branch, ResearchBranch.resource);
      expect(node.cost[ResourceType.cats], 5000000);
      expect(node.cost[ResourceType.divineEssence], 15000);
      expect(node.cost[ResourceType.wisdom], 500);
      expect(node.prerequisites, ['divine_alchemy']);
    });
  });
}
