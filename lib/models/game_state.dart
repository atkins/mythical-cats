import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';

/// Immutable game state
class GameState {
  final Map<ResourceType, double> resources;
  final Map<BuildingType, int> buildings;
  final Set<God> unlockedGods;
  final DateTime lastUpdate;
  final double totalCatsEarned; // For unlock tracking

  const GameState({
    required this.resources,
    required this.buildings,
    required this.unlockedGods,
    required this.lastUpdate,
    this.totalCatsEarned = 0,
  });

  /// Initial game state
  factory GameState.initial() {
    return GameState(
      resources: {
        ResourceType.cats: 0,
        ResourceType.offerings: 0,
        ResourceType.prayers: 0,
      },
      buildings: {},
      unlockedGods: {God.hermes},
      lastUpdate: DateTime.now(),
      totalCatsEarned: 0,
    );
  }

  /// Create a copy with modifications
  GameState copyWith({
    Map<ResourceType, double>? resources,
    Map<BuildingType, int>? buildings,
    Set<God>? unlockedGods,
    DateTime? lastUpdate,
    double? totalCatsEarned,
  }) {
    return GameState(
      resources: resources ?? Map.from(this.resources),
      buildings: buildings ?? Map.from(this.buildings),
      unlockedGods: unlockedGods ?? Set.from(this.unlockedGods),
      lastUpdate: lastUpdate ?? this.lastUpdate,
      totalCatsEarned: totalCatsEarned ?? this.totalCatsEarned,
    );
  }

  /// Get resource amount safely (returns 0 if not present)
  double getResource(ResourceType type) {
    return resources[type] ?? 0;
  }

  /// Get building count safely (returns 0 if not present)
  int getBuildingCount(BuildingType type) {
    return buildings[type] ?? 0;
  }

  /// Check if a god is unlocked
  bool hasUnlockedGod(God god) {
    return unlockedGods.contains(god);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'resources': resources.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'buildings': buildings.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'unlockedGods': unlockedGods.map((g) => g.name).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
      'totalCatsEarned': totalCatsEarned,
    };
  }

  /// Create from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      resources: (json['resources'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          ResourceType.values.firstWhere((e) => e.name == key),
          (value as num).toDouble(),
        ),
      ),
      buildings: (json['buildings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          BuildingType.values.firstWhere((e) => e.name == key),
          value as int,
        ),
      ),
      unlockedGods: (json['unlockedGods'] as List)
        .map((name) => God.values.firstWhere((e) => e.name == name))
        .toSet(),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      totalCatsEarned: (json['totalCatsEarned'] as num).toDouble(),
    );
  }
}
