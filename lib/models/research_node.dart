import 'package:mythical_cats/models/resource_type.dart';

/// Research tree branches
enum ResearchBranch {
  foundation,
  resource,
  automation,
  godFavor,
  advanced,
  knowledge;

  String get displayName {
    switch (this) {
      case ResearchBranch.foundation:
        return 'Foundation';
      case ResearchBranch.resource:
        return 'Resource';
      case ResearchBranch.automation:
        return 'Automation';
      case ResearchBranch.godFavor:
        return 'God Favor';
      case ResearchBranch.advanced:
        return 'Advanced';
      case ResearchBranch.knowledge:
        return 'Knowledge';
    }
  }
}

/// A single node in the research tree
class ResearchNode {
  final String id;
  final String name;
  final String description;
  final ResearchBranch branch;
  final Map<ResourceType, double> cost;
  final List<String> prerequisites;

  const ResearchNode({
    required this.id,
    required this.name,
    required this.description,
    required this.branch,
    required this.cost,
    this.prerequisites = const [],
  });
}
