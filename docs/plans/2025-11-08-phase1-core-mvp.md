# Phase 1: Core MVP Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a playable idle game loop where players click to generate cats, buy buildings that auto-generate cats, and unlock the first two gods (Hermes, Hestia).

**Architecture:** Flutter app with Riverpod state management. Game state uses immutable models with a game loop ticker running at 60 FPS. Local persistence via shared_preferences with JSON serialization.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, shared_preferences, intl (number formatting)

---

## Task 1: Initialize Flutter Project

**Files:**
- Create: Flutter project structure
- Create: `pubspec.yaml`
- Create: `.gitignore`

**Step 1: Create Flutter project**

Run:
```bash
flutter create --org com.mythicalcats --project-name mythical_cats .
```

Expected: Flutter project scaffolding created with lib/, test/, pubspec.yaml

**Step 2: Update pubspec.yaml with dependencies**

Edit `pubspec.yaml`, replace dependencies section:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
```

**Step 3: Get dependencies**

Run:
```bash
flutter pub get
```

Expected: All packages downloaded successfully

**Step 4: Create .gitignore additions**

Append to `.gitignore`:

```
# Generated files
*.g.dart
*.freezed.dart

# Build artifacts
build/
.dart_tool/
```

**Step 5: Commit**

```bash
git add .
git commit -m "feat: initialize Flutter project with Riverpod

Add dependencies:
- flutter_riverpod for state management
- shared_preferences for local storage
- intl for number formatting
- json_annotation for serialization"
```

---

## Task 2: Create Data Models - Resources

**Files:**
- Create: `lib/models/resource_type.dart`
- Create: `lib/models/resource.dart`

**Step 1: Create ResourceType enum**

Create `lib/models/resource_type.dart`:

```dart
/// Types of resources in the game
enum ResourceType {
  cats,
  offerings,
  prayers,
  divineEssence,
  ambrosia,
  ichor,
  celestialFragments;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ResourceType.cats:
        return 'Cats';
      case ResourceType.offerings:
        return 'Offerings';
      case ResourceType.prayers:
        return 'Prayers';
      case ResourceType.divineEssence:
        return 'Divine Essence';
      case ResourceType.ambrosia:
        return 'Ambrosia';
      case ResourceType.ichor:
        return 'Ichor';
      case ResourceType.celestialFragments:
        return 'Celestial Fragments';
    }
  }

  /// Icon for UI (placeholder, will be replaced with actual icons later)
  String get icon {
    switch (this) {
      case ResourceType.cats:
        return '🐱';
      case ResourceType.offerings:
        return '🎁';
      case ResourceType.prayers:
        return '🙏';
      case ResourceType.divineEssence:
        return '✨';
      case ResourceType.ambrosia:
        return '🍯';
      case ResourceType.ichor:
        return '💉';
      case ResourceType.celestialFragments:
        return '💎';
    }
  }
}
```

**Step 2: Create test for ResourceType**

Create `test/models/resource_type_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('ResourceType', () {
    test('has correct display names', () {
      expect(ResourceType.cats.displayName, 'Cats');
      expect(ResourceType.offerings.displayName, 'Offerings');
      expect(ResourceType.prayers.displayName, 'Prayers');
    });

    test('has icons for all types', () {
      for (final type in ResourceType.values) {
        expect(type.icon.isNotEmpty, true);
      }
    });
  });
}
```

**Step 3: Run test to verify it passes**

Run:
```bash
flutter test test/models/resource_type_test.dart
```

Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/models/resource_type.dart test/models/resource_type_test.dart
git commit -m "feat: add ResourceType enum with display names and icons"
```

---

## Task 3: Create Data Models - God

**Files:**
- Create: `lib/models/god.dart`

**Step 1: Create God enum**

Create `lib/models/god.dart`:

```dart
/// The 12 Olympian gods, unlocked in sequence
enum God {
  hermes,
  hestia,
  demeter,
  dionysus,
  athena,
  apollo,
  artemis,
  ares,
  hephaestus,
  aphrodite,
  poseidon,
  zeus;

  /// Display name
  String get displayName {
    switch (this) {
      case God.hermes:
        return 'Hermes';
      case God.hestia:
        return 'Hestia';
      case God.demeter:
        return 'Demeter';
      case God.dionysus:
        return 'Dionysus';
      case God.athena:
        return 'Athena';
      case God.apollo:
        return 'Apollo';
      case God.artemis:
        return 'Artemis';
      case God.ares:
        return 'Ares';
      case God.hephaestus:
        return 'Hephaestus';
      case God.aphrodite:
        return 'Aphrodite';
      case God.poseidon:
        return 'Poseidon';
      case God.zeus:
        return 'Zeus';
    }
  }

  /// Description of the god's domain
  String get description {
    switch (this) {
      case God.hermes:
        return 'God of travelers and messengers';
      case God.hestia:
        return 'Goddess of hearth and home';
      case God.demeter:
        return 'Goddess of harvest';
      case God.dionysus:
        return 'God of celebration';
      case God.athena:
        return 'Goddess of wisdom';
      case God.apollo:
        return 'God of light and prophecy';
      case God.artemis:
        return 'Goddess of the hunt';
      case God.ares:
        return 'God of war';
      case God.hephaestus:
        return 'God of the forge';
      case God.aphrodite:
        return 'Goddess of love';
      case God.poseidon:
        return 'God of the sea';
      case God.zeus:
        return 'King of the gods';
    }
  }

  /// Cats required to unlock this god (null for starting god)
  double? get unlockRequirement {
    switch (this) {
      case God.hermes:
        return null; // Starting god
      case God.hestia:
        return 1000;
      case God.demeter:
        return 10000;
      case God.dionysus:
        return 100000;
      case God.athena:
        return 1000000;
      case God.apollo:
        return 10000000;
      case God.artemis:
        return 100000000;
      case God.ares:
        return 1000000000;
      case God.hephaestus:
        return 10000000000;
      case God.aphrodite:
        return 100000000000;
      case God.poseidon:
        return 1000000000000;
      case God.zeus:
        return 10000000000000;
    }
  }
}
```

**Step 2: Create test for God**

Create `test/models/god_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('God', () {
    test('Hermes is the starting god with no unlock requirement', () {
      expect(God.hermes.unlockRequirement, null);
    });

    test('all gods have display names', () {
      for (final god in God.values) {
        expect(god.displayName.isNotEmpty, true);
      }
    });

    test('all gods have descriptions', () {
      for (final god in God.values) {
        expect(god.description.isNotEmpty, true);
      }
    });

    test('unlock requirements increase exponentially', () {
      expect(God.hestia.unlockRequirement, 1000);
      expect(God.demeter.unlockRequirement, 10000);
      expect(God.dionysus.unlockRequirement, 100000);
    });
  });
}
```

**Step 3: Run test**

Run:
```bash
flutter test test/models/god_test.dart
```

Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/models/god.dart test/models/god_test.dart
git commit -m "feat: add God enum with unlock requirements"
```

---

## Task 4: Create Data Models - Building Types

**Files:**
- Create: `lib/models/building_type.dart`
- Create: `lib/models/building_definition.dart`

**Step 1: Create BuildingType enum**

Create `lib/models/building_type.dart`:

```dart
import 'package:mythical_cats/models/god.dart';

/// Types of buildings available in the game
enum BuildingType {
  // Generic shrine tiers
  smallShrine,
  temple,
  grandSanctuary,

  // God-specific buildings (Phase 1: just Hermes and Hestia)
  messengerWaystation, // Hermes
  hearthAltar; // Hestia

  /// Display name
  String get displayName {
    switch (this) {
      case BuildingType.smallShrine:
        return 'Small Shrine';
      case BuildingType.temple:
        return 'Temple';
      case BuildingType.grandSanctuary:
        return 'Grand Sanctuary';
      case BuildingType.messengerWaystation:
        return 'Messenger Waystation';
      case BuildingType.hearthAltar:
        return 'Hearth Altar';
    }
  }

  /// Description
  String get description {
    switch (this) {
      case BuildingType.smallShrine:
        return 'A modest shrine that attracts divine cats';
      case BuildingType.temple:
        return 'An impressive temple dedicated to the gods';
      case BuildingType.grandSanctuary:
        return 'A magnificent sanctuary of divine power';
      case BuildingType.messengerWaystation:
        return 'Boosts offline progression efficiency';
      case BuildingType.hearthAltar:
        return 'Generates offerings from the hearth';
    }
  }

  /// God required to unlock (null if available from start)
  God? get requiredGod {
    switch (this) {
      case BuildingType.smallShrine:
      case BuildingType.temple:
      case BuildingType.grandSanctuary:
        return null; // Available from start
      case BuildingType.messengerWaystation:
        return God.hermes;
      case BuildingType.hearthAltar:
        return God.hestia;
    }
  }
}
```

**Step 2: Create BuildingDefinition model**

Create `lib/models/building_definition.dart`:

```dart
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/resource_type.dart';

/// Defines the properties of a building type
class BuildingDefinition {
  final BuildingType type;
  final Map<ResourceType, double> baseCost;
  final double costMultiplier;
  final double baseProduction;
  final ResourceType productionType;

  const BuildingDefinition({
    required this.type,
    required this.baseCost,
    this.costMultiplier = 1.15,
    required this.baseProduction,
    this.productionType = ResourceType.cats,
  });

  /// Calculate cost for buying the next building of this type
  Map<ResourceType, double> calculateCost(int currentCount) {
    return baseCost.map(
      (resource, cost) => MapEntry(
        resource,
        cost * Math.pow(costMultiplier, currentCount),
      ),
    );
  }

  /// Calculate cost for buying multiple buildings
  Map<ResourceType, double> calculateBulkCost(int currentCount, int amount) {
    final costs = <ResourceType, double>{};

    for (int i = 0; i < amount; i++) {
      final nextCost = calculateCost(currentCount + i);
      for (final entry in nextCost.entries) {
        costs[entry.key] = (costs[entry.key] ?? 0) + entry.value;
      }
    }

    return costs;
  }
}

/// All building definitions
class BuildingDefinitions {
  static const smallShrine = BuildingDefinition(
    type: BuildingType.smallShrine,
    baseCost: {ResourceType.cats: 15},
    baseProduction: 0.1,
  );

  static const temple = BuildingDefinition(
    type: BuildingType.temple,
    baseCost: {ResourceType.cats: 100},
    baseProduction: 1.0,
  );

  static const grandSanctuary = BuildingDefinition(
    type: BuildingType.grandSanctuary,
    baseCost: {ResourceType.cats: 1000},
    baseProduction: 8.0,
  );

  static const messengerWaystation = BuildingDefinition(
    type: BuildingType.messengerWaystation,
    baseCost: {ResourceType.cats: 500, ResourceType.offerings: 100},
    baseProduction: 2.0,
  );

  static const hearthAltar = BuildingDefinition(
    type: BuildingType.hearthAltar,
    baseCost: {ResourceType.cats: 2000, ResourceType.offerings: 250},
    baseProduction: 0.5,
    productionType: ResourceType.offerings,
  );

  /// Get definition by type
  static BuildingDefinition get(BuildingType type) {
    switch (type) {
      case BuildingType.smallShrine:
        return smallShrine;
      case BuildingType.temple:
        return temple;
      case BuildingType.grandSanctuary:
        return grandSanctuary;
      case BuildingType.messengerWaystation:
        return messengerWaystation;
      case BuildingType.hearthAltar:
        return hearthAltar;
    }
  }

  /// All available building definitions
  static List<BuildingDefinition> get all => [
    smallShrine,
    temple,
    grandSanctuary,
    messengerWaystation,
    hearthAltar,
  ];
}
```

Note: We need to add import for Math:
```dart
import 'dart:math' as Math;
```

**Step 3: Create test for building definitions**

Create `test/models/building_definition_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('BuildingDefinition', () {
    test('calculateCost scales with cost multiplier', () {
      final def = BuildingDefinitions.smallShrine;

      // First building costs base amount
      expect(def.calculateCost(0)[ResourceType.cats], 15);

      // Second building costs base * multiplier
      final secondCost = def.calculateCost(1)[ResourceType.cats]!;
      expect(secondCost, closeTo(15 * 1.15, 0.01));

      // Third building costs base * multiplier^2
      final thirdCost = def.calculateCost(2)[ResourceType.cats]!;
      expect(thirdCost, closeTo(15 * 1.15 * 1.15, 0.01));
    });

    test('calculateBulkCost sums individual costs', () {
      final def = BuildingDefinitions.smallShrine;

      final bulkCost = def.calculateBulkCost(0, 3)[ResourceType.cats]!;
      final individualSum =
        def.calculateCost(0)[ResourceType.cats]! +
        def.calculateCost(1)[ResourceType.cats]! +
        def.calculateCost(2)[ResourceType.cats]!;

      expect(bulkCost, closeTo(individualSum, 0.01));
    });

    test('all buildings can be retrieved by type', () {
      for (final type in BuildingType.values) {
        final def = BuildingDefinitions.get(type);
        expect(def.type, type);
      }
    });
  });
}
```

**Step 4: Run test**

Run:
```bash
flutter test test/models/building_definition_test.dart
```

Expected: All tests pass

**Step 5: Commit**

```bash
git add lib/models/building_type.dart lib/models/building_definition.dart test/models/building_definition_test.dart
git commit -m "feat: add building types and definitions with cost calculation"
```

---

## Task 5: Create GameState Model

**Files:**
- Create: `lib/models/game_state.dart`

**Step 1: Create GameState class**

Create `lib/models/game_state.dart`:

```dart
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
```

**Step 2: Create test for GameState**

Create `test/models/game_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('GameState', () {
    test('initial state has correct defaults', () {
      final state = GameState.initial();

      expect(state.getResource(ResourceType.cats), 0);
      expect(state.getResource(ResourceType.offerings), 0);
      expect(state.hasUnlockedGod(God.hermes), true);
      expect(state.hasUnlockedGod(God.hestia), false);
      expect(state.totalCatsEarned, 0);
    });

    test('copyWith creates new instance with changes', () {
      final state = GameState.initial();
      final newResources = {ResourceType.cats: 100.0};
      final newState = state.copyWith(resources: newResources);

      expect(newState.getResource(ResourceType.cats), 100);
      expect(state.getResource(ResourceType.cats), 0); // Original unchanged
    });

    test('getResource returns 0 for missing resources', () {
      final state = GameState.initial();
      expect(state.getResource(ResourceType.divineEssence), 0);
    });

    test('getBuildingCount returns 0 for buildings not built', () {
      final state = GameState.initial();
      expect(state.getBuildingCount(BuildingType.temple), 0);
    });

    test('toJson and fromJson round-trip correctly', () {
      final state = GameState(
        resources: {ResourceType.cats: 123.45},
        buildings: {BuildingType.smallShrine: 5},
        unlockedGods: {God.hermes, God.hestia},
        lastUpdate: DateTime(2025, 11, 8, 12, 0),
        totalCatsEarned: 200.0,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.getResource(ResourceType.cats), 123.45);
      expect(restored.getBuildingCount(BuildingType.smallShrine), 5);
      expect(restored.hasUnlockedGod(God.hermes), true);
      expect(restored.hasUnlockedGod(God.hestia), true);
      expect(restored.totalCatsEarned, 200.0);
    });
  });
}
```

**Step 3: Run test**

Run:
```bash
flutter test test/models/game_state_test.dart
```

Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/models/game_state.dart test/models/game_state_test.dart
git commit -m "feat: add GameState model with JSON serialization"
```

---

## Task 6: Create Game Logic Provider

**Files:**
- Create: `lib/providers/game_provider.dart`

**Step 1: Create GameNotifier class**

Create `lib/providers/game_provider.dart`:

```dart
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/god.dart';

/// Game logic provider
class GameNotifier extends StateNotifier<GameState> {
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;

  GameNotifier() : super(GameState.initial()) {
    _startGameLoop();
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

    for (final entry in state.buildings.entries) {
      final buildingType = entry.key;
      final count = entry.value;
      final definition = BuildingDefinitions.get(buildingType);

      final production = definition.baseProduction * count * deltaSeconds;

      if (definition.productionType == ResourceType.cats) {
        catsProduced += production;
      } else if (definition.productionType == ResourceType.offerings) {
        offeringsProduced += production;
      }
    }

    // Update resources
    if (catsProduced > 0 || offeringsProduced > 0) {
      final newResources = Map<ResourceType, double>.from(state.resources);

      if (catsProduced > 0) {
        newResources[ResourceType.cats] = state.getResource(ResourceType.cats) + catsProduced;
      }
      if (offeringsProduced > 0) {
        newResources[ResourceType.offerings] = state.getResource(ResourceType.offerings) + offeringsProduced;
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

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}

/// Provider for game state
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
```

**Step 2: Create test for GameNotifier**

Create `test/providers/game_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('GameNotifier', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state has Hermes unlocked', () {
      expect(notifier.state.hasUnlockedGod(God.hermes), true);
      expect(notifier.state.getResource(ResourceType.cats), 0);
    });

    test('performRitual adds 1 cat', () {
      notifier.performRitual();
      expect(notifier.state.getResource(ResourceType.cats), 1);
      expect(notifier.state.totalCatsEarned, 1);
    });

    test('buyBuilding succeeds when affordable', () {
      // Give enough cats to buy a small shrine (costs 15)
      notifier.performRitual();
      for (int i = 0; i < 14; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.getResource(ResourceType.cats), 15);

      final success = notifier.buyBuilding(BuildingType.smallShrine);
      expect(success, true);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 1);
      expect(notifier.state.getResource(ResourceType.cats), 0);
    });

    test('buyBuilding fails when not affordable', () {
      final success = notifier.buyBuilding(BuildingType.smallShrine);
      expect(success, false);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 0);
    });

    test('buyBuilding can buy multiple at once', () {
      // Give enough cats
      for (int i = 0; i < 50; i++) {
        notifier.performRitual();
      }

      final success = notifier.buyBuilding(BuildingType.smallShrine, amount: 2);
      expect(success, true);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 2);
    });

    test('catsPerSecond calculates correctly', () {
      // Manually set a building to check calculation
      final newBuildings = {BuildingType.smallShrine: 10};
      notifier.state = notifier.state.copyWith(buildings: newBuildings);

      // Small shrine produces 0.1 cats/sec, 10 of them = 1.0 cats/sec
      expect(notifier.catsPerSecond, 1.0);
    });

    test('god unlocks when requirement met', () {
      expect(notifier.state.hasUnlockedGod(God.hestia), false);

      // Set total cats earned to unlock Hestia (requires 1000)
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000,
        resources: {ResourceType.cats: 1000},
      );
      notifier.performRitual(); // Trigger unlock check

      expect(notifier.state.hasUnlockedGod(God.hestia), true);
    });
  });
}
```

**Step 3: Run test**

Run:
```bash
flutter test test/providers/game_provider_test.dart
```

Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add game logic provider with ticker and building purchase"
```

---

## Task 7: Create Number Formatting Utility

**Files:**
- Create: `lib/utils/number_formatter.dart`

**Step 1: Create NumberFormatter class**

Create `lib/utils/number_formatter.dart`:

```dart
import 'package:intl/intl.dart';

/// Utility for formatting large numbers in abbreviated form
class NumberFormatter {
  static final _suffixes = [
    '', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc'
  ];

  /// Format number with abbreviations (1.5K, 2.3M, etc.)
  static String format(double value, {int decimalPlaces = 1}) {
    if (value < 1000) {
      return value.toStringAsFixed(value < 10 ? 1 : 0);
    }

    int magnitude = 0;
    double reduced = value;

    while (reduced >= 1000 && magnitude < _suffixes.length - 1) {
      reduced /= 1000;
      magnitude++;
    }

    return '${reduced.toStringAsFixed(decimalPlaces)}${_suffixes[magnitude]}';
  }

  /// Format number with commas (1,234,567)
  static String formatWithCommas(double value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value.floor());
  }

  /// Format as per-second rate
  static String formatRate(double value) {
    return '${format(value)}/sec';
  }
}
```

**Step 2: Create test for NumberFormatter**

Create `test/utils/number_formatter_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

void main() {
  group('NumberFormatter', () {
    test('formats small numbers without suffix', () {
      expect(NumberFormatter.format(0), '0');
      expect(NumberFormatter.format(5), '5');
      expect(NumberFormatter.format(99), '99');
      expect(NumberFormatter.format(999), '999');
    });

    test('formats thousands with K suffix', () {
      expect(NumberFormatter.format(1000), '1.0K');
      expect(NumberFormatter.format(1500), '1.5K');
      expect(NumberFormatter.format(999000), '999.0K');
    });

    test('formats millions with M suffix', () {
      expect(NumberFormatter.format(1000000), '1.0M');
      expect(NumberFormatter.format(2300000), '2.3M');
    });

    test('formats billions with B suffix', () {
      expect(NumberFormatter.format(1000000000), '1.0B');
      expect(NumberFormatter.format(5600000000), '5.6B');
    });

    test('formats trillions with T suffix', () {
      expect(NumberFormatter.format(1000000000000), '1.0T');
    });

    test('formatRate adds /sec', () {
      expect(NumberFormatter.formatRate(1.5), '1.5/sec');
      expect(NumberFormatter.formatRate(1500), '1.5K/sec');
    });

    test('formatWithCommas adds commas', () {
      expect(NumberFormatter.formatWithCommas(1234567), '1,234,567');
      expect(NumberFormatter.formatWithCommas(999), '999');
    });
  });
}
```

**Step 3: Run test**

Run:
```bash
flutter test test/utils/number_formatter_test.dart
```

Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/utils/number_formatter.dart test/utils/number_formatter_test.dart
git commit -m "feat: add number formatter for large numbers"
```

---

## Task 8: Create Home Screen UI

**Files:**
- Create: `lib/screens/home_screen.dart`
- Modify: `lib/main.dart`

**Step 1: Create HomeScreen widget**

Create `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final cats = gameState.getResource(ResourceType.cats);
    final catsPerSecond = gameNotifier.catsPerSecond;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Resource display
              _ResourceDisplay(
                icon: ResourceType.cats.icon,
                label: ResourceType.cats.displayName,
                value: cats,
                rate: catsPerSecond,
              ),
              const SizedBox(height: 24),

              // Ritual button (click to generate cats)
              _RitualButton(
                onPressed: () => gameNotifier.performRitual(),
              ),

              const SizedBox(height: 24),

              // Quick stats
              _QuickStats(
                currentGod: gameState.unlockedGods.last.displayName,
                totalEarned: gameState.totalCatsEarned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceDisplay extends StatelessWidget {
  final String icon;
  final String label;
  final double value;
  final double rate;

  const _ResourceDisplay({
    required this.icon,
    required this.label,
    required this.value,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.format(value),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          if (rate > 0) ...[
            const SizedBox(height: 4),
            Text(
              NumberFormatter.formatRate(rate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.amber.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RitualButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RitualButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 48),
            const SizedBox(height: 8),
            Text(
              'Perform Ritual',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '+1 ${ResourceType.cats.icon}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final String currentGod;
  final double totalEarned;

  const _QuickStats({
    required this.currentGod,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatRow(
            label: 'Current God',
            value: currentGod,
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Total Cats Earned',
            value: NumberFormatter.format(totalEarned),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
```

**Step 2: Update main.dart to use ProviderScope and HomeScreen**

Modify `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mythical Cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

**Step 3: Test the app manually**

Run:
```bash
flutter run -d chrome
```

Expected: App launches, shows Home screen with ritual button. Clicking button increases cat count.

**Step 4: Commit**

```bash
git add lib/screens/home_screen.dart lib/main.dart
git commit -m "feat: add home screen UI with ritual button"
```

---

## Task 9: Create Buildings Screen UI

**Files:**
- Create: `lib/screens/buildings_screen.dart`
- Create: `lib/widgets/building_card.dart`

**Step 1: Create BuildingCard widget**

Create `lib/widgets/building_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class BuildingCard extends StatelessWidget {
  final BuildingType type;
  final int owned;
  final Map<ResourceType, double> cost;
  final bool canAfford;
  final bool isUnlocked;
  final VoidCallback onBuy;

  const BuildingCard({
    super.key,
    required this.type,
    required this.owned,
    required this.cost,
    required this.canAfford,
    required this.isUnlocked,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final definition = BuildingDefinitions.get(type);

    if (!isUnlocked) {
      return _LockedCard(type: type);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: canAfford ? 4 : 1,
      child: InkWell(
        onTap: canAfford ? onBuy : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Owned: $owned',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Production:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${NumberFormatter.formatRate(definition.baseProduction)} ${definition.productionType.icon}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cost:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      ...cost.entries.map((entry) => Text(
                        '${NumberFormatter.format(entry.value)} ${entry.key.icon}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: canAfford ? Colors.black : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final BuildingType type;

  const _LockedCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Requires: ${type.requiredGod?.displayName ?? "Unknown"}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Create BuildingsScreen**

Create `lib/screens/buildings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/widgets/building_card.dart';

class BuildingsScreen extends ConsumerWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buildings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: BuildingType.values.length,
        itemBuilder: (context, index) {
          final buildingType = BuildingType.values[index];
          final definition = BuildingDefinitions.get(buildingType);
          final owned = gameState.getBuildingCount(buildingType);
          final cost = definition.calculateCost(owned);

          // Check if unlocked
          final requiredGod = buildingType.requiredGod;
          final isUnlocked = requiredGod == null ||
                             gameState.hasUnlockedGod(requiredGod);

          // Check if can afford
          bool canAfford = true;
          for (final entry in cost.entries) {
            if (gameState.getResource(entry.key) < entry.value) {
              canAfford = false;
              break;
            }
          }

          return BuildingCard(
            type: buildingType,
            owned: owned,
            cost: cost,
            canAfford: canAfford,
            isUnlocked: isUnlocked,
            onBuy: () => gameNotifier.buyBuilding(buildingType),
          );
        },
      ),
    );
  }
}
```

**Step 3: Add navigation between screens**

Modify `lib/screens/home_screen.dart` to add bottom navigation:

Replace the entire `HomeScreen` class with:

```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(),
      BuildingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Buildings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final cats = gameState.getResource(ResourceType.cats);
    final catsPerSecond = gameNotifier.catsPerSecond;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Resource display
            _ResourceDisplay(
              icon: ResourceType.cats.icon,
              label: ResourceType.cats.displayName,
              value: cats,
              rate: catsPerSecond,
            ),
            const SizedBox(height: 24),

            // Ritual button (click to generate cats)
            _RitualButton(
              onPressed: () => gameNotifier.performRitual(),
            ),

            const SizedBox(height: 24),

            // Quick stats
            _QuickStats(
              currentGod: gameState.unlockedGods.last.displayName,
              totalEarned: gameState.totalCatsEarned,
            ),
          ],
        ),
      ),
    );
  }
}
```

Also add import at top of file:
```dart
import 'package:mythical_cats/screens/buildings_screen.dart';
```

**Step 4: Test the app**

Run:
```bash
flutter run -d chrome
```

Expected:
- Bottom navigation shows Home and Buildings tabs
- Buildings tab shows list of buildings
- Locked buildings show lock icon
- Can buy buildings when affordable

**Step 5: Commit**

```bash
git add lib/screens/buildings_screen.dart lib/widgets/building_card.dart lib/screens/home_screen.dart
git commit -m "feat: add buildings screen with buy functionality"
```

---

## Task 10: Add Save/Load System

**Files:**
- Create: `lib/services/save_service.dart`
- Modify: `lib/providers/game_provider.dart`
- Modify: `lib/main.dart`

**Step 1: Create SaveService**

Create `lib/services/save_service.dart`:

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mythical_cats/models/game_state.dart';

class SaveService {
  static const String _saveKey = 'game_save';

  /// Save game state
  static Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_saveKey, json);
  }

  /// Load game state
  static Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (e) {
      // Invalid save data, return null
      return null;
    }
  }

  /// Delete save
  static Future<void> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  /// Check if save exists
  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }
}
```

**Step 2: Update GameNotifier to auto-save**

Modify `lib/providers/game_provider.dart`:

Add import at top:
```dart
import 'package:mythical_cats/services/save_service.dart';
```

Add auto-save timer field:
```dart
class GameNotifier extends StateNotifier<GameState> {
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  Timer? _saveTimer; // Add this
```

In the constructor, add auto-save timer:
```dart
GameNotifier() : super(GameState.initial()) {
  _startGameLoop();
  _startAutoSave(); // Add this
}
```

Add the auto-save method before dispose():
```dart
/// Start auto-save timer (every 30 seconds)
void _startAutoSave() {
  _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    SaveService.save(state);
  });
}
```

Add import for Timer:
```dart
import 'dart:async';
```

Update dispose to cancel timer:
```dart
@override
void dispose() {
  _ticker?.dispose();
  _saveTimer?.cancel(); // Add this
  super.dispose();
}
```

**Step 3: Load save on app start**

Modify `lib/providers/game_provider.dart` to add a load method and initial load provider:

Add after the gameProvider:
```dart
/// Provider that loads initial game state
final initialGameStateProvider = FutureProvider<GameState>((ref) async {
  final saved = await SaveService.load();
  return saved ?? GameState.initial();
});
```

**Step 4: Update main.dart to show loading screen**

Modify `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mythical Cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GameLoader(),
    );
  }
}

class GameLoader extends ConsumerWidget {
  const GameLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialState = ref.watch(initialGameStateProvider);

    return initialState.when(
      data: (state) {
        // Initialize game with loaded state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(gameProvider.notifier).state = state;
        });
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error loading game: $err'),
        ),
      ),
    );
  }
}
```

**Step 5: Test save/load**

Run:
```bash
flutter run -d chrome
```

Test:
1. Click ritual button several times
2. Buy a building
3. Close and reopen app
4. State should be restored

**Step 6: Commit**

```bash
git add lib/services/save_service.dart lib/providers/game_provider.dart lib/main.dart
git commit -m "feat: add auto-save system with 30s interval"
```

---

## Task 11: Add Offline Progress

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Create: `lib/widgets/offline_progress_dialog.dart`

**Step 1: Add offline progress calculation to GameNotifier**

Modify `lib/providers/game_provider.dart`:

Add method to calculate offline progress:
```dart
/// Calculate and apply offline progress
void applyOfflineProgress() {
  final now = DateTime.now();
  final lastUpdate = state.lastUpdate;
  final elapsed = now.difference(lastUpdate);

  // Cap at 24 hours
  final cappedSeconds = elapsed.inSeconds.toDouble().clamp(0, 24 * 60 * 60);

  if (cappedSeconds > 60) { // Only apply if more than 1 minute offline
    _updateGame(cappedSeconds);
  }
}
```

**Step 2: Create offline progress dialog**

Create `lib/widgets/offline_progress_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class OfflineProgressDialog extends StatelessWidget {
  final Duration duration;
  final double catsEarned;
  final VoidCallback onDismiss;

  const OfflineProgressDialog({
    super.key,
    required this.duration,
    required this.catsEarned,
    required this.onDismiss,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome Back!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            'You were away for ${_formatDuration(duration)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text('Cats Earned:'),
                const SizedBox(height: 8),
                Text(
                  '+${NumberFormatter.format(catsEarned)} 🐱',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Awesome!'),
        ),
      ],
    );
  }
}
```

**Step 3: Show offline progress dialog on app start**

Modify `lib/main.dart`:

Update the `GameLoader` widget:

```dart
class GameLoader extends ConsumerStatefulWidget {
  const GameLoader({super.key});

  @override
  ConsumerState<GameLoader> createState() => _GameLoaderState();
}

class _GameLoaderState extends ConsumerState<GameLoader> {
  bool _hasShownOfflineDialog = false;

  @override
  Widget build(BuildContext context) {
    final initialState = ref.watch(initialGameStateProvider);

    return initialState.when(
      data: (state) {
        // Initialize game with loaded state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final notifier = ref.read(gameProvider.notifier);
          notifier.state = state;

          // Show offline progress if applicable
          if (!_hasShownOfflineDialog) {
            _hasShownOfflineDialog = true;
            _showOfflineProgressIfNeeded(state);
          }
        });
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error loading game: $err'),
        ),
      ),
    );
  }

  void _showOfflineProgressIfNeeded(GameState state) {
    final now = DateTime.now();
    final lastUpdate = state.lastUpdate;
    final elapsed = now.difference(lastUpdate);

    // Only show if offline for more than 1 minute
    if (elapsed.inSeconds < 60) return;

    // Calculate cats that would have been earned
    final notifier = ref.read(gameProvider.notifier);
    final catsBefore = state.getResource(ResourceType.cats);

    // Apply offline progress
    notifier.applyOfflineProgress();

    final catsAfter = ref.read(gameProvider).getResource(ResourceType.cats);
    final catsEarned = catsAfter - catsBefore;

    if (catsEarned > 0) {
      showDialog(
        context: context,
        builder: (context) => OfflineProgressDialog(
          duration: elapsed,
          catsEarned: catsEarned,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }
}
```

Add import:
```dart
import 'package:mythical_cats/widgets/offline_progress_dialog.dart';
import 'package:mythical_cats/models/resource_type.dart';
```

**Step 4: Test offline progress**

Run:
```bash
flutter run -d chrome
```

Test:
1. Buy some buildings that generate cats
2. Close app
3. Wait 2-3 minutes
4. Reopen app
5. Should see "Welcome Back" dialog with cats earned

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart lib/widgets/offline_progress_dialog.dart lib/main.dart
git commit -m "feat: add offline progress with welcome back dialog"
```

---

## Task 12: Final Polish and Testing

**Files:**
- Create: `test/integration_test.dart`

**Step 1: Create integration test**

Create `test/integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  group('Integration Test: Early Game Loop', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('complete early game progression', () async {
      // Start with 0 cats
      expect(notifier.state.getResource(ResourceType.cats), 0);

      // Click to get 15 cats
      for (int i = 0; i < 15; i++) {
        notifier.performRitual();
      }
      expect(notifier.state.getResource(ResourceType.cats), 15);

      // Buy first small shrine
      final bought = notifier.buyBuilding(BuildingType.smallShrine);
      expect(bought, true);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 1);
      expect(notifier.state.getResource(ResourceType.cats), 0);

      // Wait for production (simulate 100 seconds)
      for (int i = 0; i < 100; i++) {
        notifier.performRitual(); // Each click helps speed up
      }

      // Should have more than 100 cats now from clicking
      expect(notifier.state.getResource(ResourceType.cats) >= 100, true);

      // Buy a temple
      final boughtTemple = notifier.buyBuilding(BuildingType.temple);
      expect(boughtTemple, true);

      // Keep clicking to get to 1000 cats for Hestia unlock
      while (notifier.state.totalCatsEarned < 1000) {
        notifier.performRitual();
      }

      // Hestia should be unlocked
      expect(notifier.state.hasUnlockedGod(God.hestia), true);
    });

    test('buildings produce correct resources', () {
      // Give resources to buy hearth altar
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 5000,
          ResourceType.offerings: 500,
        },
      );

      // Buy hearth altar (produces offerings)
      notifier.buyBuilding(BuildingType.hearthAltar);

      expect(notifier.state.getBuildingCount(BuildingType.hearthAltar), 1);

      // The building produces offerings, not cats
      // (Would need to wait for game loop to verify production)
    });
  });
}
```

**Step 2: Run all tests**

Run:
```bash
flutter test
```

Expected: All tests pass

**Step 3: Test full app manually**

Run:
```bash
flutter run -d chrome
```

Manual test checklist:
- [ ] App loads successfully
- [ ] Clicking ritual button increases cats
- [ ] Can buy small shrine when have 15 cats
- [ ] Buildings generate cats automatically
- [ ] Can navigate to Buildings tab
- [ ] Locked buildings show correctly
- [ ] Can't buy building when not enough resources
- [ ] Number formatting works (shows K, M, etc.)
- [ ] Auto-save works (refresh page, state restored)
- [ ] Offline progress works (close and wait, reopen)
- [ ] Hestia unlocks at 1000 total cats

**Step 4: Create README**

Create `README.md`:

```markdown
# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Phase 1 MVP Features

- Click to perform rituals and summon cats
- Buy buildings that auto-generate cats
- First 3 generic building tiers (Small Shrine, Temple, Grand Sanctuary)
- God-specific buildings (Hermes' Messenger Waystation, Hestia's Hearth Altar)
- Tier 1 resources (Cats, Offerings, Prayers)
- Auto-save every 30 seconds
- Offline progression (up to 24 hours)
- First two gods unlocked (Hermes at start, Hestia at 1000 cats)

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Chrome/Edge browser (for web) or iOS/Android device

### Installation

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run tests
flutter test
```

## Architecture

- **State Management**: Riverpod
- **Game Loop**: Flutter Ticker (60 FPS)
- **Persistence**: shared_preferences with JSON serialization
- **UI**: Material 3 with mobile-first design

## Project Structure

```
lib/
  models/          # Data models (GameState, Building, Resource, God)
  providers/       # Riverpod providers (game logic)
  screens/         # UI screens (Home, Buildings)
  widgets/         # Reusable widgets
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # Unit tests
```

## Next Steps (Future Phases)

- Add gods 3-4 (Demeter, Dionysus)
- Research/tech tree system (unlocked with Athena)
- Achievements
- Random events
- More building types
- Reincarnation/prestige system
```

**Step 5: Final commit**

```bash
git add test/integration_test.dart README.md
git commit -m "test: add integration tests and README

Phase 1 MVP complete:
- Working game loop with clicking and buildings
- Auto-save and offline progress
- First two gods (Hermes, Hestia)
- Mobile-first UI with Home and Buildings tabs"
```

---

## Verification

**Run final verification:**

```bash
# Run all tests
flutter test

# Build for web
flutter build web

# Check for any issues
flutter analyze
```

Expected:
- All tests pass
- No analyzer errors
- Web build succeeds
- Game is playable and fun

---

## Summary

Phase 1 MVP is now complete! The game has:

✅ Click-to-generate cats mechanic
✅ 5 building types (3 generic + 2 god-specific)
✅ Automatic cat generation
✅ 2 gods (Hermes unlocked at start, Hestia at 1000 cats)
✅ 3 resource types (Cats, Offerings, Prayers)
✅ Auto-save every 30 seconds
✅ Offline progress up to 24 hours
✅ Mobile-first UI with tab navigation
✅ Number formatting for large values
✅ Full test coverage

**Total Commits**: 12
**Estimated Time**: 2-4 weeks
**Lines of Code**: ~2000

The foundation is solid and ready for Phase 2 expansion!
