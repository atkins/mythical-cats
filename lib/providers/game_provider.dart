import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';
import 'package:mythical_cats/services/save_service.dart';

/// Game logic provider
class GameNotifier extends StateNotifier<GameState> {
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  Timer? _saveTimer;

  GameNotifier() : super(GameState.initial()) {
    _startGameLoop();
    _startAutoSave();
  }

  /// Start the game loop ticker
  void _startGameLoop() {
    _ticker = Ticker((elapsed) {
      final delta = elapsed - _lastElapsed;
      _lastElapsed = elapsed;

      _updateGame(delta.inMilliseconds / 1000.0); // Convert to seconds
    });
    _ticker!.start();
  }

  /// Update game state based on elapsed time
  void _updateGame(double deltaSeconds) {
    // Calculate production
    double catsProduced = 0;
    double offeringsProduced = 0;
    double prayersProduced = 0;

    for (final entry in state.buildings.entries) {
      final buildingType = entry.key;
      final count = entry.value;
      final definition = BuildingDefinitions.get(buildingType);

      final production = definition.baseProduction * count * deltaSeconds;

      if (definition.productionType == ResourceType.cats) {
        catsProduced += production;
      } else if (definition.productionType == ResourceType.offerings) {
        offeringsProduced += production;
      } else if (definition.productionType == ResourceType.prayers) {
        prayersProduced += production;
      }
    }

    // Update resources
    if (catsProduced > 0 || offeringsProduced > 0 || prayersProduced > 0) {
      final newResources = Map<ResourceType, double>.from(state.resources);

      if (catsProduced > 0) {
        newResources[ResourceType.cats] = state.getResource(ResourceType.cats) + catsProduced;
      }
      if (offeringsProduced > 0) {
        newResources[ResourceType.offerings] = state.getResource(ResourceType.offerings) + offeringsProduced;
      }
      if (prayersProduced > 0) {
        newResources[ResourceType.prayers] = state.getResource(ResourceType.prayers) + prayersProduced;
      }

      state = state.copyWith(
        resources: newResources,
        totalCatsEarned: state.totalCatsEarned + catsProduced,
        lastUpdate: DateTime.now(),
      );

      // Check for god unlocks
      _checkGodUnlocks();
    }
  }

  /// Perform a ritual (manual click to generate cats)
  void performRitual() {
    final newResources = Map<ResourceType, double>.from(state.resources);
    newResources[ResourceType.cats] = state.getResource(ResourceType.cats) + 1;

    state = state.copyWith(
      resources: newResources,
      totalCatsEarned: state.totalCatsEarned + 1,
    );

    _checkGodUnlocks();
    _checkAchievements();
  }

  /// Buy a building
  bool buyBuilding(BuildingType type, {int amount = 1}) {
    final definition = BuildingDefinitions.get(type);
    final currentCount = state.getBuildingCount(type);
    final cost = definition.calculateBulkCost(currentCount, amount);

    // Check if we can afford it
    for (final entry in cost.entries) {
      if (state.getResource(entry.key) < entry.value) {
        return false; // Can't afford
      }
    }

    // Deduct resources
    final newResources = Map<ResourceType, double>.from(state.resources);
    for (final entry in cost.entries) {
      newResources[entry.key] = state.getResource(entry.key) - entry.value;
    }

    // Add building
    final newBuildings = Map<BuildingType, int>.from(state.buildings);
    newBuildings[type] = currentCount + amount;

    state = state.copyWith(
      resources: newResources,
      buildings: newBuildings,
    );

    _checkAchievements();

    return true;
  }

  /// Check and unlock gods based on total cats earned
  void _checkGodUnlocks() {
    final unlockedSet = Set<God>.from(state.unlockedGods);
    bool unlocked = false;

    for (final god in God.values) {
      if (!state.hasUnlockedGod(god)) {
        final requirement = god.unlockRequirement;
        if (requirement == null || state.totalCatsEarned >= requirement) {
          unlockedSet.add(god);
          unlocked = true;
        }
      }
    }

    if (unlocked) {
      state = state.copyWith(unlockedGods: unlockedSet);
    }
  }

  /// Calculate total cats per second
  double get catsPerSecond {
    double total = 0;
    for (final entry in state.buildings.entries) {
      final definition = BuildingDefinitions.get(entry.key);
      if (definition.productionType == ResourceType.cats) {
        total += definition.baseProduction * entry.value;
      }
    }
    return total;
  }

  /// Start auto-save timer (every 30 seconds)
  void _startAutoSave() {
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      SaveService.save(state);
    });
  }

  /// Load saved state
  void loadState(GameState loadedState) {
    state = loadedState;
  }

  /// Calculate and apply offline progress
  void applyOfflineProgress() {
    final now = DateTime.now();
    final lastUpdate = state.lastUpdate;
    final elapsed = now.difference(lastUpdate);

    // Cap at 24 hours
    final cappedSeconds = elapsed.inSeconds.toDouble().clamp(0.0, 24.0 * 60 * 60);

    if (cappedSeconds > 60) { // Only apply if more than 1 minute offline
      _updateGame(cappedSeconds);
    }
  }

  /// Check and unlock achievements based on current state
  void _checkAchievements() {
    final newAchievements = Set<String>.from(state.unlockedAchievements);
    bool unlocked = false;

    for (final achievement in AchievementDefinitions.all) {
      if (state.hasUnlockedAchievement(achievement.id)) {
        continue; // Already unlocked
      }

      bool shouldUnlock = false;

      // Check cat achievements
      if (achievement.id == 'cats_100' && state.totalCatsEarned >= 100) {
        shouldUnlock = true;
      } else if (achievement.id == 'cats_1k' && state.totalCatsEarned >= 1000) {
        shouldUnlock = true;
      } else if (achievement.id == 'cats_10k' && state.totalCatsEarned >= 10000) {
        shouldUnlock = true;
      }
      // Check building achievements
      else if (achievement.id == 'buildings_10') {
        final totalBuildings = state.buildings.values.fold<int>(
          0, (sum, count) => sum + count,
        );
        if (totalBuildings >= 10) shouldUnlock = true;
      } else if (achievement.id == 'buildings_50') {
        final totalBuildings = state.buildings.values.fold<int>(
          0, (sum, count) => sum + count,
        );
        if (totalBuildings >= 50) shouldUnlock = true;
      }
      // Check god achievements
      else if (achievement.id == 'god_hestia' && state.hasUnlockedGod(God.hestia)) {
        shouldUnlock = true;
      } else if (achievement.id == 'god_demeter' && state.hasUnlockedGod(God.demeter)) {
        shouldUnlock = true;
      } else if (achievement.id == 'god_dionysus' && state.hasUnlockedGod(God.dionysus)) {
        shouldUnlock = true;
      }

      if (shouldUnlock) {
        newAchievements.add(achievement.id);
        unlocked = true;
      }
    }

    if (unlocked) {
      state = state.copyWith(unlockedAchievements: newAchievements);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }
}

/// Provider for game state
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

/// Provider that loads initial game state
final initialGameStateProvider = FutureProvider<GameState>((ref) async {
  final saved = await SaveService.load();
  return saved ?? GameState.initial();
});
