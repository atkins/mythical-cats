import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/prophecy.dart';

/// Immutable game state
class GameState {
  final Map<ResourceType, double> resources;
  final Map<BuildingType, int> buildings;
  final Set<God> unlockedGods;
  final DateTime lastUpdate;
  final double totalCatsEarned; // For unlock tracking
  final Set<String> unlockedAchievements;
  final Set<String> completedResearch;
  final Set<String> conqueredTerritories;
  final ReincarnationState reincarnationState;
  final ProphecyState prophecyState;
  final double lifetimeWisdom; // Lifetime total wisdom accumulated (NOT current balance)
  final int lifetimePropheciesActivated; // Count of times any prophecy has been activated

  const GameState({
    required this.resources,
    required this.buildings,
    required this.unlockedGods,
    required this.lastUpdate,
    this.totalCatsEarned = 0,
    this.unlockedAchievements = const {},
    this.completedResearch = const {},
    this.conqueredTerritories = const {},
    this.reincarnationState = const ReincarnationState(),
    this.prophecyState = const ProphecyState(cooldowns: {}),
    this.lifetimeWisdom = 0,
    this.lifetimePropheciesActivated = 0,
  });

  /// Initial game state
  factory GameState.initial() {
    return GameState(
      resources: {
        ResourceType.cats: 0,
        ResourceType.offerings: 0,
        ResourceType.prayers: 0,
        ResourceType.wisdom: 0,
      },
      buildings: {},
      unlockedGods: {God.hermes},
      lastUpdate: DateTime.now(),
      totalCatsEarned: 0,
      unlockedAchievements: {},
      completedResearch: {},
      conqueredTerritories: {},
      reincarnationState: const ReincarnationState(),
      prophecyState: ProphecyState.initial(),
      lifetimeWisdom: 0,
      lifetimePropheciesActivated: 0,
    );
  }

  /// Create a copy with modifications
  GameState copyWith({
    Map<ResourceType, double>? resources,
    Map<BuildingType, int>? buildings,
    Set<God>? unlockedGods,
    DateTime? lastUpdate,
    double? totalCatsEarned,
    Set<String>? unlockedAchievements,
    Set<String>? completedResearch,
    Set<String>? conqueredTerritories,
    ReincarnationState? reincarnationState,
    ProphecyState? prophecyState,
    double? lifetimeWisdom,
    int? lifetimePropheciesActivated,
  }) {
    return GameState(
      resources: resources ?? Map.from(this.resources),
      buildings: buildings ?? Map.from(this.buildings),
      unlockedGods: unlockedGods ?? Set.from(this.unlockedGods),
      lastUpdate: lastUpdate ?? this.lastUpdate,
      totalCatsEarned: totalCatsEarned ?? this.totalCatsEarned,
      unlockedAchievements: unlockedAchievements ?? Set.from(this.unlockedAchievements),
      completedResearch: completedResearch ?? Set.from(this.completedResearch),
      conqueredTerritories: conqueredTerritories ?? Set.from(this.conqueredTerritories),
      reincarnationState: reincarnationState ?? this.reincarnationState,
      prophecyState: prophecyState ?? this.prophecyState,
      lifetimeWisdom: lifetimeWisdom ?? this.lifetimeWisdom,
      lifetimePropheciesActivated: lifetimePropheciesActivated ?? this.lifetimePropheciesActivated,
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

  /// Check if achievement is unlocked
  bool hasUnlockedAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  /// Check if research is completed
  bool hasCompletedResearch(String researchId) {
    return completedResearch.contains(researchId);
  }

  /// Check if territory is conquered
  bool hasConqueredTerritory(String territoryId) {
    return conqueredTerritories.contains(territoryId);
  }

  /// Activate a prophecy
  GameState activateProphecy(ProphecyType prophecy, DateTime now) {
    // Check if on cooldown
    if (prophecyState.isOnCooldown(prophecy, now)) {
      throw ProphecyOnCooldownException(prophecy);
    }

    // Calculate actual cost with research bonuses
    double cost = prophecy.wisdomCost.toDouble();

    // Apply prophetic connection research (-15% cost)
    if (hasCompletedResearch('prophetic_connection')) {
      cost *= 0.85; // 15% discount
    }

    // Check if have enough Wisdom
    final currentWisdom = resources[ResourceType.wisdom] ?? 0;
    if (currentWisdom < cost) {
      throw InsufficientResourcesException(ResourceType.wisdom, cost, currentWisdom);
    }

    // Deduct Wisdom
    final updatedResources = Map<ResourceType, double>.from(resources);
    updatedResources[ResourceType.wisdom] = currentWisdom - cost;

    // Activate prophecy
    final updatedProphecyState = prophecyState.activate(prophecy, now);

    return copyWith(
      resources: updatedResources,
      prophecyState: updatedProphecyState,
      lifetimePropheciesActivated: lifetimePropheciesActivated + 1,
    );
  }

  /// Update prophecy effects (expire timed boosts if needed)
  GameState updateProphecyEffects(DateTime now) {
    // Check if active timed boost has expired
    if (prophecyState.activeTimedBoost != null &&
        prophecyState.activeTimedBoostExpiry != null &&
        now.isAfter(prophecyState.activeTimedBoostExpiry!)) {
      return copyWith(
        prophecyState: prophecyState.copyWith(
          activeTimedBoost: null,
          activeTimedBoostExpiry: null,
        ),
      );
    }

    return this;
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
      'unlockedAchievements': unlockedAchievements.toList(),
      'completedResearch': completedResearch.toList(),
      'conqueredTerritories': conqueredTerritories.toList(),
      'reincarnationState': reincarnationState.toJson(),
      'lifetimeWisdom': lifetimeWisdom,
      'lifetimePropheciesActivated': lifetimePropheciesActivated,
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
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toSet() ?? {},
      completedResearch: (json['completedResearch'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toSet() ?? {},
      conqueredTerritories: (json['conqueredTerritories'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toSet() ?? {},
      reincarnationState: json['reincarnationState'] != null
        ? ReincarnationState.fromJson(json['reincarnationState'] as Map<String, dynamic>)
        : const ReincarnationState(),
      lifetimeWisdom: (json['lifetimeWisdom'] as num?)?.toDouble() ?? 0,
      lifetimePropheciesActivated: (json['lifetimePropheciesActivated'] as int?) ?? 0,
    );
  }
}

/// Exception thrown when trying to activate a prophecy on cooldown
class ProphecyOnCooldownException implements Exception {
  final ProphecyType prophecy;
  ProphecyOnCooldownException(this.prophecy);

  @override
  String toString() => 'Prophecy ${prophecy.displayName} is on cooldown';
}

/// Exception thrown when trying to activate a prophecy with insufficient resources
class InsufficientResourcesException implements Exception {
  final ResourceType resource;
  final double required;
  final double current;

  InsufficientResourcesException(this.resource, this.required, this.current);

  @override
  String toString() => 'Insufficient ${resource.displayName}: need $required, have $current';
}
