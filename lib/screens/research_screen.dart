import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/research_node.dart';
import 'package:mythical_cats/widgets/research_node_card.dart';

class ResearchScreen extends ConsumerWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foundationNodes = ResearchDefinitions.phase3Nodes
        .where((n) => n.branch == ResearchBranch.foundation)
        .toList();

    final resourceNodes = ResearchDefinitions.phase3Nodes
        .where((n) => n.branch == ResearchBranch.resource)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Foundation'),
              Tab(text: 'Resource'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBranchList(foundationNodes),
                _buildBranchList(resourceNodes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchList(List<ResearchNode> nodes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ResearchNodeCard(node: nodes[index]),
        );
      },
    );
  }
}
