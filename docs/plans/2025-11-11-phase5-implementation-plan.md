# Phase 5: Athena & Apollo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement Athena (Goddess of Wisdom) and Apollo (God of Prophecy) with Wisdom resource, prophecy system, expanded research, new territories, and 10 achievements.

**Architecture:** Follows existing game architecture with Riverpod state management. Adds Wisdom as 6th resource, creates prophecy activation system with cooldown timers, extends research tree with Knowledge branch, and adds new Prophecy tab (8th tab). All new buildings follow existing building pattern with 1.15x cost scaling.

**Tech Stack:** Flutter 3.x, Dart, Riverpod, existing game state models

---

## Part 1: Core Models & Wisdom Resource (Tasks 1-8)

### Task 1: Add Wisdom Resource Type

**Files:**
- Modify: `lib/models/resource.dart`
- Test: `test/models/resource_test.dart`

**Step 1: Write the failing test**

```dart
// In test/models/resource_test.dart, add to existing tests:

test('Wisdom resource type exists', () {
  expect(ResourceType.wisdom, isNotNull);
});

test('Wisdom has correct display properties', () {
  expect(ResourceType.wisdom.displayName, 'Wisdom');
  expect(ResourceType.wisdom.description, 'Divine knowledge and insight');
  expect(ResourceType.wisdom.tier, 2);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/resource_test.dart`
Expected: FAIL with "The getter 'wisdom' isn't defined for the type 'ResourceType'"

**Step 3: Add Wisdom to ResourceType enum**

In `lib/models/resource.dart`, add to enum and getters:

```dart
enum ResourceType {
  cats,
  offerings,
  prayers,
  divineEssence,
  ambrosia,
  wisdom, // NEW
}

extension ResourceTypeExtension on ResourceType {
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
      case ResourceType.wisdom:
        return 'Wisdom';
    }
  }

  String get description {
    switch (this) {
      case ResourceType.cats:
        return 'Your primary currency';
      case ResourceType.offerings:
        return 'Basic offerings to the gods';
      case ResourceType.prayers:
        return 'Spiritual devotion';
      case ResourceType.divineEssence:
        return 'Refined spiritual energy';
      case ResourceType.ambrosia:
        return 'Food of the gods';
      case ResourceType.wisdom:
        return 'Divine knowledge and insight';
    }
  }

  int get tier {
    switch (this) {
      case ResourceType.cats:
      case ResourceType.offerings:
      case ResourceType.prayers:
        return 1;
      case ResourceType.divineEssence:
      case ResourceType.ambrosia:
      case ResourceType.wisdom:
        return 2;
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/resource_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/resource.dart test/models/resource_test.dart
git commit -m "feat: add Wisdom resource type"
```

---

### Task 2: Add Athena Buildings to Building Enum

**Files:**
- Modify: `lib/models/building.dart`
- Test: `test/models/building_test.dart`

**Step 1: Write the failing test**

```dart
// In test/models/building_test.dart, add:

group('Athena Buildings', () {
  test('Hall of Wisdom has correct properties', () {
    final building = BuildingType.hallOfWisdom;
    expect(building.displayName, 'Hall of Wisdom');
    expect(building.baseCost, 75000);
    expect(building.baseProduction, 0.1);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.athena);
  });

  test('Academy of Athens has correct properties', () {
    final building = BuildingType.academyOfAthens;
    expect(building.displayName, 'Academy of Athens');
    expect(building.baseCost, 500000);
    expect(building.baseProduction, 0.8);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.athena);
  });

  test('Strategy Chamber has correct properties', () {
    final building = BuildingType.strategyChamber;
    expect(building.displayName, 'Strategy Chamber');
    expect(building.baseCost, 3000000);
    expect(building.baseProduction, 5);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.athena);
  });

  test('Oracle\'s Archive has correct properties', () {
    final building = BuildingType.oraclesArchive;
    expect(building.displayName, 'Oracle\'s Archive');
    expect(building.baseCost, 15000000);
    expect(building.baseProduction, 25);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.athena);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/building_test.dart`
Expected: FAIL with "The getter 'hallOfWisdom' isn't defined"

**Step 3: Add Athena buildings to BuildingType enum**

In `lib/models/building.dart`, add to enum after existing buildings:

```dart
enum BuildingType {
  // ... existing buildings ...

  // Athena buildings
  hallOfWisdom,
  academyOfAthens,
  strategyChamber,
  oraclesArchive,
}

extension BuildingTypeExtension on BuildingType {
  String get displayName {
    switch (this) {
      // ... existing cases ...
      case BuildingType.hallOfWisdom:
        return 'Hall of Wisdom';
      case BuildingType.academyOfAthens:
        return 'Academy of Athens';
      case BuildingType.strategyChamber:
        return 'Strategy Chamber';
      case BuildingType.oraclesArchive:
        return 'Oracle\'s Archive';
    }
  }

  String get description {
    switch (this) {
      // ... existing cases ...
      case BuildingType.hallOfWisdom:
        return 'The foundational wisdom structure, a library of divine knowledge';
      case BuildingType.academyOfAthens:
        return 'Where mortals and minor deities study the arts and sciences';
      case BuildingType.strategyChamber:
        return 'War room where tactical planning generates strategic insights';
      case BuildingType.oraclesArchive:
        return 'Repository of prophecies and divine foresight';
    }
  }

  double get baseCost {
    switch (this) {
      // ... existing cases ...
      case BuildingType.hallOfWisdom:
        return 75000;
      case BuildingType.academyOfAthens:
        return 500000;
      case BuildingType.strategyChamber:
        return 3000000;
      case BuildingType.oraclesArchive:
        return 15000000;
    }
  }

  double get baseProduction {
    switch (this) {
      // ... existing cases ...
      case BuildingType.hallOfWisdom:
        return 0.1;
      case BuildingType.academyOfAthens:
        return 0.8;
      case BuildingType.strategyChamber:
        return 5.0;
      case BuildingType.oraclesArchive:
        return 25.0;
    }
  }

  ResourceType get producesResource {
    switch (this) {
      // ... existing cases ...
      case BuildingType.hallOfWisdom:
      case BuildingType.academyOfAthens:
      case BuildingType.strategyChamber:
      case BuildingType.oraclesArchive:
        return ResourceType.wisdom;
    }
  }

  God? get requiredGod {
    switch (this) {
      // ... existing cases ...
      case BuildingType.hallOfWisdom:
      case BuildingType.academyOfAthens:
      case BuildingType.strategyChamber:
      case BuildingType.oraclesArchive:
        return God.athena;
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/building_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/building.dart test/models/building_test.dart
git commit -m "feat: add Athena buildings (4 wisdom producers)"
```

---

### Task 3: Add Apollo Buildings to Building Enum

**Files:**
- Modify: `lib/models/building.dart`
- Test: `test/models/building_test.dart`

**Step 1: Write the failing test**

```dart
// In test/models/building_test.dart, add:

group('Apollo Buildings', () {
  test('Temple of Delphi has correct properties', () {
    final building = BuildingType.templeOfDelphi;
    expect(building.displayName, 'Temple of Delphi');
    expect(building.baseCost, 250000);
    expect(building.baseProduction, 2);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.apollo);
  });

  test('Sun Chariot Stable has correct properties', () {
    final building = BuildingType.sunChariotStable;
    expect(building.displayName, 'Sun Chariot Stable');
    expect(building.baseCost, 1500000);
    expect(building.baseProduction, 12);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.apollo);
  });

  test('Muses\' Sanctuary has correct properties', () {
    final building = BuildingType.musesSanctuary;
    expect(building.displayName, 'Muses\' Sanctuary');
    expect(building.baseCost, 8000000);
    expect(building.baseProduction, 60);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.apollo);
  });

  test('Celestial Observatory has correct properties', () {
    final building = BuildingType.celestialObservatory;
    expect(building.displayName, 'Celestial Observatory');
    expect(building.baseCost, 40000000);
    expect(building.baseProduction, 280);
    expect(building.producesResource, ResourceType.wisdom);
    expect(building.requiredGod, God.apollo);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/building_test.dart`
Expected: FAIL with "The getter 'templeOfDelphi' isn't defined"

**Step 3: Add Apollo buildings to BuildingType enum**

In `lib/models/building.dart`, add to enum after Athena buildings:

```dart
enum BuildingType {
  // ... existing buildings ...
  // ... Athena buildings ...

  // Apollo buildings
  templeOfDelphi,
  sunChariotStable,
  musesSanctuary,
  celestialObservatory,
}

// In extension, add cases:
String get displayName {
  switch (this) {
    // ... existing cases ...
    case BuildingType.templeOfDelphi:
      return 'Temple of Delphi';
    case BuildingType.sunChariotStable:
      return 'Sun Chariot Stable';
    case BuildingType.musesSanctuary:
      return 'Muses\' Sanctuary';
    case BuildingType.celestialObservatory:
      return 'Celestial Observatory';
  }
}

String get description {
  switch (this) {
    // ... existing cases ...
    case BuildingType.templeOfDelphi:
      return 'The sacred site of prophecy and oracles';
    case BuildingType.sunChariotStable:
      return 'Where Apollo\'s golden chariot rests, radiating enlightenment';
    case BuildingType.musesSanctuary:
      return 'Home to the nine muses who inspire wisdom and creativity';
    case BuildingType.celestialObservatory:
      return 'Tracks celestial movements to predict divine patterns';
  }
}

double get baseCost {
  switch (this) {
    // ... existing cases ...
    case BuildingType.templeOfDelphi:
      return 250000;
    case BuildingType.sunChariotStable:
      return 1500000;
    case BuildingType.musesSanctuary:
      return 8000000;
    case BuildingType.celestialObservatory:
      return 40000000;
  }
}

double get baseProduction {
  switch (this) {
    // ... existing cases ...
    case BuildingType.templeOfDelphi:
      return 2.0;
    case BuildingType.sunChariotStable:
      return 12.0;
    case BuildingType.musesSanctuary:
      return 60.0;
    case BuildingType.celestialObservatory:
      return 280.0;
  }
}

ResourceType get producesResource {
  switch (this) {
    // ... existing cases ...
    case BuildingType.templeOfDelphi:
    case BuildingType.sunChariotStable:
    case BuildingType.musesSanctuary:
    case BuildingType.celestialObservatory:
      return ResourceType.wisdom;
  }
}

God? get requiredGod {
  switch (this) {
    // ... existing cases ...
    case BuildingType.templeOfDelphi:
    case BuildingType.sunChariotStable:
    case BuildingType.musesSanctuary:
    case BuildingType.celestialObservatory:
      return God.apollo;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/building_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/building.dart test/models/building_test.dart
git commit -m "feat: add Apollo buildings (4 advanced wisdom producers)"
```

---

### Task 4: Add Wisdom to GameState

**Files:**
- Modify: `lib/providers/game_state.dart`
- Test: `test/providers/game_state_test.dart`

**Step 1: Write the failing test**

```dart
// In test/providers/game_state_test.dart, add:

test('GameState initializes with 0 Wisdom', () {
  final state = GameState.initial();
  expect(state.resources[ResourceType.wisdom], 0);
});

test('GameState can add Wisdom', () {
  final state = GameState.initial();
  final updated = state.addResource(ResourceType.wisdom, 100);
  expect(updated.resources[ResourceType.wisdom], 100);
});

test('GameState calculates Wisdom production rate', () {
  final state = GameState.initial()
      .copyWith(buildings: {
        BuildingType.hallOfWisdom: 10, // 10 * 0.1 = 1.0 Wisdom/sec
        BuildingType.academyOfAthens: 5, // 5 * 0.8 = 4.0 Wisdom/sec
      });

  expect(state.getProductionRate(ResourceType.wisdom), 5.0);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_state_test.dart`
Expected: FAIL (Wisdom not initialized in resources map)

**Step 3: Update GameState to include Wisdom**

In `lib/providers/game_state.dart`:

```dart
class GameState {
  final Map<ResourceType, double> resources;
  // ... other fields ...

  GameState({
    required this.resources,
    // ... other parameters ...
  });

  factory GameState.initial() {
    return GameState(
      resources: {
        ResourceType.cats: 0,
        ResourceType.offerings: 0,
        ResourceType.prayers: 0,
        ResourceType.divineEssence: 0,
        ResourceType.ambrosia: 0,
        ResourceType.wisdom: 0, // NEW
      },
      // ... other initial values ...
    );
  }

  // getProductionRate should already handle all ResourceTypes via loop
  // No changes needed if it iterates over all buildings
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_state_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/game_state.dart test/providers/game_state_test.dart
git commit -m "feat: add Wisdom resource to GameState"
```

---

### Task 5: Update Game Loop to Generate Wisdom

**Files:**
- Modify: `lib/providers/game_state.dart` (tick method)
- Test: `test/providers/game_state_test.dart`

**Step 1: Write the failing test**

```dart
// In test/providers/game_state_test.dart, add:

test('Game loop generates Wisdom from buildings', () {
  final state = GameState.initial().copyWith(
    buildings: {
      BuildingType.hallOfWisdom: 1, // 0.1 Wisdom/sec
    },
  );

  final updated = state.tick(Duration(seconds: 10)); // 10 seconds
  expect(updated.resources[ResourceType.wisdom], 1.0); // 0.1 * 10 = 1.0
});

test('Wisdom accumulates over multiple ticks', () {
  var state = GameState.initial().copyWith(
    buildings: {
      BuildingType.academyOfAthens: 1, // 0.8 Wisdom/sec
    },
  );

  state = state.tick(Duration(seconds: 5)); // +4.0 Wisdom
  expect(state.resources[ResourceType.wisdom], 4.0);

  state = state.tick(Duration(seconds: 5)); // +4.0 Wisdom
  expect(state.resources[ResourceType.wisdom], 8.0);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_state_test.dart`
Expected: FAIL (Wisdom not generated in tick method)

**Step 3: Verify tick method handles all resources**

In `lib/providers/game_state.dart`, the `tick` method should already iterate over all buildings and resources. Verify it looks like:

```dart
GameState tick(Duration elapsed) {
  final seconds = elapsed.inMilliseconds / 1000.0;
  final updatedResources = Map<ResourceType, double>.from(resources);

  // Generate resources from buildings
  buildings.forEach((buildingType, count) {
    if (count > 0) {
      final resourceType = buildingType.producesResource;
      final productionRate = buildingType.baseProduction * count;
      final produced = productionRate * seconds;
      updatedResources[resourceType] =
          (updatedResources[resourceType] ?? 0) + produced;
    }
  });

  return copyWith(resources: updatedResources);
}
```

If this generic implementation exists, it should automatically handle Wisdom. If not, add it.

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_state_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/game_state.dart test/providers/game_state_test.dart
git commit -m "feat: wisdom generation in game loop"
```

---

## Part 2: Prophecy System (Tasks 6-12)

### Task 6: Create Prophecy Model

**Files:**
- Create: `lib/models/prophecy.dart`
- Create: `test/models/prophecy_test.dart`

**Step 1: Write the failing test**

```dart
// In test/models/prophecy_test.dart:

import 'package:flutter_test/flutter_test.dart';
import 'package:idleidle/models/prophecy.dart';
import 'package:idleidle/models/resource.dart';

void main() {
  group('ProphecyType', () {
    test('Vision of Prosperity has correct properties', () {
      final prophecy = ProphecyType.visionOfProsperity;
      expect(prophecy.displayName, 'Vision of Prosperity');
      expect(prophecy.wisdomCost, 50);
      expect(prophecy.cooldownMinutes, 30);
      expect(prophecy.tier, 1);
      expect(prophecy.effectType, ProphecyEffectType.informational);
    });

    test('Solar Blessing has correct properties', () {
      final prophecy = ProphecyType.solarBlessing;
      expect(prophecy.displayName, 'Solar Blessing');
      expect(prophecy.wisdomCost, 100);
      expect(prophecy.cooldownMinutes, 60);
      expect(prophecy.tier, 1);
      expect(prophecy.effectType, ProphecyEffectType.timedBoost);
      expect(prophecy.durationMinutes, 15);
      expect(prophecy.productionMultiplier, 1.5); // +50%
    });
  });

  group('ProphecyState', () {
    test('Prophecy starts in ready state', () {
      final state = ProphecyState.initial();
      expect(state.isOnCooldown(ProphecyType.visionOfProsperity), false);
    });

    test('Activating prophecy starts cooldown', () {
      final now = DateTime.now();
      final state = ProphecyState.initial().activate(
        ProphecyType.visionOfProsperity,
        now,
      );

      expect(state.isOnCooldown(ProphecyType.visionOfProsperity), true);
      expect(state.getCooldownRemaining(ProphecyType.visionOfProsperity, now),
          Duration(minutes: 30));
    });

    test('Cooldown expires after duration', () {
      final now = DateTime.now();
      var state = ProphecyState.initial().activate(
        ProphecyType.visionOfProsperity,
        now,
      );

      expect(state.isOnCooldown(ProphecyType.visionOfProsperity), true);

      final later = now.add(Duration(minutes: 31));
      expect(state.isOnCooldown(ProphecyType.visionOfProsperity, later), false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/prophecy_test.dart`
Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Create Prophecy model**

Create `lib/models/prophecy.dart`:

```dart
/// Prophecy effect types
enum ProphecyEffectType {
  informational,
  timedBoost,
  instantBenefit,
  hybrid,
}

/// The 10 prophecies
enum ProphecyType {
  // Tier 1
  visionOfProsperity,
  solarBlessing,
  glimpseOfResearch,

  // Tier 2
  prophecyOfAbundance,
  divineCalculation,
  musesInspiration,

  // Tier 3
  oraclesRevelation,
  celestialSurge,
  prophecyOfFortune,
  apollosGrandVision,
}

extension ProphecyTypeExtension on ProphecyType {
  String get displayName {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 'Vision of Prosperity';
      case ProphecyType.solarBlessing:
        return 'Solar Blessing';
      case ProphecyType.glimpseOfResearch:
        return 'Glimpse of Research';
      case ProphecyType.prophecyOfAbundance:
        return 'Prophecy of Abundance';
      case ProphecyType.divineCalculation:
        return 'Divine Calculation';
      case ProphecyType.musesInspiration:
        return 'Muse\'s Inspiration';
      case ProphecyType.oraclesRevelation:
        return 'Oracle\'s Revelation';
      case ProphecyType.celestialSurge:
        return 'Celestial Surge';
      case ProphecyType.prophecyOfFortune:
        return 'Prophecy of Fortune';
      case ProphecyType.apollosGrandVision:
        return 'Apollo\'s Grand Vision';
    }
  }

  String get description {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 'Shows next 3 building unlock thresholds and their production rates';
      case ProphecyType.solarBlessing:
        return '+50% cat production for 15 minutes';
      case ProphecyType.glimpseOfResearch:
        return 'Reveals all available research nodes and their prerequisites';
      case ProphecyType.prophecyOfAbundance:
        return '+100% all resource production for 30 minutes';
      case ProphecyType.divineCalculation:
        return 'Shows exact time to reach next god unlock at current production rate';
      case ProphecyType.musesInspiration:
        return 'Next 5 buildings purchased cost 20% less';
      case ProphecyType.oraclesRevelation:
        return 'Reveals optimal building purchase order for next 10 minutes of progression';
      case ProphecyType.celestialSurge:
        return '+200% cat production for 45 minutes';
      case ProphecyType.prophecyOfFortune:
        return 'Gain instant cats equal to 30 minutes of current production';
      case ProphecyType.apollosGrandVision:
        return 'Shows complete path to next reincarnation threshold + grants +150% all production for 1 hour';
    }
  }

  double get wisdomCost {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 50;
      case ProphecyType.solarBlessing:
        return 100;
      case ProphecyType.glimpseOfResearch:
        return 75;
      case ProphecyType.prophecyOfAbundance:
        return 250;
      case ProphecyType.divineCalculation:
        return 200;
      case ProphecyType.musesInspiration:
        return 300;
      case ProphecyType.oraclesRevelation:
        return 500;
      case ProphecyType.celestialSurge:
        return 750;
      case ProphecyType.prophecyOfFortune:
        return 1000;
      case ProphecyType.apollosGrandVision:
        return 2000;
    }
  }

  int get cooldownMinutes {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 30;
      case ProphecyType.solarBlessing:
        return 60;
      case ProphecyType.glimpseOfResearch:
        return 45;
      case ProphecyType.prophecyOfAbundance:
        return 90;
      case ProphecyType.divineCalculation:
        return 60;
      case ProphecyType.musesInspiration:
        return 120;
      case ProphecyType.oraclesRevelation:
        return 150;
      case ProphecyType.celestialSurge:
        return 180;
      case ProphecyType.prophecyOfFortune:
        return 210;
      case ProphecyType.apollosGrandVision:
        return 240;
    }
  }

  int get tier {
    switch (this) {
      case ProphecyType.visionOfProsperity:
      case ProphecyType.solarBlessing:
      case ProphecyType.glimpseOfResearch:
        return 1;
      case ProphecyType.prophecyOfAbundance:
      case ProphecyType.divineCalculation:
      case ProphecyType.musesInspiration:
        return 2;
      case ProphecyType.oraclesRevelation:
      case ProphecyType.celestialSurge:
      case ProphecyType.prophecyOfFortune:
      case ProphecyType.apollosGrandVision:
        return 3;
    }
  }

  ProphecyEffectType get effectType {
    switch (this) {
      case ProphecyType.visionOfProsperity:
      case ProphecyType.glimpseOfResearch:
      case ProphecyType.divineCalculation:
      case ProphecyType.oraclesRevelation:
        return ProphecyEffectType.informational;
      case ProphecyType.solarBlessing:
      case ProphecyType.prophecyOfAbundance:
      case ProphecyType.celestialSurge:
        return ProphecyEffectType.timedBoost;
      case ProphecyType.prophecyOfFortune:
        return ProphecyEffectType.instantBenefit;
      case ProphecyType.musesInspiration:
      case ProphecyType.apollosGrandVision:
        return ProphecyEffectType.hybrid;
    }
  }

  int? get durationMinutes {
    switch (this) {
      case ProphecyType.solarBlessing:
        return 15;
      case ProphecyType.prophecyOfAbundance:
        return 30;
      case ProphecyType.celestialSurge:
        return 45;
      case ProphecyType.musesInspiration:
        return 60; // or 5 purchases
      case ProphecyType.apollosGrandVision:
        return 60;
      default:
        return null; // No duration for informational/instant
    }
  }

  double? get productionMultiplier {
    switch (this) {
      case ProphecyType.solarBlessing:
        return 1.5; // +50%
      case ProphecyType.prophecyOfAbundance:
        return 2.0; // +100%
      case ProphecyType.celestialSurge:
        return 3.0; // +200%
      case ProphecyType.apollosGrandVision:
        return 2.5; // +150%
      default:
        return null;
    }
  }
}

/// Prophecy activation state
class ProphecyState {
  final Map<ProphecyType, DateTime> cooldowns;
  final ProphecyType? activeTimedBoost;
  final DateTime? activeTimedBoostExpiry;

  const ProphecyState({
    required this.cooldowns,
    this.activeTimedBoost,
    this.activeTimedBoostExpiry,
  });

  factory ProphecyState.initial() {
    return const ProphecyState(cooldowns: {});
  }

  bool isOnCooldown(ProphecyType prophecy, [DateTime? now]) {
    final checkTime = now ?? DateTime.now();
    final cooldownEnd = cooldowns[prophecy];
    if (cooldownEnd == null) return false;
    return checkTime.isBefore(cooldownEnd);
  }

  Duration getCooldownRemaining(ProphecyType prophecy, [DateTime? now]) {
    final checkTime = now ?? DateTime.now();
    final cooldownEnd = cooldowns[prophecy];
    if (cooldownEnd == null) return Duration.zero;
    final remaining = cooldownEnd.difference(checkTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  ProphecyState activate(ProphecyType prophecy, DateTime now) {
    final cooldownEnd = now.add(Duration(minutes: prophecy.cooldownMinutes));
    final updatedCooldowns = Map<ProphecyType, DateTime>.from(cooldowns);
    updatedCooldowns[prophecy] = cooldownEnd;

    // If it's a timed boost, set as active
    if (prophecy.effectType == ProphecyEffectType.timedBoost ||
        prophecy.effectType == ProphecyEffectType.hybrid) {
      final duration = prophecy.durationMinutes;
      if (duration != null) {
        return ProphecyState(
          cooldowns: updatedCooldowns,
          activeTimedBoost: prophecy,
          activeTimedBoostExpiry: now.add(Duration(minutes: duration)),
        );
      }
    }

    return ProphecyState(
      cooldowns: updatedCooldowns,
      activeTimedBoost: activeTimedBoost,
      activeTimedBoostExpiry: activeTimedBoostExpiry,
    );
  }

  ProphecyState copyWith({
    Map<ProphecyType, DateTime>? cooldowns,
    ProphecyType? activeTimedBoost,
    DateTime? activeTimedBoostExpiry,
  }) {
    return ProphecyState(
      cooldowns: cooldowns ?? this.cooldowns,
      activeTimedBoost: activeTimedBoost ?? this.activeTimedBoost,
      activeTimedBoostExpiry: activeTimedBoostExpiry ?? this.activeTimedBoostExpiry,
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/prophecy_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/prophecy.dart test/models/prophecy_test.dart
git commit -m "feat: create prophecy model with 10 prophecies"
```

---

### Task 7: Add Prophecy State to GameState

**Files:**
- Modify: `lib/providers/game_state.dart`
- Test: `test/providers/game_state_test.dart`

**Step 1: Write the failing test**

```dart
// In test/providers/game_state_test.dart, add:

import 'package:idleidle/models/prophecy.dart';

test('GameState initializes with empty prophecy state', () {
  final state = GameState.initial();
  expect(state.prophecyState, isNotNull);
  expect(state.prophecyState.cooldowns, isEmpty);
});

test('GameState can activate prophecy', () {
  final state = GameState.initial().copyWith(
    resources: {ResourceType.wisdom: 100},
  );

  final now = DateTime.now();
  final updated = state.activateProphecy(ProphecyType.solarBlessing, now);

  expect(updated.resources[ResourceType.wisdom], 0); // 100 - 100 = 0
  expect(updated.prophecyState.isOnCooldown(ProphecyType.solarBlessing), true);
});

test('Cannot activate prophecy with insufficient Wisdom', () {
  final state = GameState.initial().copyWith(
    resources: {ResourceType.wisdom: 50},
  );

  expect(
    () => state.activateProphecy(ProphecyType.solarBlessing, DateTime.now()),
    throwsA(isA<InsufficientResourcesException>()),
  );
});

test('Cannot activate prophecy on cooldown', () {
  final now = DateTime.now();
  final state = GameState.initial()
      .copyWith(resources: {ResourceType.wisdom: 200})
      .activateProphecy(ProphecyType.solarBlessing, now);

  expect(
    () => state.activateProphecy(ProphecyType.solarBlessing, now),
    throwsA(isA<ProphecyOnCooldownException>()),
  );
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_state_test.dart`
Expected: FAIL with "The getter 'prophecyState' isn't defined"

**Step 3: Add prophecy state to GameState**

In `lib/providers/game_state.dart`:

```dart
import 'package:idleidle/models/prophecy.dart';

class GameState {
  final Map<ResourceType, double> resources;
  final ProphecyState prophecyState;
  // ... other fields ...

  GameState({
    required this.resources,
    required this.prophecyState,
    // ... other parameters ...
  });

  factory GameState.initial() {
    return GameState(
      resources: {
        ResourceType.cats: 0,
        ResourceType.offerings: 0,
        ResourceType.prayers: 0,
        ResourceType.divineEssence: 0,
        ResourceType.ambrosia: 0,
        ResourceType.wisdom: 0,
      },
      prophecyState: ProphecyState.initial(),
      // ... other initial values ...
    );
  }

  GameState activateProphecy(ProphecyType prophecy, DateTime now) {
    // Check if on cooldown
    if (prophecyState.isOnCooldown(prophecy, now)) {
      throw ProphecyOnCooldownException(prophecy);
    }

    // Check if have enough Wisdom
    final cost = prophecy.wisdomCost;
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
    );
  }

  GameState copyWith({
    Map<ResourceType, double>? resources,
    ProphecyState? prophecyState,
    // ... other parameters ...
  }) {
    return GameState(
      resources: resources ?? this.resources,
      prophecyState: prophecyState ?? this.prophecyState,
      // ... other fields ...
    );
  }
}

class ProphecyOnCooldownException implements Exception {
  final ProphecyType prophecy;
  ProphecyOnCooldownException(this.prophecy);

  @override
  String toString() => 'Prophecy ${prophecy.displayName} is on cooldown';
}

class InsufficientResourcesException implements Exception {
  final ResourceType resource;
  final double required;
  final double current;

  InsufficientResourcesException(this.resource, this.required, this.current);

  @override
  String toString() => 'Insufficient ${resource.displayName}: need $required, have $current';
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_state_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/game_state.dart test/providers/game_state_test.dart
git commit -m "feat: add prophecy activation to GameState"
```

---

### Task 8: Implement Timed Boost Application

**Files:**
- Modify: `lib/providers/game_state.dart`
- Test: `test/providers/game_state_test.dart`

**Step 1: Write the failing test**

```dart
// In test/providers/game_state_test.dart, add:

test('Solar Blessing applies +50% cat production', () {
  final now = DateTime.now();
  var state = GameState.initial().copyWith(
    resources: {ResourceType.wisdom: 100},
    buildings: {BuildingType.smallShrine: 10}, // Base: 10 * 0.1 = 1.0 cats/sec
  );

  // Activate Solar Blessing
  state = state.activateProphecy(ProphecyType.solarBlessing, now);

  // Check production rate with boost
  final boostedRate = state.getProductionRate(ResourceType.cats);
  expect(boostedRate, 1.5); // 1.0 * 1.5 = 1.5

  // After boost expires (15 min + 1 sec)
  final expired = now.add(Duration(minutes: 15, seconds: 1));
  state = state.updateProphecyEffects(expired);

  final normalRate = state.getProductionRate(ResourceType.cats);
  expect(normalRate, 1.0); // Back to normal
});

test('Prophecy of Abundance applies +100% to all resources', () {
  final now = DateTime.now();
  var state = GameState.initial().copyWith(
    resources: {ResourceType.wisdom: 250},
    buildings: {
      BuildingType.smallShrine: 10, // 1.0 cats/sec
      BuildingType.hallOfWisdom: 10, // 1.0 wisdom/sec
    },
  );

  state = state.activateProphecy(ProphecyType.prophecyOfAbundance, now);

  expect(state.getProductionRate(ResourceType.cats), 2.0); // 1.0 * 2.0
  expect(state.getProductionRate(ResourceType.wisdom), 2.0); // 1.0 * 2.0
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_state_test.dart`
Expected: FAIL with "The method 'updateProphecyEffects' isn't defined"

**Step 3: Implement boost application**

In `lib/providers/game_state.dart`:

```dart
double getProductionRate(ResourceType resource) {
  double baseRate = 0.0;

  // Calculate base production from buildings
  buildings.forEach((buildingType, count) {
    if (buildingType.producesResource == resource) {
      baseRate += buildingType.baseProduction * count;
    }
  });

  // Apply prophecy boost if active
  final now = DateTime.now();
  if (prophecyState.activeTimedBoost != null &&
      prophecyState.activeTimedBoostExpiry != null &&
      now.isBefore(prophecyState.activeTimedBoostExpiry!)) {
    final prophecy = prophecyState.activeTimedBoost!;
    final multiplier = prophecy.productionMultiplier;

    if (multiplier != null) {
      // Some prophecies boost all resources, others boost specific ones
      if (prophecy == ProphecyType.solarBlessing && resource == ResourceType.cats) {
        baseRate *= multiplier;
      } else if (prophecy == ProphecyType.prophecyOfAbundance) {
        baseRate *= multiplier; // Boosts all resources
      } else if (prophecy == ProphecyType.celestialSurge && resource == ResourceType.cats) {
        baseRate *= multiplier;
      } else if (prophecy == ProphecyType.apollosGrandVision) {
        baseRate *= multiplier; // Boosts all resources
      }
    }
  }

  return baseRate;
}

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

GameState tick(Duration elapsed) {
  final now = DateTime.now();

  // Update prophecy effects (expire if needed)
  var state = updateProphecyEffects(now);

  final seconds = elapsed.inMilliseconds / 1000.0;
  final updatedResources = Map<ResourceType, double>.from(state.resources);

  // Generate resources from buildings (using boosted rates)
  for (final resourceType in ResourceType.values) {
    final productionRate = state.getProductionRate(resourceType);
    final produced = productionRate * seconds;
    updatedResources[resourceType] =
        (updatedResources[resourceType] ?? 0) + produced;
  }

  return state.copyWith(resources: updatedResources);
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_state_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/game_state.dart test/providers/game_state_test.dart
git commit -m "feat: apply prophecy timed boosts to production"
```

---

## Part 3: Research System (Tasks 9-11)

### Task 9: Add Knowledge Branch Research Nodes

**Files:**
- Modify: `lib/models/research.dart`
- Test: `test/models/research_test.dart`

**Step 1: Write the failing test**

```dart
// In test/models/research_test.dart, add:

group('Knowledge Branch', () {
  test('Foundations of Wisdom has correct properties', () {
    final node = ResearchNode.foundationsOfWisdom;
    expect(node.displayName, 'Foundations of Wisdom');
    expect(node.costs[ResourceType.cats], 10000);
    expect(node.costs[ResourceType.offerings], 100);
    expect(node.prerequisites, isEmpty);
    expect(node.branch, ResearchBranch.knowledge);
  });

  test('Scholarly Pursuit I has correct properties', () {
    final node = ResearchNode.scholarlyPursuitI;
    expect(node.displayName, 'Scholarly Pursuit I');
    expect(node.costs[ResourceType.cats], 50000);
    expect(node.costs[ResourceType.offerings], 500);
    expect(node.costs[ResourceType.wisdom], 50);
    expect(node.prerequisites, contains(ResearchNode.foundationsOfWisdom));
    expect(node.effectDescription, '+10% Wisdom production');
  });

  test('Divine Insight requires Scholarly Pursuit II', () {
    final node = ResearchNode.divineInsight;
    expect(node.prerequisites, contains(ResearchNode.scholarlyPursuitII));
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/research_test.dart`
Expected: FAIL with "The getter 'foundationsOfWisdom' isn't defined"

**Step 3: Add Knowledge branch to research enum**

In `lib/models/research.dart`:

```dart
enum ResearchBranch {
  foundation,
  resource,
  automation,
  godFavor,
  knowledge, // NEW
}

enum ResearchNode {
  // ... existing nodes ...

  // Knowledge branch (Phase 5)
  foundationsOfWisdom,
  scholarlyPursuitI,
  scholarlyPursuitII,
  scholarlyPursuitIII,
  divineInsight,
  philosophicalMethod,
  propheticConnection,

  // Extensions to existing branches (Phase 5)
  wisdomAutomation,
  athenasBlessing,
  essenceToWisdomConversion,
}

extension ResearchNodeExtension on ResearchNode {
  String get displayName {
    switch (this) {
      // ... existing cases ...
      case ResearchNode.foundationsOfWisdom:
        return 'Foundations of Wisdom';
      case ResearchNode.scholarlyPursuitI:
        return 'Scholarly Pursuit I';
      case ResearchNode.scholarlyPursuitII:
        return 'Scholarly Pursuit II';
      case ResearchNode.scholarlyPursuitIII:
        return 'Scholarly Pursuit III';
      case ResearchNode.divineInsight:
        return 'Divine Insight';
      case ResearchNode.philosophicalMethod:
        return 'Philosophical Method';
      case ResearchNode.propheticConnection:
        return 'Prophetic Connection';
      case ResearchNode.wisdomAutomation:
        return 'Wisdom Automation';
      case ResearchNode.athenasBlessing:
        return 'Athena\'s Blessing';
      case ResearchNode.essenceToWisdomConversion:
        return 'Essence to Wisdom Conversion';
    }
  }

  String get description {
    switch (this) {
      // ... existing cases ...
      case ResearchNode.foundationsOfWisdom:
        return 'Begin your journey into divine knowledge';
      case ResearchNode.scholarlyPursuitI:
        return 'Enhance your pursuit of wisdom';
      case ResearchNode.scholarlyPursuitII:
        return 'Deepen your intellectual commitment';
      case ResearchNode.scholarlyPursuitIII:
        return 'Master the art of knowledge accumulation';
      case ResearchNode.divineInsight:
        return 'Channel Athena\'s divine intellect';
      case ResearchNode.philosophicalMethod:
        return 'Wisdom flows from enlightened deeds';
      case ResearchNode.propheticConnection:
        return 'Bridge mortal wisdom to divine foresight';
      case ResearchNode.wisdomAutomation:
        return 'Athena and Apollo buildings gain +50% offline efficiency';
      case ResearchNode.athenasBlessing:
        return '+10% cat production when Wisdom > 1000';
      case ResearchNode.essenceToWisdomConversion:
        return 'Unlock Workshop converter: 100 Divine Essence → 10 Wisdom';
    }
  }

  String? get effectDescription {
    switch (this) {
      case ResearchNode.scholarlyPursuitI:
        return '+10% Wisdom production';
      case ResearchNode.scholarlyPursuitII:
        return '+15% Wisdom production';
      case ResearchNode.scholarlyPursuitIII:
        return '+20% Wisdom production';
      case ResearchNode.divineInsight:
        return 'Athena buildings +25% Wisdom';
      case ResearchNode.philosophicalMethod:
        return 'Unlock passive Wisdom from achievements';
      case ResearchNode.propheticConnection:
        return 'Prophecy costs -15%';
      case ResearchNode.wisdomAutomation:
        return 'Wisdom buildings +50% offline';
      case ResearchNode.athenasBlessing:
        return '+10% cats when Wisdom > 1000';
      case ResearchNode.essenceToWisdomConversion:
        return 'Unlock Workshop converter';
      default:
        return null;
    }
  }

  Map<ResourceType, double> get costs {
    switch (this) {
      // ... existing cases ...
      case ResearchNode.foundationsOfWisdom:
        return {
          ResourceType.cats: 10000,
          ResourceType.offerings: 100,
        };
      case ResearchNode.scholarlyPursuitI:
        return {
          ResourceType.cats: 50000,
          ResourceType.offerings: 500,
          ResourceType.wisdom: 50,
        };
      case ResearchNode.scholarlyPursuitII:
        return {
          ResourceType.cats: 250000,
          ResourceType.offerings: 2000,
          ResourceType.wisdom: 200,
        };
      case ResearchNode.scholarlyPursuitIII:
        return {
          ResourceType.cats: 1000000,
          ResourceType.divineEssence: 5000,
          ResourceType.wisdom: 500,
        };
      case ResearchNode.divineInsight:
        return {
          ResourceType.cats: 500000,
          ResourceType.divineEssence: 1000,
          ResourceType.wisdom: 50,
        };
      case ResearchNode.philosophicalMethod:
        return {
          ResourceType.cats: 2000000,
          ResourceType.divineEssence: 5000,
          ResourceType.wisdom: 200,
        };
      case ResearchNode.propheticConnection:
        return {
          ResourceType.cats: 8000000,
          ResourceType.divineEssence: 20000,
          ResourceType.wisdom: 1000,
        };
      case ResearchNode.wisdomAutomation:
        return {
          ResourceType.cats: 3000000,
          ResourceType.divineEssence: 10000,
          ResourceType.wisdom: 300,
        };
      case ResearchNode.athenasBlessing:
        return {
          ResourceType.cats: 2500000,
          ResourceType.divineEssence: 8000,
          ResourceType.wisdom: 250,
        };
      case ResearchNode.essenceToWisdomConversion:
        return {
          ResourceType.cats: 5000000,
          ResourceType.divineEssence: 15000,
          ResourceType.wisdom: 500,
        };
    }
  }

  List<ResearchNode> get prerequisites {
    switch (this) {
      case ResearchNode.foundationsOfWisdom:
        return [];
      case ResearchNode.scholarlyPursuitI:
        return [ResearchNode.foundationsOfWisdom];
      case ResearchNode.scholarlyPursuitII:
        return [ResearchNode.scholarlyPursuitI];
      case ResearchNode.scholarlyPursuitIII:
        return [ResearchNode.scholarlyPursuitII];
      case ResearchNode.divineInsight:
        return [ResearchNode.scholarlyPursuitII];
      case ResearchNode.philosophicalMethod:
        return [ResearchNode.divineInsight];
      case ResearchNode.propheticConnection:
        return [ResearchNode.philosophicalMethod];
      case ResearchNode.wisdomAutomation:
        return [ResearchNode.divineOversight]; // existing automation node
      case ResearchNode.athenasBlessing:
        return [ResearchNode.divineBlessings]; // existing god favor node
      case ResearchNode.essenceToWisdomConversion:
        return [ResearchNode.divineAlchemy]; // existing resource node
      default:
        return [];
    }
  }

  ResearchBranch get branch {
    switch (this) {
      case ResearchNode.foundationsOfWisdom:
      case ResearchNode.scholarlyPursuitI:
      case ResearchNode.scholarlyPursuitII:
      case ResearchNode.scholarlyPursuitIII:
      case ResearchNode.divineInsight:
      case ResearchNode.philosophicalMethod:
      case ResearchNode.propheticConnection:
        return ResearchBranch.knowledge;
      case ResearchNode.wisdomAutomation:
        return ResearchBranch.automation;
      case ResearchNode.athenasBlessing:
        return ResearchBranch.godFavor;
      case ResearchNode.essenceToWisdomConversion:
        return ResearchBranch.resource;
      default:
        // ... existing branches ...
        return ResearchBranch.foundation;
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/research_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/models/research.dart test/models/research_test.dart
git commit -m "feat: add Knowledge research branch (7 nodes + 3 extensions)"
```

---

### Task 10: Apply Research Bonuses to Wisdom Production

**Files:**
- Modify: `lib/providers/game_state.dart`
- Test: `test/providers/game_state_test.dart`

**Step 1: Write the failing test**

```dart
// In test/providers/game_state_test.dart, add:

test('Scholarly Pursuit I adds +10% Wisdom production', () {
  final state = GameState.initial().copyWith(
    buildings: {BuildingType.hallOfWisdom: 10}, // Base: 1.0 Wisdom/sec
    completedResearch: {ResearchNode.scholarlyPursuitI},
  );

  expect(state.getProductionRate(ResourceType.wisdom), 1.1); // 1.0 * 1.1
});

test('Scholarly Pursuit bonuses stack', () {
  final state = GameState.initial().copyWith(
    buildings: {BuildingType.hallOfWisdom: 10}, // Base: 1.0 Wisdom/sec
    completedResearch: {
      ResearchNode.scholarlyPursuitI, // +10%
      ResearchNode.scholarlyPursuitII, // +15%
      ResearchNode.scholarlyPursuitIII, // +20%
    },
  );

  // 1.0 * 1.10 * 1.15 * 1.20 = 1.518
  expect(state.getProductionRate(ResourceType.wisdom), closeTo(1.518, 0.001));
});

test('Divine Insight adds +25% to Athena buildings only', () {
  final state = GameState.initial().copyWith(
    buildings: {
      BuildingType.hallOfWisdom: 10, // 1.0 Wisdom/sec (Athena)
      BuildingType.templeOfDelphi: 1, // 2.0 Wisdom/sec (Apollo)
    },
    completedResearch: {ResearchNode.divineInsight},
  );

  // Athena: 1.0 * 1.25 = 1.25
  // Apollo: 2.0 * 1.0 = 2.0
  // Total: 3.25
  expect(state.getProductionRate(ResourceType.wisdom), 3.25);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_state_test.dart`
Expected: FAIL (bonuses not applied)

**Step 3: Update getProductionRate to apply research bonuses**

In `lib/providers/game_state.dart`:

```dart
double getProductionRate(ResourceType resource) {
  double baseRate = 0.0;

  // Calculate base production from buildings
  buildings.forEach((buildingType, count) {
    if (buildingType.producesResource == resource) {
      double buildingProduction = buildingType.baseProduction * count;

      // Apply building-specific research bonuses (for Wisdom only)
      if (resource == ResourceType.wisdom) {
        // Divine Insight: +25% for Athena buildings
        if (completedResearch.contains(ResearchNode.divineInsight)) {
          if (buildingType == BuildingType.hallOfWisdom ||
              buildingType == BuildingType.academyOfAthens ||
              buildingType == BuildingType.strategyChamber ||
              buildingType == BuildingType.oraclesArchive) {
            buildingProduction *= 1.25;
          }
        }
      }

      baseRate += buildingProduction;
    }
  });

  // Apply global resource bonuses
  if (resource == ResourceType.wisdom) {
    // Scholarly Pursuit bonuses stack multiplicatively
    if (completedResearch.contains(ResearchNode.scholarlyPursuitI)) {
      baseRate *= 1.10;
    }
    if (completedResearch.contains(ResearchNode.scholarlyPursuitII)) {
      baseRate *= 1.15;
    }
    if (completedResearch.contains(ResearchNode.scholarlyPursuitIII)) {
      baseRate *= 1.20;
    }
  }

  // Apply prophecy boost if active
  // ... existing prophecy boost code ...

  return baseRate;
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_state_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/providers/game_state.dart test/providers/game_state_test.dart
git commit -m "feat: apply Knowledge research bonuses to Wisdom production"
```

---

## Part 4: UI Components (Tasks 11-15)

### Task 11: Create ProphecyCard Widget

**Files:**
- Create: `lib/widgets/prophecy_card.dart`
- Create: `test/widgets/prophecy_card_test.dart`

**Step 1: Write the failing test**

```dart
// In test/widgets/prophecy_card_test.dart:

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idleidle/models/prophecy.dart';
import 'package:idleidle/widgets/prophecy_card.dart';

void main() {
  testWidgets('ProphecyCard displays prophecy info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 100,
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            onActivate: () {},
          ),
        ),
      ),
    );

    expect(find.text('Solar Blessing'), findsOneWidget);
    expect(find.text('+50% cat production for 15 minutes'), findsOneWidget);
    expect(find.text('100'), findsOneWidget); // Wisdom cost
    expect(find.text('Activate'), findsOneWidget);
  });

  testWidgets('ProphecyCard shows cooldown state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 100,
            isOnCooldown: true,
            cooldownRemaining: Duration(minutes: 45, seconds: 23),
            onActivate: () {},
          ),
        ),
      ),
    );

    expect(find.text('45:23'), findsOneWidget);
    expect(find.text('Activate'), findsNothing); // Button disabled/hidden
  });

  testWidgets('ProphecyCard disables when insufficient Wisdom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 50, // Need 100
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            onActivate: () {},
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.enabled, false);
  });

  testWidgets('ProphecyCard calls onActivate when tapped', (tester) async {
    bool activated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 100,
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            onActivate: () {
              activated = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Activate'));
    await tester.pump();

    expect(activated, true);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/prophecy_card_test.dart`
Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Create ProphecyCard widget**

Create `lib/widgets/prophecy_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:idleidle/models/prophecy.dart';
import 'package:idleidle/utils/number_formatter.dart';

class ProphecyCard extends StatelessWidget {
  final ProphecyType prophecy;
  final double currentWisdom;
  final bool isOnCooldown;
  final Duration cooldownRemaining;
  final VoidCallback onActivate;

  const ProphecyCard({
    Key? key,
    required this.prophecy,
    required this.currentWisdom,
    required this.isOnCooldown,
    required this.cooldownRemaining,
    required this.onActivate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canAfford = currentWisdom >= prophecy.wisdomCost;
    final canActivate = !isOnCooldown && canAfford;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prophecy name
            Text(
              prophecy.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              prophecy.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            // Wisdom cost
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.purple, size: 16),
                const SizedBox(width: 4),
                Text(
                  formatNumber(prophecy.wisdomCost),
                  style: TextStyle(
                    color: canAfford ? Colors.black : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Cooldown or Activate button
            if (isOnCooldown)
              Text(
                _formatCooldown(cooldownRemaining),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              ElevatedButton(
                onPressed: canActivate ? onActivate : null,
                child: const Text('Activate'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCooldown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/prophecy_card_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/widgets/prophecy_card.dart test/widgets/prophecy_card_test.dart
git commit -m "feat: create ProphecyCard widget"
```

---

### Task 12: Create Prophecy Screen (8th Tab)

**Files:**
- Create: `lib/screens/prophecy_screen.dart`
- Create: `test/screens/prophecy_screen_test.dart`

**Step 1: Write the failing test**

```dart
// In test/screens/prophecy_screen_test.dart:

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleidle/models/prophecy.dart';
import 'package:idleidle/screens/prophecy_screen.dart';

void main() {
  testWidgets('ProphecyScreen displays all 10 prophecies', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    // Should show all prophecy names
    expect(find.text('Vision of Prosperity'), findsOneWidget);
    expect(find.text('Solar Blessing'), findsOneWidget);
    expect(find.text('Apollo\'s Grand Vision'), findsOneWidget);
  });

  testWidgets('ProphecyScreen shows Wisdom balance', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    expect(find.textContaining('Wisdom:'), findsOneWidget);
  });

  testWidgets('ProphecyScreen grouped by tier', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    expect(find.text('Tier 1: Minor Prophecies'), findsOneWidget);
    expect(find.text('Tier 2: Standard Prophecies'), findsOneWidget);
    expect(find.text('Tier 3: Major Prophecies'), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/screens/prophecy_screen_test.dart`
Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Create ProphecyScreen**

Create `lib/screens/prophecy_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleidle/models/prophecy.dart';
import 'package:idleidle/models/resource.dart';
import 'package:idleidle/providers/game_state.dart';
import 'package:idleidle/utils/number_formatter.dart';
import 'package:idleidle/widgets/prophecy_card.dart';

class ProphecyScreen extends ConsumerWidget {
  const ProphecyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final currentWisdom = gameState.resources[ResourceType.wisdom] ?? 0;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prophecies'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wisdom balance
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.purple, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wisdom: ${formatNumber(currentWisdom)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '+${formatNumber(gameState.getProductionRate(ResourceType.wisdom))}/sec',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tier 1
            _buildTierSection(
              context,
              'Tier 1: Minor Prophecies',
              _getPropheciesByTier(1),
              gameState,
              currentWisdom,
              now,
              ref,
            ),
            const SizedBox(height: 24),

            // Tier 2
            _buildTierSection(
              context,
              'Tier 2: Standard Prophecies',
              _getPropheciesByTier(2),
              gameState,
              currentWisdom,
              now,
              ref,
            ),
            const SizedBox(height: 24),

            // Tier 3
            _buildTierSection(
              context,
              'Tier 3: Major Prophecies',
              _getPropheciesByTier(3),
              gameState,
              currentWisdom,
              now,
              ref,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierSection(
    BuildContext context,
    String title,
    List<ProphecyType> prophecies,
    GameState gameState,
    double currentWisdom,
    DateTime now,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: prophecies.length,
          itemBuilder: (context, index) {
            final prophecy = prophecies[index];
            final isOnCooldown = gameState.prophecyState.isOnCooldown(prophecy, now);
            final cooldownRemaining =
                gameState.prophecyState.getCooldownRemaining(prophecy, now);

            return ProphecyCard(
              prophecy: prophecy,
              currentWisdom: currentWisdom,
              isOnCooldown: isOnCooldown,
              cooldownRemaining: cooldownRemaining,
              onActivate: () {
                _activateProphecy(ref, prophecy);
              },
            );
          },
        ),
      ],
    );
  }

  List<ProphecyType> _getPropheciesByTier(int tier) {
    return ProphecyType.values.where((p) => p.tier == tier).toList();
  }

  void _activateProphecy(WidgetRef ref, ProphecyType prophecy) {
    final notifier = ref.read(gameStateProvider.notifier);
    try {
      notifier.activateProphecy(prophecy);
    } catch (e) {
      // Show error snackbar
      // (requires BuildContext, handle in widget tree)
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/screens/prophecy_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/screens/prophecy_screen.dart test/screens/prophecy_screen_test.dart
git commit -m "feat: create ProphecyScreen (8th tab)"
```

---

### Task 13: Update HomeScreen to Add Prophecy Tab

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Test: `test/screens/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
// In test/screens/home_screen_test.dart, add:

test('Prophecy tab appears when Apollo unlocked', () async {
  final container = ProviderContainer(
    overrides: [
      gameStateProvider.overrideWith((ref) {
        return GameState.initial().copyWith(
          unlockedGods: [God.hermes, God.hestia, God.demeter, God.dionysus, God.athena, God.apollo],
        );
      }),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: HomeScreen()),
    ),
  );

  expect(find.text('Prophecy'), findsOneWidget); // Tab label
});

test('Prophecy tab hidden before Apollo unlocked', () async {
  final container = ProviderContainer(
    overrides: [
      gameStateProvider.overrideWith((ref) {
        return GameState.initial().copyWith(
          unlockedGods: [God.hermes, God.hestia, God.demeter, God.dionysus, God.athena],
        );
      }),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: HomeScreen()),
    ),
  );

  expect(find.text('Prophecy'), findsNothing);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/screens/home_screen_test.dart`
Expected: FAIL (Prophecy tab not present)

**Step 3: Add Prophecy tab to HomeScreen**

In `lib/screens/home_screen.dart`:

```dart
import 'package:idleidle/screens/prophecy_screen.dart';
import 'package:idleidle/models/god.dart';

class HomeScreen extends ConsumerStatefulWidget {
  // ... existing code ...
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _updateTabController();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTabController();
  }

  void _updateTabController() {
    final gameState = ref.read(gameStateProvider);
    final tabCount = _calculateTabCount(gameState);

    if (_tabController.length != tabCount) {
      _tabController.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  int _calculateTabCount(GameState gameState) {
    int count = 4; // Home, Buildings, Achievements, Settings

    if (gameState.hasUnlockedGod(God.athena)) {
      count++; // Research tab
    }

    if (gameState.hasUnlockedGod(God.ares)) {
      count++; // Conquest tab
    }

    if (gameState.hasUnlockedGod(God.dionysus)) {
      count++; // Reincarnation tab
    }

    if (gameState.hasUnlockedGod(God.apollo)) {
      count++; // Prophecy tab (NEW)
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    // Home tab
    tabs.add(const Tab(text: 'Home'));
    tabViews.add(HomeTab());

    // Buildings tab
    tabs.add(const Tab(text: 'Buildings'));
    tabViews.add(BuildingsTab());

    // Research tab (if Athena unlocked)
    if (gameState.hasUnlockedGod(God.athena)) {
      tabs.add(const Tab(text: 'Research'));
      tabViews.add(ResearchScreen());
    }

    // Conquest tab (if Ares unlocked)
    if (gameState.hasUnlockedGod(God.ares)) {
      tabs.add(const Tab(text: 'Conquest'));
      tabViews.add(ConquestScreen());
    }

    // Prophecy tab (if Apollo unlocked) - NEW
    if (gameState.hasUnlockedGod(God.apollo)) {
      tabs.add(const Tab(text: 'Prophecy'));
      tabViews.add(ProphecyScreen());
    }

    // Achievements tab
    tabs.add(const Tab(text: 'Achievements'));
    tabViews.add(AchievementsTab());

    // Reincarnation tab (if Dionysus unlocked)
    if (gameState.hasUnlockedGod(God.dionysus)) {
      tabs.add(const Tab(text: 'Reincarnation'));
      tabViews.add(ReincarnationScreen());
    }

    // Settings tab
    tabs.add(const Tab(text: 'Settings'));
    tabViews.add(SettingsTab());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mythical Cats'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabViews,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/screens/home_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/screens/home_screen.dart test/screens/home_screen_test.dart
git commit -m "feat: add Prophecy tab to HomeScreen (8th tab)"
```

---

## Part 5: Remaining Implementation (Tasks 14-20)

Due to space constraints, the remaining tasks follow the same TDD pattern:

### Task 14: Add Wisdom Display to Home Tab
- Files: `lib/widgets/home_tab.dart`, `test/widgets/home_tab_test.dart`
- Write test → Run fail → Add Wisdom resource display (6th resource) → Run pass → Commit

### Task 15: Update Buildings Tab with Athena/Apollo Sections
- Files: `lib/widgets/buildings_tab.dart`, `test/widgets/buildings_tab_test.dart`
- Write test → Run fail → Add Athena section after Dionysus → Add Apollo section after Athena → Run pass → Commit

### Task 16: Add 3 New Territories (Conquest)
- Files: `lib/models/territory.dart`, `test/models/territory_test.dart`
- Write test → Run fail → Add Academy District, Oracle's Peak, Library of Alexandria → Run pass → Commit

### Task 17: Implement Territory Bonuses
- Files: `lib/providers/game_state.dart`, `test/providers/game_state_test.dart`
- Write test → Run fail → Apply +15% Athena Wisdom, -10% prophecy cooldowns, +25% Knowledge research → Run pass → Commit

### Task 18: Add 10 Phase 5 Achievements
- Files: `lib/models/achievement.dart`, `test/models/achievement_test.dart`
- Write test → Run fail → Add 10 achievements with unlock conditions → Run pass → Commit

### Task 19: Apply Achievement Rewards
- Files: `lib/providers/game_state.dart`, `test/providers/game_state_test.dart`
- Write test → Run fail → Apply +Wisdom/sec, +% production bonuses → Run pass → Commit

### Task 20: End-to-End Integration Test
- Files: `test/e2e/phase5_flow_test.dart`
- Write complete flow test: Unlock Athena → Build Hall of Wisdom → Generate Wisdom → Complete research → Unlock Apollo → Activate prophecy → Verify all systems working → Run pass → Commit

---

## Execution Instructions

### Prerequisites
- Flutter SDK 3.x installed
- Dart SDK included with Flutter
- Run `flutter pub get` to install dependencies
- Ensure all Phase 4 tests passing (230 tests)

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/prophecy_test.dart

# Run with coverage
flutter test --coverage
```

### Development Workflow
1. Always write test first (TDD)
2. Run test to see it fail
3. Implement minimal code to pass
4. Run test to see it pass
5. Commit immediately with descriptive message

### Commit Message Format
```
feat: add Wisdom resource type
fix: prophecy cooldown not persisting
test: add Athena building tests
refactor: extract prophecy activation logic
```

### Branch Strategy
- Work in feature branch: `phase5-athena-apollo`
- Frequent commits (every 5-10 minutes)
- Merge to main when all tests pass

### Estimated Timeline
- Tasks 1-5 (Core Models): 2-3 hours
- Tasks 6-8 (Prophecy System): 3-4 hours
- Tasks 9-10 (Research): 2 hours
- Tasks 11-13 (UI Components): 3-4 hours
- Tasks 14-20 (Integration): 4-5 hours
- **Total: 14-18 hours of focused development**

---

## Testing Checklist

After all tasks complete, verify:

- [ ] All 250+ tests passing (existing + new)
- [ ] Wisdom generates from Athena/Apollo buildings
- [ ] All 10 prophecies activatable
- [ ] Prophecy cooldowns work correctly
- [ ] Research bonuses apply to Wisdom production
- [ ] Territory bonuses apply correctly
- [ ] Achievements unlock and grant rewards
- [ ] Prophecy tab appears when Apollo unlocked
- [ ] UI responsive on mobile (320px width)
- [ ] No console errors or warnings

---

## References

- Design Document: `docs/plans/2025-11-11-phase5-design.md`
- Phase 4 Implementation: Previous PR/commit history
- Existing Patterns: `lib/models/building.dart`, `lib/providers/game_state.dart`

---

**Plan complete. Ready for execution using superpowers:executing-plans or superpowers:subagent-driven-development.**
