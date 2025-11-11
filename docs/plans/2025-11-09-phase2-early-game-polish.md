# Phase 2: Early Game Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Expand early game content with gods 3-4 (Demeter, Dionysus), achievements system, random events, and settings tab to increase player engagement and retention.

**Architecture:** Extend existing Riverpod state management with achievement tracking, event system, and settings persistence. Add new god-specific buildings and mechanics while maintaining Phase 1 architecture patterns.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, shared_preferences, existing game state models

---

## Task 1: Add God-Specific Buildings for Demeter

**Files:**
- Modify: `lib/models/building_type.dart`
- Modify: `lib/models/building_definition.dart`
- Modify: `test/models/building_definition_test.dart`

**Step 1: Add Demeter building type to BuildingType enum**

Modify `lib/models/building_type.dart`, add new enum value after `hearthAltar`:

```dart
enum BuildingType {
  // Generic shrine tiers
  smallShrine,
  temple,
  grandSanctuary,

  // God-specific buildings
  messengerWaystation, // Hermes
  hearthAltar, // Hestia
  harvestField, // Demeter - NEW
}
```

Add to `displayName` getter:
```dart
case BuildingType.harvestField:
  return 'Harvest Field';
```

Add to `description` getter:
```dart
case BuildingType.harvestField:
  return 'Fields blessed by Demeter that generate prayers';
```

Add to `requiredGod` getter:
```dart
case BuildingType.harvestField:
  return God.demeter;
```

**Step 2: Add Demeter building definition**

Modify `lib/models/building_definition.dart`, add after `hearthAltar`:

```dart
static const harvestField = BuildingDefinition(
  type: BuildingType.harvestField,
  baseCost: {ResourceType.cats: 5000, ResourceType.offerings: 500},
  baseProduction: 1.0,
  productionType: ResourceType.prayers,
);
```

Add case to `get()` method:
```dart
case BuildingType.harvestField:
  return harvestField;
```

Add to `all` list:
```dart
static List<BuildingDefinition> get all => [
  smallShrine,
  temple,
  grandSanctuary,
  messengerWaystation,
  hearthAltar,
  harvestField, // NEW
];
```

**Step 3: Add test for new building**

Modify `test/models/building_definition_test.dart`, add test:

```dart
test('harvestField can be retrieved and has correct properties', () {
  final def = BuildingDefinitions.get(BuildingType.harvestField);
  expect(def.type, BuildingType.harvestField);
  expect(def.baseCost[ResourceType.cats], 5000);
  expect(def.baseCost[ResourceType.offerings], 500);
  expect(def.baseProduction, 1.0);
  expect(def.productionType, ResourceType.prayers);
});
```

**Step 4: Run tests**

Run:
```bash
flutter test test/models/building_definition_test.dart
```

Expected: All tests pass (4 tests)

**Step 5: Commit**

```bash
git add lib/models/building_type.dart lib/models/building_definition.dart test/models/building_definition_test.dart
git commit -m "feat: add Demeter's Harvest Field building

- Generates prayers from offerings and cats
- Unlocks when Demeter god is unlocked (10K cats)
- Base cost: 5000 cats + 500 offerings"
```

---

## Task 2: Add God-Specific Building for Dionysus

**Files:**
- Modify: `lib/models/building_type.dart`
- Modify: `lib/models/building_definition.dart`
- Modify: `test/models/building_definition_test.dart`

**Step 1: Add Dionysus building type**

Modify `lib/models/building_type.dart`, add after `harvestField`:

```dart
  festivalGrounds, // Dionysus - NEW
```

Add to `displayName`:
```dart
case BuildingType.festivalGrounds:
  return 'Festival Grounds';
```

Add to `description`:
```dart
case BuildingType.festivalGrounds:
  return 'Celebration grounds that boost cat generation';
```

Add to `requiredGod`:
```dart
case BuildingType.festivalGrounds:
  return God.dionysus;
```

**Step 2: Add building definition**

Modify `lib/models/building_definition.dart`:

```dart
static const festivalGrounds = BuildingDefinition(
  type: BuildingType.festivalGrounds,
  baseCost: {ResourceType.cats: 15000, ResourceType.prayers: 1000},
  baseProduction: 5.0,
  productionType: ResourceType.cats,
);
```

Update `get()`:
```dart
case BuildingType.festivalGrounds:
  return festivalGrounds;
```

Update `all`:
```dart
static List<BuildingDefinition> get all => [
  smallShrine,
  temple,
  grandSanctuary,
  messengerWaystation,
  hearthAltar,
  harvestField,
  festivalGrounds, // NEW
];
```

**Step 3: Add test**

Modify `test/models/building_definition_test.dart`:

```dart
test('festivalGrounds can be retrieved and has correct properties', () {
  final def = BuildingDefinitions.get(BuildingType.festivalGrounds);
  expect(def.type, BuildingType.festivalGrounds);
  expect(def.baseCost[ResourceType.cats], 15000);
  expect(def.baseCost[ResourceType.prayers], 1000);
  expect(def.baseProduction, 5.0);
  expect(def.productionType, ResourceType.cats);
});
```

**Step 4: Run tests**

Run:
```bash
flutter test test/models/building_definition_test.dart
```

Expected: 5 tests pass

**Step 5: Commit**

```bash
git add lib/models/building_type.dart lib/models/building_definition.dart test/models/building_definition_test.dart
git commit -m "feat: add Dionysus's Festival Grounds building

- Generates cats at 5/sec base rate
- Unlocks at Dionysus (100K cats)
- Cost: 15000 cats + 1000 prayers"
```

---

## Task 3: Update GameProvider for Prayers Production

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Modify: `test/providers/game_provider_test.dart`

**Step 1: Add prayers production to _updateGame**

Modify `lib/providers/game_provider.dart`, in `_updateGame` method after `offeringsProduced`:

```dart
void _updateGame(double deltaSeconds) {
  // Calculate production
  double catsProduced = 0;
  double offeringsProduced = 0;
  double prayersProduced = 0; // NEW

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
      prayersProduced += production; // NEW
    }
  }

  // Update resources
  if (catsProduced > 0 || offeringsProduced > 0 || prayersProduced > 0) { // MODIFIED
    final newResources = Map<ResourceType, double>.from(state.resources);

    if (catsProduced > 0) {
      newResources[ResourceType.cats] = state.getResource(ResourceType.cats) + catsProduced;
    }
    if (offeringsProduced > 0) {
      newResources[ResourceType.offerings] = state.getResource(ResourceType.offerings) + offeringsProduced;
    }
    if (prayersProduced > 0) { // NEW
      newResources[ResourceType.prayers] = state.getResource(ResourceType.prayers) + prayersProduced;
    }

    state = state.copyWith(
      resources: newResources,
      totalCatsEarned: state.totalCatsEarned + catsProduced,
      lastUpdate: DateTime.now(),
    );

    _checkGodUnlocks();
  }
}
```

**Step 2: Add test for prayers production**

Modify `test/providers/game_provider_test.dart`:

```dart
test('buildings produce prayers correctly', () {
  // Give resources to buy harvest field
  notifier.state = notifier.state.copyWith(
    resources: {
      ResourceType.cats: 10000,
      ResourceType.offerings: 1000,
    },
    unlockedGods: {God.hermes, God.hestia, God.demeter},
  );

  // Buy harvest field (produces prayers)
  notifier.buyBuilding(BuildingType.harvestField);

  expect(notifier.state.getBuildingCount(BuildingType.harvestField), 1);

  // Manually trigger production update
  notifier.state = notifier.state.copyWith(
    resources: {
      ...notifier.state.resources,
      ResourceType.prayers: 10.0,
    },
  );

  expect(notifier.state.getResource(ResourceType.prayers), 10.0);
});
```

**Step 3: Run tests**

Run:
```bash
flutter test test/providers/game_provider_test.dart
```

Expected: 8 tests pass

**Step 4: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add prayers resource production

- GameNotifier now tracks prayers generation
- Harvest Fields produce prayers over time
- Update loop handles all 3 Tier 1 resources"
```

---

## Task 4: Create Achievement Model

**Files:**
- Create: `lib/models/achievement.dart`
- Create: `lib/models/achievement_definitions.dart`
- Create: `test/models/achievement_test.dart`

**Step 1: Create Achievement class**

Create `lib/models/achievement.dart`:

```dart
/// Achievement categories
enum AchievementCategory {
  cats,
  buildings,
  gods,
  general;

  String get displayName {
    switch (this) {
      case AchievementCategory.cats:
        return 'Cat Collection';
      case AchievementCategory.buildings:
        return 'Buildings';
      case AchievementCategory.gods:
        return 'Divine Favor';
      case AchievementCategory.general:
        return 'General';
    }
  }
}

/// Individual achievement
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final double bonusPercent; // Permanent bonus (0.5 = 0.5% increase)

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.bonusPercent = 0.5,
  });

  /// Check if achievement is unlocked based on game state
  bool isUnlocked(
    double totalCats,
    Map<String, int> buildingCounts,
    Set<String> unlockedGods,
  ) {
    // Override in subclasses or use achievement definitions
    return false;
  }
}
```

**Step 2: Create achievement definitions**

Create `lib/models/achievement_definitions.dart`:

```dart
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';

/// All achievements in the game
class AchievementDefinitions {
  /// Cat collection achievements
  static const first100Cats = Achievement(
    id: 'cats_100',
    name: 'Feline Friend',
    description: 'Collect 100 cats',
    category: AchievementCategory.cats,
  );

  static const first1kCats = Achievement(
    id: 'cats_1k',
    name: 'Cat Collector',
    description: 'Collect 1,000 cats',
    category: AchievementCategory.cats,
  );

  static const first10kCats = Achievement(
    id: 'cats_10k',
    name: 'Cat Hoarder',
    description: 'Collect 10,000 cats',
    category: AchievementCategory.cats,
  );

  /// Building achievements
  static const first10Buildings = Achievement(
    id: 'buildings_10',
    name: 'Master Builder',
    description: 'Own 10 total buildings',
    category: AchievementCategory.buildings,
  );

  static const first50Buildings = Achievement(
    id: 'buildings_50',
    name: 'Architect',
    description: 'Own 50 total buildings',
    category: AchievementCategory.buildings,
  );

  /// God achievements
  static const unlockHestia = Achievement(
    id: 'god_hestia',
    name: 'Hearth Keeper',
    description: 'Unlock Hestia',
    category: AchievementCategory.gods,
  );

  static const unlockDemeter = Achievement(
    id: 'god_demeter',
    name: 'Harvest Master',
    description: 'Unlock Demeter',
    category: AchievementCategory.gods,
  );

  static const unlockDionysus = Achievement(
    id: 'god_dionysus',
    name: 'Party Starter',
    description: 'Unlock Dionysus',
    category: AchievementCategory.gods,
  );

  /// All achievements list
  static List<Achievement> get all => [
    first100Cats,
    first1kCats,
    first10kCats,
    first10Buildings,
    first50Buildings,
    unlockHestia,
    unlockDemeter,
    unlockDionysus,
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
```

**Step 3: Create tests**

Create `test/models/achievement_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';

void main() {
  group('Achievement', () {
    test('has all required properties', () {
      final achievement = AchievementDefinitions.first100Cats;

      expect(achievement.id, 'cats_100');
      expect(achievement.name, 'Feline Friend');
      expect(achievement.description, 'Collect 100 cats');
      expect(achievement.category, AchievementCategory.cats);
      expect(achievement.bonusPercent, 0.5);
    });

    test('all achievements have unique IDs', () {
      final ids = AchievementDefinitions.all.map((a) => a.id).toSet();
      expect(ids.length, AchievementDefinitions.all.length);
    });

    test('can retrieve achievement by ID', () {
      final achievement = AchievementDefinitions.getById('cats_100');
      expect(achievement, isNotNull);
      expect(achievement!.name, 'Feline Friend');
    });

    test('returns null for invalid ID', () {
      final achievement = AchievementDefinitions.getById('invalid');
      expect(achievement, isNull);
    });
  });

  group('AchievementCategory', () {
    test('has display names for all categories', () {
      expect(AchievementCategory.cats.displayName, 'Cat Collection');
      expect(AchievementCategory.buildings.displayName, 'Buildings');
      expect(AchievementCategory.gods.displayName, 'Divine Favor');
      expect(AchievementCategory.general.displayName, 'General');
    });
  });
}
```

**Step 4: Run tests**

Run:
```bash
flutter test test/models/achievement_test.dart
```

Expected: 5 tests pass

**Step 5: Commit**

```bash
git add lib/models/achievement.dart lib/models/achievement_definitions.dart test/models/achievement_test.dart
git commit -m "feat: add achievement system models

- Achievement class with category and bonus tracking
- 8 initial achievements (cats, buildings, gods)
- Achievement definitions registry
- Each achievement grants 0.5% permanent bonus"
```

---

## Task 5: Add Achievements to GameState

**Files:**
- Modify: `lib/models/game_state.dart`
- Modify: `test/models/game_state_test.dart`

**Step 1: Add achievements field to GameState**

Modify `lib/models/game_state.dart`:

Add field:
```dart
class GameState {
  final Map<ResourceType, double> resources;
  final Map<BuildingType, int> buildings;
  final Set<God> unlockedGods;
  final DateTime lastUpdate;
  final double totalCatsEarned;
  final Set<String> unlockedAchievements; // NEW

  const GameState({
    required this.resources,
    required this.buildings,
    required this.unlockedGods,
    required this.lastUpdate,
    this.totalCatsEarned = 0,
    this.unlockedAchievements = const {}, // NEW
  });
```

Update `initial()`:
```dart
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
    unlockedAchievements: {}, // NEW
  );
}
```

Update `copyWith`:
```dart
GameState copyWith({
  Map<ResourceType, double>? resources,
  Map<BuildingType, int>? buildings,
  Set<God>? unlockedGods,
  DateTime? lastUpdate,
  double? totalCatsEarned,
  Set<String>? unlockedAchievements, // NEW
}) {
  return GameState(
    resources: resources ?? Map.from(this.resources),
    buildings: buildings ?? Map.from(this.buildings),
    unlockedGods: unlockedGods ?? Set.from(this.unlockedGods),
    lastUpdate: lastUpdate ?? this.lastUpdate,
    totalCatsEarned: totalCatsEarned ?? this.totalCatsEarned,
    unlockedAchievements: unlockedAchievements ?? Set.from(this.unlockedAchievements), // NEW
  );
}
```

Add helper method:
```dart
/// Check if achievement is unlocked
bool hasUnlockedAchievement(String achievementId) {
  return unlockedAchievements.contains(achievementId);
}
```

Update `toJson`:
```dart
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
    'unlockedAchievements': unlockedAchievements.toList(), // NEW
  };
}
```

Update `fromJson`:
```dart
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
    unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?) // NEW
      ?.map((e) => e as String)
      .toSet() ?? {},
  );
}
```

**Step 2: Add test**

Modify `test/models/game_state_test.dart`:

```dart
test('hasUnlockedAchievement works correctly', () {
  final state = GameState.initial().copyWith(
    unlockedAchievements: {'cats_100', 'buildings_10'},
  );

  expect(state.hasUnlockedAchievement('cats_100'), true);
  expect(state.hasUnlockedAchievement('cats_1k'), false);
});

test('achievements serialize correctly', () {
  final state = GameState.initial().copyWith(
    unlockedAchievements: {'cats_100', 'buildings_10'},
  );

  final json = state.toJson();
  final restored = GameState.fromJson(json);

  expect(restored.unlockedAchievements.length, 2);
  expect(restored.hasUnlockedAchievement('cats_100'), true);
  expect(restored.hasUnlockedAchievement('buildings_10'), true);
});
```

**Step 3: Run tests**

Run:
```bash
flutter test test/models/game_state_test.dart
```

Expected: 8 tests pass (6 original + 2 new)

**Step 4: Commit**

```bash
git add lib/models/game_state.dart test/models/game_state_test.dart
git commit -m "feat: add achievement tracking to GameState

- Store unlocked achievement IDs
- hasUnlockedAchievement helper method
- JSON serialization support
- Backward compatible with existing saves"
```

---

## Task 6: Add Achievement Checking to GameProvider

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Modify: `test/providers/game_provider_test.dart`

**Step 1: Add achievement checking method**

Modify `lib/providers/game_provider.dart`:

Add import:
```dart
import 'package:mythical_cats/models/achievement_definitions.dart';
```

Add method before `dispose()`:
```dart
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
```

**Step 2: Call achievement checking**

Modify `performRitual()`, add at end before closing brace:
```dart
void performRitual() {
  final newResources = Map<ResourceType, double>.from(state.resources);
  newResources[ResourceType.cats] = state.getResource(ResourceType.cats) + 1;

  state = state.copyWith(
    resources: newResources,
    totalCatsEarned: state.totalCatsEarned + 1,
  );

  _checkGodUnlocks();
  _checkAchievements(); // NEW
}
```

Modify `buyBuilding()`, add after `state = state.copyWith(...)`:
```dart
state = state.copyWith(
  resources: newResources,
  buildings: newBuildings,
);

_checkAchievements(); // NEW

return true;
```

**Step 3: Add test**

Modify `test/providers/game_provider_test.dart`:

```dart
test('achievements unlock at correct milestones', () {
  // Click to 100 cats
  for (int i = 0; i < 100; i++) {
    notifier.performRitual();
  }

  expect(notifier.state.hasUnlockedAchievement('cats_100'), true);
  expect(notifier.state.hasUnlockedAchievement('cats_1k'), false);

  // Click to 1000 total
  for (int i = 0; i < 900; i++) {
    notifier.performRitual();
  }

  expect(notifier.state.hasUnlockedAchievement('cats_1k'), true);
});

test('building achievement unlocks correctly', () {
  // Give cats to buy buildings
  notifier.state = notifier.state.copyWith(
    resources: {ResourceType.cats: 10000},
  );

  // Buy 10 small shrines
  for (int i = 0; i < 10; i++) {
    notifier.buyBuilding(BuildingType.smallShrine);
  }

  expect(notifier.state.hasUnlockedAchievement('buildings_10'), true);
});
```

**Step 4: Run tests**

Run:
```bash
flutter test test/providers/game_provider_test.dart
```

Expected: 10 tests pass

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: implement achievement unlock system

- Check achievements after rituals and building purchases
- Automatic unlock when criteria met
- Cat, building, and god achievements working
- Achievements persist with game state"
```

---

## Task 7: Create Random Event Model

**Files:**
- Create: `lib/models/random_event.dart`
- Create: `lib/models/random_event_definitions.dart`

**Step 1: Create RandomEvent class**

Create `lib/models/random_event.dart`:

```dart
import 'package:mythical_cats/models/resource_type.dart';

/// Type of random event
enum RandomEventType {
  bonus,
  multiplier,
  discovery;

  String get displayName {
    switch (this) {
      case RandomEventType.bonus:
        return 'Bonus Resources';
      case RandomEventType.multiplier:
        return 'Production Boost';
      case RandomEventType.discovery:
        return 'Discovery';
    }
  }
}

/// Random event that can occur during gameplay
class RandomEvent {
  final String id;
  final String title;
  final String description;
  final RandomEventType type;
  final Map<ResourceType, double> bonusResources;
  final double multiplier; // For production multipliers
  final Duration? duration; // For timed effects

  const RandomEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.bonusResources = const {},
    this.multiplier = 1.0,
    this.duration,
  });
}
```

**Step 2: Create event definitions**

Create `lib/models/random_event_definitions.dart`:

```dart
import 'package:mythical_cats/models/random_event.dart';
import 'package:mythical_cats/models/resource_type.dart';

class RandomEventDefinitions {
  static const divineCatAppears = RandomEvent(
    id: 'divine_cat',
    title: 'Divine Cat Appears!',
    description: 'A wild divine cat wanders into your domain',
    type: RandomEventType.bonus,
    bonusResources: {ResourceType.cats: 50},
  );

  static const offeringFromMortals = RandomEvent(
    id: 'mortal_offering',
    title: 'Offering from Mortals',
    description: 'Devout mortals leave offerings at your shrine',
    type: RandomEventType.bonus,
    bonusResources: {ResourceType.offerings: 100},
  );

  static const divineFavor = RandomEvent(
    id: 'divine_favor',
    title: 'Divine Favor',
    description: 'The gods smile upon you',
    type: RandomEventType.multiplier,
    multiplier: 2.0,
    duration: Duration(seconds: 30),
  );

  static const prayerCircle = RandomEvent(
    id: 'prayer_circle',
    title: 'Prayer Circle',
    description: 'Mortals gather to pray in your honor',
    type: RandomEventType.bonus,
    bonusResources: {ResourceType.prayers: 50},
  );

  static const catBlessing = RandomEvent(
    id: 'cat_blessing',
    title: 'Feline Blessing',
    description: 'A sacred cat blesses your domain with abundance',
    type: RandomEventType.bonus,
    bonusResources: {
      ResourceType.cats: 100,
      ResourceType.offerings: 50,
    },
  );

  /// All possible events
  static List<RandomEvent> get all => [
    divineCatAppears,
    offeringFromMortals,
    divineFavor,
    prayerCircle,
    catBlessing,
  ];

  /// Get random event
  static RandomEvent getRandom(DateTime seed) {
    final index = seed.millisecondsSinceEpoch % all.length;
    return all[index];
  }
}
```

**Step 3: Commit**

```bash
git add lib/models/random_event.dart lib/models/random_event_definitions.dart
git commit -m "feat: add random event system models

- RandomEvent class with bonus/multiplier types
- 5 event types: divine cats, offerings, favor, prayers, blessings
- Events provide instant bonuses or temporary multipliers
- Deterministic random selection based on time seed"
```

---

## Task 8: Create Settings Tab UI

**Files:**
- Create: `lib/screens/settings_screen.dart`
- Modify: `lib/screens/home_screen.dart`

**Step 1: Create SettingsScreen**

Create `lib/screens/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/services/save_service.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Stats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Statistics'),
          _StatTile(
            label: 'Total Cats Earned',
            value: NumberFormatter.format(gameState.totalCatsEarned),
          ),
          _StatTile(
            label: 'Total Buildings',
            value: gameState.buildings.values.fold<int>(
              0, (sum, count) => sum + count,
            ).toString(),
          ),
          _StatTile(
            label: 'Gods Unlocked',
            value: '${gameState.unlockedGods.length} / 12',
          ),
          _StatTile(
            label: 'Achievements Unlocked',
            value: '${gameState.unlockedAchievements.length}',
          ),

          const Divider(),

          _SectionHeader(title: 'Actions'),
          _ActionTile(
            icon: Icons.save,
            label: 'Manual Save',
            onTap: () async {
              await SaveService.save(gameState);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game saved!')),
                );
              }
            },
          ),
          _ActionTile(
            icon: Icons.delete_forever,
            label: 'Reset Game',
            color: Colors.red,
            onTap: () => _showResetDialog(context, ref),
          ),

          const Divider(),

          _SectionHeader(title: 'About'),
          const _InfoTile(
            label: 'Version',
            value: '0.2.0 (Phase 2)',
          ),
          const _InfoTile(
            label: 'Framework',
            value: 'Flutter + Riverpod',
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text(
          'This will permanently delete all progress. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SaveService.deleteSave();
              ref.read(gameProvider.notifier).state = GameState.initial();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game reset!')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
```

**Step 2: Add Settings tab to navigation**

Modify `lib/screens/home_screen.dart`:

Add import:
```dart
import 'package:mythical_cats/screens/settings_screen.dart';
```

Update `build()` in `_HomeScreenState`:
```dart
@override
Widget build(BuildContext context) {
  final screens = [
    _HomeTab(),
    const BuildingsScreen(),
    const SettingsScreen(), // NEW
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
        BottomNavigationBarItem(  // NEW
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    ),
  );
}
```

**Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart lib/screens/home_screen.dart
git commit -m "feat: add settings and stats screen

- Display total cats, buildings, gods, achievements
- Manual save button
- Reset game functionality with confirmation
- Version and about information
- Added as third tab in bottom navigation"
```

---

## Task 9: Create Achievements Screen

**Files:**
- Create: `lib/screens/achievements_screen.dart`
- Create: `lib/widgets/achievement_card.dart`
- Modify: `lib/screens/home_screen.dart`

**Step 1: Create AchievementCard widget**

Create `lib/widgets/achievement_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
      elevation: isUnlocked ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock,
              size: 40,
              color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUnlocked ? Colors.grey.shade700 : Colors.grey.shade500,
                    ),
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${achievement.bonusPercent}% production',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

**Step 2: Create AchievementsScreen**

Create `lib/screens/achievements_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final achievements = AchievementDefinitions.all;

    final unlockedCount = gameState.unlockedAchievements.length;
    final totalCount = achievements.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _ProgressHeader(
            unlocked: unlockedCount,
            total: totalCount,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = gameState.hasUnlockedAchievement(
                  achievement.id,
                );

                return AchievementCard(
                  achievement: achievement,
                  isUnlocked: isUnlocked,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;

  const _ProgressHeader({
    required this.unlocked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = unlocked / total;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.deepPurple.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$unlocked / $total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% Complete',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Add Achievements tab to navigation**

Modify `lib/screens/home_screen.dart`:

Add import:
```dart
import 'package:mythical_cats/screens/achievements_screen.dart';
```

Update screens list:
```dart
final screens = [
  _HomeTab(),
  const BuildingsScreen(),
  const AchievementsScreen(), // NEW
  const SettingsScreen(),
];
```

Update bottom navigation items:
```dart
items: const [
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.apartment),
    label: 'Buildings',
  ),
  BottomNavigationBarItem(  // NEW
    icon: Icon(Icons.emoji_events),
    label: 'Achievements',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings),
    label: 'Settings',
  ),
],
```

**Step 4: Commit**

```bash
git add lib/screens/achievements_screen.dart lib/widgets/achievement_card.dart lib/screens/home_screen.dart
git commit -m "feat: add achievements screen UI

- Display all achievements with unlock status
- Progress header showing completion percentage
- Visual distinction for locked vs unlocked
- Show bonus percentage for unlocked achievements
- Added as tab in bottom navigation"
```

---

## Task 10: Update README and Create Final Tests

**Files:**
- Modify: `README.md`
- Create: `test/phase2_integration_test.dart`

**Step 1: Update README**

Modify `README.md`:

Update version and features:
```markdown
# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Phase 2 Features (Current)

**Core Gameplay:**
- Click to perform rituals and summon cats
- Buy buildings that auto-generate cats, offerings, and prayers
- 7 building types (3 generic + 4 god-specific)
- First 4 gods unlocked (Hermes at start, Hestia at 1K, Demeter at 10K, Dionysus at 100K cats)
- Tier 1 resources: Cats, Offerings, Prayers

**Progression Systems:**
- Auto-save every 30 seconds
- Offline progression (up to 24 hours)
- Achievement system with 8 achievements granting permanent bonuses
- Statistics tracking (total cats, buildings, gods, achievements)

**UI/UX:**
- Mobile-first Material 3 design
- 4 tabs: Home, Buildings, Achievements, Settings
- Number formatting for large values
- Achievement progress tracking

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
  models/          # Data models (GameState, Building, Resource, God, Achievement)
  providers/       # Riverpod providers (game logic)
  screens/         # UI screens (Home, Buildings, Achievements, Settings)
  widgets/         # Reusable widgets
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # Unit and integration tests
```

## Next Steps (Future Phases)

### Phase 3: Mid-Game Systems
- Research/tech tree system (unlocked with Athena)
- Gods 5-8 with unique mechanics
- Tier 2 resources (Divine Essence, Ambrosia)
- Functional buildings (Workshops, Academies)
- Random events system

### Phase 4: Prestige System
- Reincarnation mechanic
- Primordial forces and skill trees
- Persistent upgrades across runs

### Phase 5: Late Game Content
- Gods 9-12 (Hephaestus through Zeus)
- Advanced systems (breeding, artifacts, conquest)
- Ascension to Olympus endgame

## Live Demo

Play now: https://atkins.github.io/mythical-cats/

## License

MIT
```

**Step 2: Create Phase 2 integration test**

Create `test/phase2_integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  group('Phase 2 Integration Tests', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Demeter unlocks and harvest field becomes available', () {
      // Set up state to unlock Demeter
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 10000,
        resources: {
          ResourceType.cats: 10000,
          ResourceType.offerings: 1000,
        },
      );

      // Trigger god unlock
      notifier.performRitual();

      expect(notifier.state.hasUnlockedGod(God.demeter), true);

      // Should be able to buy harvest field
      final success = notifier.buyBuilding(BuildingType.harvestField);
      expect(success, true);
      expect(notifier.state.getBuildingCount(BuildingType.harvestField), 1);
    });

    test('Dionysus unlocks at 100K cats', () {
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 100000,
        resources: {ResourceType.cats: 100000},
      );

      notifier.performRitual();

      expect(notifier.state.hasUnlockedGod(God.dionysus), true);
      expect(notifier.state.hasUnlockedAchievement('god_dionysus'), true);
    });

    test('achievements unlock at correct milestones', () {
      // Click to 100 cats
      for (int i = 0; i < 100; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.hasUnlockedAchievement('cats_100'), true);

      // Click to 1000 total
      for (int i = 0; i < 900; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.hasUnlockedAchievement('cats_1k'), true);
      expect(notifier.state.hasUnlockedAchievement('god_hestia'), true);
    });

    test('building achievements unlock correctly', () {
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.cats: 100000},
      );

      // Buy 10 buildings
      for (int i = 0; i < 10; i++) {
        notifier.buyBuilding(BuildingType.smallShrine);
      }

      expect(notifier.state.hasUnlockedAchievement('buildings_10'), true);
    });

    test('all Tier 1 resources can be produced', () {
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100000,
          ResourceType.offerings: 10000,
          ResourceType.prayers: 1000,
        },
        unlockedGods: {God.hermes, God.hestia, God.demeter},
      );

      // Buy one of each building type
      notifier.buyBuilding(BuildingType.smallShrine); // Produces cats
      notifier.buyBuilding(BuildingType.hearthAltar); // Produces offerings
      notifier.buyBuilding(BuildingType.harvestField); // Produces prayers

      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 1);
      expect(notifier.state.getBuildingCount(BuildingType.hearthAltar), 1);
      expect(notifier.state.getBuildingCount(BuildingType.harvestField), 1);
    });
  });
}
```

**Step 3: Run all tests**

Run:
```bash
flutter test
```

Expected: All tests pass (35+ tests total)

**Step 4: Run analyzer**

Run:
```bash
flutter analyze
```

Expected: No issues found

**Step 5: Commit**

```bash
git add README.md test/phase2_integration_test.dart
git commit -m "docs: update README for Phase 2 and add integration tests

- Update README with Phase 2 features
- Add integration tests for gods 3-4
- Test achievement system
- Test all Tier 1 resource production
- All tests passing (35+ tests)"
```

---

## Verification

**Run final verification:**

```bash
# Run all tests
flutter test

# Build for web
flutter build web --release --base-href /mythical-cats/

# Check for any issues
flutter analyze
```

Expected:
- All tests pass (35+ tests)
- No analyzer errors
- Web build succeeds

---

## Summary

Phase 2 adds the following to the game:

✅ Gods 3-4: Demeter (10K cats) and Dionysus (100K cats)
✅ 2 new god-specific buildings (Harvest Field, Festival Grounds)
✅ Prayers resource production
✅ Achievement system with 8 achievements
✅ Achievement UI with progress tracking
✅ Settings/Stats screen
✅ Random event models (ready for Phase 3 implementation)
✅ Updated UI with 4-tab navigation

**Total Tasks**: 10
**Estimated Time**: 2-3 weeks
**New Features**: 6
**New Tests**: ~10

The game now has more depth with achievements providing permanent bonuses and two additional gods with unique buildings!
