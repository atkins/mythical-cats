import 'dart:async';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/services/save_service.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';

/// Game logic provider
class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  Timer? _saveTimer;

  GameNotifier(this.ref) : super(GameState.initial()) {
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
    // Calculate production for all resource types
    final production = <ResourceType, double>{};

    for (final resourceType in ResourceType.values) {
      final rate = getProductionRate(resourceType);
      if (rate > 0) {
        production[resourceType] = rate * deltaSeconds;
      }
    }

    // Update resources if any production occurred
    if (production.isNotEmpty) {
      final newResources = Map<ResourceType, double>.from(state.resources);

      double catsProduced = 0;
      for (final entry in production.entries) {
        newResources[entry.key] = state.getResource(entry.key) + entry.value;
        if (entry.key == ResourceType.cats) {
          catsProduced = entry.value;
        }
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

  /// Add/remove resources (helper for other providers)
  void addResource(ResourceType type, double amount) {
    final current = state.getResource(type);
    final newResources = Map<ResourceType, double>.from(state.resources);
    newResources[type] = current + amount;

    state = state.copyWith(resources: newResources);
  }

  /// Update state directly (helper for other providers)
  void updateState(GameState newState) {
    state = newState;
  }

  /// Convert offerings to divine essence in the workshop
  bool convertInWorkshop(double offeringsAmount) {
    // Check if player has at least 1 workshop
    if (state.getBuildingCount(BuildingType.workshop) < 1) {
      return false;
    }

    // Check if player has enough offerings
    if (state.getResource(ResourceType.offerings) < offeringsAmount) {
      return false;
    }

    // Calculate conversion ratio (10:1 base, 8:1 with Divine Alchemy)
    final hasDivineAlchemy = state.hasCompletedResearch('divine_alchemy');
    final conversionRatio = hasDivineAlchemy ? 8.0 : 10.0;
    final divineEssenceGained = offeringsAmount / conversionRatio;

    // Perform conversion
    addResource(ResourceType.offerings, -offeringsAmount);
    addResource(ResourceType.divineEssence, divineEssenceGained);

    return true;
  }

  /// Calculate PE earned from total cats earned in this run.
  ///
  /// Formula: basePE = (log(totalCats) / ln10 - 7).round() * 10
  /// - Threshold: 1 billion cats (1,000,000,000)
  /// - Returns 0 if below threshold
  /// - Applies +10% bonus per tier 5 upgrade owned
  int calculatePrimordialEssence(double totalCats) {
    if (totalCats < 1000000000) return 0;

    final basePE = (log(totalCats) / ln10 - 7).round() * 10;

    // Apply PE bonuses from tier 5 upgrades (+10% each)
    double peBonus = 0;
    if (state.reincarnationState.ownedUpgradeIds.contains('chaos_5')) peBonus += 0.1;
    if (state.reincarnationState.ownedUpgradeIds.contains('gaia_5')) peBonus += 0.1;
    if (state.reincarnationState.ownedUpgradeIds.contains('nyx_5')) peBonus += 0.1;
    if (state.reincarnationState.ownedUpgradeIds.contains('erebus_5')) peBonus += 0.1;

    return (basePE * (1 + peBonus)).floor();
  }

  /// Get click power multiplier from Chaos upgrades and patron bonus
  ///
  /// Chaos tier bonuses: 10%, 25%, 50%, 100%, 150%
  /// Patron bonus: 0.5 + (tier * 0.1) if Chaos is active patron
  double getClickPowerMultiplier() {
    double multiplier = 1.0;
    final upgrades = state.reincarnationState.ownedUpgradeIds;

    // Permanent Chaos upgrades
    if (upgrades.contains('chaos_1')) multiplier += 0.10;
    if (upgrades.contains('chaos_2')) multiplier += 0.25;
    if (upgrades.contains('chaos_3')) multiplier += 0.50;
    if (upgrades.contains('chaos_4')) multiplier += 1.00;
    if (upgrades.contains('chaos_5')) multiplier += 1.50;

    // Patron bonus
    if (state.reincarnationState.activePatron == PrimordialForce.chaos) {
      int tier = 0;
      if (upgrades.contains('chaos_1')) tier++;
      if (upgrades.contains('chaos_2')) tier++;
      if (upgrades.contains('chaos_3')) tier++;
      if (upgrades.contains('chaos_4')) tier++;
      if (upgrades.contains('chaos_5')) tier++;
      multiplier += 0.5 + (tier * 0.1);
    }

    return multiplier;
  }

  /// Get building production multiplier from Gaia upgrades and patron bonus
  ///
  /// Gaia tier bonuses: 10%, 25%, 50%, 100%, 150%
  /// Patron bonus: 0.5 + (tier * 0.1) if Gaia is active patron
  double getBuildingProductionMultiplier() {
    double multiplier = 1.0;
    final upgrades = state.reincarnationState.ownedUpgradeIds;

    // Permanent Gaia upgrades
    if (upgrades.contains('gaia_1')) multiplier += 0.10;
    if (upgrades.contains('gaia_2')) multiplier += 0.25;
    if (upgrades.contains('gaia_3')) multiplier += 0.50;
    if (upgrades.contains('gaia_4')) multiplier += 1.00;
    if (upgrades.contains('gaia_5')) multiplier += 1.50;

    // Patron bonus
    if (state.reincarnationState.activePatron == PrimordialForce.gaia) {
      int tier = 0;
      if (upgrades.contains('gaia_1')) tier++;
      if (upgrades.contains('gaia_2')) tier++;
      if (upgrades.contains('gaia_3')) tier++;
      if (upgrades.contains('gaia_4')) tier++;
      if (upgrades.contains('gaia_5')) tier++;
      multiplier += 0.5 + (tier * 0.1);
    }

    return multiplier;
  }

  /// Get building cost reduction from Gaia upgrades
  ///
  /// Gaia III: -10%, Gaia IV: -15% (higher tier wins, not cumulative)
  double getBuildingCostReduction() {
    final upgrades = state.reincarnationState.ownedUpgradeIds;

    if (upgrades.contains('gaia_4')) return 0.15;
    if (upgrades.contains('gaia_3')) return 0.10;
    return 0.0;
  }

  /// Get offline progression multiplier from Nyx upgrades and patron bonus
  ///
  /// Nyx tier bonuses: 25%, 50%, 100%, 150%, 200%
  /// Patron bonus: 0.5 + (tier * 0.1) if Nyx is active patron
  double getOfflineProgressionMultiplier() {
    double multiplier = 1.0;
    final upgrades = state.reincarnationState.ownedUpgradeIds;

    // Permanent Nyx upgrades
    if (upgrades.contains('nyx_1')) multiplier += 0.25;
    if (upgrades.contains('nyx_2')) multiplier += 0.50;
    if (upgrades.contains('nyx_3')) multiplier += 1.00;
    if (upgrades.contains('nyx_4')) multiplier += 1.50;
    if (upgrades.contains('nyx_5')) multiplier += 2.00;

    // Patron bonus
    if (state.reincarnationState.activePatron == PrimordialForce.nyx) {
      int tier = 0;
      if (upgrades.contains('nyx_1')) tier++;
      if (upgrades.contains('nyx_2')) tier++;
      if (upgrades.contains('nyx_3')) tier++;
      if (upgrades.contains('nyx_4')) tier++;
      if (upgrades.contains('nyx_5')) tier++;
      multiplier += 0.5 + (tier * 0.1);
    }

    return multiplier;
  }

  /// Get offline cap hours from Nyx upgrades
  ///
  /// Default: 24 hours
  /// Nyx III: 48 hours
  /// Nyx IV: 72 hours
  /// (higher tier wins, not cumulative)
  int getOfflineCapHours() {
    final upgrades = state.reincarnationState.ownedUpgradeIds;

    if (upgrades.contains('nyx_4')) return 72;
    if (upgrades.contains('nyx_3')) return 48;
    return 24;
  }

  /// Get Tier 2 production multiplier from Erebus upgrades and patron bonus
  ///
  /// Erebus tier bonuses: 15%, 30%, 50%, 75%, 100%
  /// Patron bonus: 0.5 + (tier * 0.1) if Erebus is active patron
  double getTier2ProductionMultiplier() {
    double multiplier = 1.0;
    final upgrades = state.reincarnationState.ownedUpgradeIds;

    // Permanent Erebus upgrades
    if (upgrades.contains('erebus_1')) multiplier += 0.15;
    if (upgrades.contains('erebus_2')) multiplier += 0.30;
    if (upgrades.contains('erebus_3')) multiplier += 0.50;
    if (upgrades.contains('erebus_4')) multiplier += 0.75;
    if (upgrades.contains('erebus_5')) multiplier += 1.00;

    // Patron bonus
    if (state.reincarnationState.activePatron == PrimordialForce.erebus) {
      int tier = 0;
      if (upgrades.contains('erebus_1')) tier++;
      if (upgrades.contains('erebus_2')) tier++;
      if (upgrades.contains('erebus_3')) tier++;
      if (upgrades.contains('erebus_4')) tier++;
      if (upgrades.contains('erebus_5')) tier++;
      multiplier += 0.5 + (tier * 0.1);
    }

    return multiplier;
  }

  /// Get production rate for a specific resource type
  double getProductionRate(ResourceType type) {
    double baseProduction = 0;

    // Calculate base production from buildings
    for (final buildingType in BuildingType.values) {
      final count = state.getBuildingCount(buildingType);
      if (count > 0) {
        final definition = BuildingDefinitions.get(buildingType);
        if (definition.productionType == type) {
          baseProduction += definition.baseProduction * count;
        }
      }
    }

    // Apply conquest bonuses
    try {
      final conquest = ref.read(conquestProvider);
      final bonuses = conquest.getTotalProductionBonus();
      final bonus = bonuses[type] ?? 0;
      return baseProduction * (1 + bonus);
    } catch (e) {
      // If conquest provider is not available, return base production
      return baseProduction;
    }
  }

  /// Calculate total cats per second
  double get catsPerSecond {
    return getProductionRate(ResourceType.cats);
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

    // Calculate total buildings once for efficiency
    final totalBuildings = state.buildings.values.fold<int>(
      0, (sum, count) => sum + count,
    );

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
        if (totalBuildings >= 10) shouldUnlock = true;
      } else if (achievement.id == 'buildings_50') {
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

  /// Reincarnate: Reset game state and award Primordial Essence
  void reincarnate(PrimordialForce chosenPatron) {
    // Calculate PE earned from this run
    final peEarned = calculatePrimordialEssence(state.totalCatsEarned);

    // Store persistent data
    final persistedResearch = Set<String>.from(state.completedResearch);
    final persistedAchievements = Set<String>.from(state.unlockedAchievements);
    final persistedUpgrades = Set<String>.from(state.reincarnationState.ownedUpgradeIds);

    // Reset to initial state but keep reincarnation progress
    state = GameState.initial().copyWith(
      completedResearch: persistedResearch,
      unlockedAchievements: persistedAchievements,
      reincarnationState: ReincarnationState(
        totalReincarnations: state.reincarnationState.totalReincarnations + 1,
        totalPrimordialEssence: state.reincarnationState.totalPrimordialEssence + peEarned,
        availablePrimordialEssence: state.reincarnationState.availablePrimordialEssence + peEarned,
        ownedUpgradeIds: persistedUpgrades,
        activePatron: chosenPatron,
        lifetimeCatsEarned: state.reincarnationState.lifetimeCatsEarned + state.totalCatsEarned.toInt(),
        thisRunCatsEarned: 0,
      ),
    );
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
  return GameNotifier(ref);
});

/// Provider that loads initial game state
final initialGameStateProvider = FutureProvider<GameState>((ref) async {
  final saved = await SaveService.load();
  return saved ?? GameState.initial();
});
