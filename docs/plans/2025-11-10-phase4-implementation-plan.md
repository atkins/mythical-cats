# Phase 4: Prestige System - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement reincarnation/prestige system with Primordial Essence currency, 4 skill trees, and patron bonuses.

**Architecture:** TDD approach building from models → business logic → UI. Permanent upgrades stack additively, patron bonuses calculated per run. Research and achievements persist through reincarnation.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, Dart enums, JSON serialization

---

## Task 1: PrimordialForce Enum

**Files:**
- Create: `lib/models/primordial_force.dart`
- Test: `test/models/primordial_force_test.dart`

**Step 1: Write the failing test**

Create `test/models/primordial_force_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialForce', () {
    test('has all 4 forces', () {
      expect(PrimordialForce.chaos, isNotNull);
      expect(PrimordialForce.gaia, isNotNull);
      expect(PrimordialForce.nyx, isNotNull);
      expect(PrimordialForce.erebus, isNotNull);
    });

    test('has correct display names', () {
      expect(PrimordialForce.chaos.displayName, 'Chaos');
      expect(PrimordialForce.gaia.displayName, 'Gaia');
      expect(PrimordialForce.nyx.displayName, 'Nyx');
      expect(PrimordialForce.erebus.displayName, 'Erebus');
    });

    test('has correct descriptions', () {
      expect(PrimordialForce.chaos.description, 'Active Play - Click Power');
      expect(PrimordialForce.gaia.description, 'Building Production & Efficiency');
      expect(PrimordialForce.nyx.description, 'Offline Progression & Time');
      expect(PrimordialForce.erebus.description, 'Tier 2 Resources & Wealth');
    });

    test('has correct icons', () {
      expect(PrimordialForce.chaos.icon, '⚡');
      expect(PrimordialForce.gaia.icon, '🌿');
      expect(PrimordialForce.nyx.icon, '🌙');
      expect(PrimordialForce.erebus.icon, '💎');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/primordial_force_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/models/primordial_force.dart`:

```dart
enum PrimordialForce {
  chaos,
  gaia,
  nyx,
  erebus;

  String get displayName {
    switch (this) {
      case PrimordialForce.chaos:
        return 'Chaos';
      case PrimordialForce.gaia:
        return 'Gaia';
      case PrimordialForce.nyx:
        return 'Nyx';
      case PrimordialForce.erebus:
        return 'Erebus';
    }
  }

  String get description {
    switch (this) {
      case PrimordialForce.chaos:
        return 'Active Play - Click Power';
      case PrimordialForce.gaia:
        return 'Building Production & Efficiency';
      case PrimordialForce.nyx:
        return 'Offline Progression & Time';
      case PrimordialForce.erebus:
        return 'Tier 2 Resources & Wealth';
    }
  }

  String get icon {
    switch (this) {
      case PrimordialForce.chaos:
        return '⚡';
      case PrimordialForce.gaia:
        return '🌿';
      case PrimordialForce.nyx:
        return '🌙';
      case PrimordialForce.erebus:
        return '💎';
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/primordial_force_test.dart`

Expected: All tests pass (4 passing)

**Step 5: Commit**

```bash
git add lib/models/primordial_force.dart test/models/primordial_force_test.dart
git commit -m "feat: add PrimordialForce enum with display properties"
```

---

## Task 2: PrimordialUpgrade Model

**Files:**
- Create: `lib/models/primordial_upgrade.dart`
- Test: `test/models/primordial_upgrade_test.dart`

**Step 1: Write the failing test**

Create `test/models/primordial_upgrade_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/primordial_upgrade.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialUpgrade', () {
    test('creates upgrade with all properties', () {
      const upgrade = PrimordialUpgrade(
        id: 'chaos_1',
        force: PrimordialForce.chaos,
        tier: 1,
        cost: 10,
        name: 'Chaos I',
        effect: '+10% click power',
      );

      expect(upgrade.id, 'chaos_1');
      expect(upgrade.force, PrimordialForce.chaos);
      expect(upgrade.tier, 1);
      expect(upgrade.cost, 10);
      expect(upgrade.name, 'Chaos I');
      expect(upgrade.effect, '+10% click power');
    });

    test('different tiers have different costs', () {
      const tier1 = PrimordialUpgrade(
        id: 'chaos_1',
        force: PrimordialForce.chaos,
        tier: 1,
        cost: 10,
        name: 'Chaos I',
        effect: '+10% click power',
      );

      const tier2 = PrimordialUpgrade(
        id: 'chaos_2',
        force: PrimordialForce.chaos,
        tier: 2,
        cost: 25,
        name: 'Chaos II',
        effect: '+25% click power',
      );

      expect(tier1.cost, 10);
      expect(tier2.cost, 25);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/primordial_upgrade_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/models/primordial_upgrade.dart`:

```dart
import 'package:mythical_cats/models/primordial_force.dart';

class PrimordialUpgrade {
  final String id;
  final PrimordialForce force;
  final int tier;
  final int cost;
  final String name;
  final String effect;

  const PrimordialUpgrade({
    required this.id,
    required this.force,
    required this.tier,
    required this.cost,
    required this.name,
    required this.effect,
  });
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/primordial_upgrade_test.dart`

Expected: All tests pass (2 passing)

**Step 5: Commit**

```bash
git add lib/models/primordial_upgrade.dart test/models/primordial_upgrade_test.dart
git commit -m "feat: add PrimordialUpgrade model"
```

---

## Task 3: PrimordialUpgradeDefinitions

**Files:**
- Create: `lib/models/primordial_upgrade_definitions.dart`
- Test: `test/models/primordial_upgrade_definitions_test.dart`

**Step 1: Write the failing test**

Create `test/models/primordial_upgrade_definitions_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialUpgradeDefinitions', () {
    test('chaos1 has correct properties', () {
      const upgrade = PrimordialUpgradeDefinitions.chaos1;
      expect(upgrade.id, 'chaos_1');
      expect(upgrade.force, PrimordialForce.chaos);
      expect(upgrade.tier, 1);
      expect(upgrade.cost, 10);
      expect(upgrade.name, 'Chaos I');
      expect(upgrade.effect, '+10% click power');
    });

    test('all 20 upgrades exist', () {
      expect(PrimordialUpgradeDefinitions.all.length, 20);
    });

    test('getForceUpgrades returns only Chaos upgrades', () {
      final chaosUpgrades = PrimordialUpgradeDefinitions.getForceUpgrades(PrimordialForce.chaos);
      expect(chaosUpgrades.length, 5);
      expect(chaosUpgrades.every((u) => u.force == PrimordialForce.chaos), true);
    });

    test('getForceUpgrades returns upgrades in tier order', () {
      final chaosUpgrades = PrimordialUpgradeDefinitions.getForceUpgrades(PrimordialForce.chaos);
      expect(chaosUpgrades[0].tier, 1);
      expect(chaosUpgrades[1].tier, 2);
      expect(chaosUpgrades[2].tier, 3);
      expect(chaosUpgrades[3].tier, 4);
      expect(chaosUpgrades[4].tier, 5);
    });

    test('getById returns correct upgrade', () {
      final upgrade = PrimordialUpgradeDefinitions.getById('gaia_3');
      expect(upgrade?.id, 'gaia_3');
      expect(upgrade?.force, PrimordialForce.gaia);
    });

    test('getById returns null for invalid id', () {
      final upgrade = PrimordialUpgradeDefinitions.getById('invalid');
      expect(upgrade, isNull);
    });

    test('tier costs follow correct progression', () {
      final chaos1 = PrimordialUpgradeDefinitions.chaos1;
      final chaos2 = PrimordialUpgradeDefinitions.chaos2;
      final chaos3 = PrimordialUpgradeDefinitions.chaos3;
      final chaos4 = PrimordialUpgradeDefinitions.chaos4;
      final chaos5 = PrimordialUpgradeDefinitions.chaos5;

      expect(chaos1.cost, 10);
      expect(chaos2.cost, 25);
      expect(chaos3.cost, 50);
      expect(chaos4.cost, 100);
      expect(chaos5.cost, 200);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/primordial_upgrade_definitions_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/models/primordial_upgrade_definitions.dart`:

```dart
import 'package:mythical_cats/models/primordial_upgrade.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PrimordialUpgradeDefinitions {
  // Chaos upgrades
  static const chaos1 = PrimordialUpgrade(
    id: 'chaos_1',
    force: PrimordialForce.chaos,
    tier: 1,
    cost: 10,
    name: 'Chaos I',
    effect: '+10% click power',
  );

  static const chaos2 = PrimordialUpgrade(
    id: 'chaos_2',
    force: PrimordialForce.chaos,
    tier: 2,
    cost: 25,
    name: 'Chaos II',
    effect: '+25% click power',
  );

  static const chaos3 = PrimordialUpgrade(
    id: 'chaos_3',
    force: PrimordialForce.chaos,
    tier: 3,
    cost: 50,
    name: 'Chaos III',
    effect: '+50% click power',
  );

  static const chaos4 = PrimordialUpgrade(
    id: 'chaos_4',
    force: PrimordialForce.chaos,
    tier: 4,
    cost: 100,
    name: 'Chaos IV',
    effect: '+100% click power',
  );

  static const chaos5 = PrimordialUpgrade(
    id: 'chaos_5',
    force: PrimordialForce.chaos,
    tier: 5,
    cost: 200,
    name: 'Chaos V',
    effect: '+150% click power, +10% Primordial Essence',
  );

  // Gaia upgrades
  static const gaia1 = PrimordialUpgrade(
    id: 'gaia_1',
    force: PrimordialForce.gaia,
    tier: 1,
    cost: 10,
    name: 'Gaia I',
    effect: '+10% building production',
  );

  static const gaia2 = PrimordialUpgrade(
    id: 'gaia_2',
    force: PrimordialForce.gaia,
    tier: 2,
    cost: 25,
    name: 'Gaia II',
    effect: '+25% building production',
  );

  static const gaia3 = PrimordialUpgrade(
    id: 'gaia_3',
    force: PrimordialForce.gaia,
    tier: 3,
    cost: 50,
    name: 'Gaia III',
    effect: '+50% building production, -10% building costs',
  );

  static const gaia4 = PrimordialUpgrade(
    id: 'gaia_4',
    force: PrimordialForce.gaia,
    tier: 4,
    cost: 100,
    name: 'Gaia IV',
    effect: '+100% building production, -15% building costs',
  );

  static const gaia5 = PrimordialUpgrade(
    id: 'gaia_5',
    force: PrimordialForce.gaia,
    tier: 5,
    cost: 200,
    name: 'Gaia V',
    effect: '+150% building production, +10% Primordial Essence',
  );

  // Nyx upgrades
  static const nyx1 = PrimordialUpgrade(
    id: 'nyx_1',
    force: PrimordialForce.nyx,
    tier: 1,
    cost: 10,
    name: 'Nyx I',
    effect: '+25% offline progression',
  );

  static const nyx2 = PrimordialUpgrade(
    id: 'nyx_2',
    force: PrimordialForce.nyx,
    tier: 2,
    cost: 25,
    name: 'Nyx II',
    effect: '+50% offline progression',
  );

  static const nyx3 = PrimordialUpgrade(
    id: 'nyx_3',
    force: PrimordialForce.nyx,
    tier: 3,
    cost: 50,
    name: 'Nyx III',
    effect: '+100% offline progression, 48h cap',
  );

  static const nyx4 = PrimordialUpgrade(
    id: 'nyx_4',
    force: PrimordialForce.nyx,
    tier: 4,
    cost: 100,
    name: 'Nyx IV',
    effect: '+150% offline progression, 72h cap',
  );

  static const nyx5 = PrimordialUpgrade(
    id: 'nyx_5',
    force: PrimordialForce.nyx,
    tier: 5,
    cost: 200,
    name: 'Nyx V',
    effect: '+200% offline progression, +10% Primordial Essence',
  );

  // Erebus upgrades
  static const erebus1 = PrimordialUpgrade(
    id: 'erebus_1',
    force: PrimordialForce.erebus,
    tier: 1,
    cost: 10,
    name: 'Erebus I',
    effect: '+15% Divine Essence production',
  );

  static const erebus2 = PrimordialUpgrade(
    id: 'erebus_2',
    force: PrimordialForce.erebus,
    tier: 2,
    cost: 25,
    name: 'Erebus II',
    effect: '+30% Divine Essence, +15% Ambrosia',
  );

  static const erebus3 = PrimordialUpgrade(
    id: 'erebus_3',
    force: PrimordialForce.erebus,
    tier: 3,
    cost: 50,
    name: 'Erebus III',
    effect: '+50% Divine Essence, +30% Ambrosia',
  );

  static const erebus4 = PrimordialUpgrade(
    id: 'erebus_4',
    force: PrimordialForce.erebus,
    tier: 4,
    cost: 100,
    name: 'Erebus IV',
    effect: '+75% Tier 2 resources',
  );

  static const erebus5 = PrimordialUpgrade(
    id: 'erebus_5',
    force: PrimordialForce.erebus,
    tier: 5,
    cost: 200,
    name: 'Erebus V',
    effect: '+100% Tier 2 resources, +10% Primordial Essence',
  );

  static List<PrimordialUpgrade> getForceUpgrades(PrimordialForce force) {
    return all.where((u) => u.force == force).toList()
      ..sort((a, b) => a.tier.compareTo(b.tier));
  }

  static List<PrimordialUpgrade> get all => [
        chaos1, chaos2, chaos3, chaos4, chaos5,
        gaia1, gaia2, gaia3, gaia4, gaia5,
        nyx1, nyx2, nyx3, nyx4, nyx5,
        erebus1, erebus2, erebus3, erebus4, erebus5,
      ];

  static PrimordialUpgrade? getById(String id) {
    try {
      return all.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/primordial_upgrade_definitions_test.dart`

Expected: All tests pass (7 passing)

**Step 5: Commit**

```bash
git add lib/models/primordial_upgrade_definitions.dart test/models/primordial_upgrade_definitions_test.dart
git commit -m "feat: add all 20 primordial upgrade definitions"
```

---

## Task 4: ReincarnationState Model

**Files:**
- Create: `lib/models/reincarnation_state.dart`
- Test: `test/models/reincarnation_state_test.dart`

**Step 1: Write the failing test**

Create `test/models/reincarnation_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('ReincarnationState', () {
    test('initial state has correct defaults', () {
      const state = ReincarnationState();
      expect(state.reincarnationCount, 0);
      expect(state.totalPrimordialEssence, 0);
      expect(state.availablePrimordialEssence, 0);
      expect(state.purchasedUpgrades.isEmpty, true);
      expect(state.currentPatron, isNull);
      expect(state.totalCatsAllTime, 0);
    });

    test('copyWith creates new instance with changes', () {
      const state = ReincarnationState();
      final updated = state.copyWith(
        reincarnationCount: 5,
        currentPatron: PrimordialForce.chaos,
      );

      expect(updated.reincarnationCount, 5);
      expect(updated.currentPatron, PrimordialForce.chaos);
      expect(updated.totalPrimordialEssence, 0); // unchanged
    });

    test('toJson serializes correctly', () {
      const state = ReincarnationState(
        reincarnationCount: 3,
        totalPrimordialEssence: 100,
        availablePrimordialEssence: 25,
        purchasedUpgrades: {'chaos_1', 'gaia_1'},
        currentPatron: PrimordialForce.chaos,
        totalCatsAllTime: 5000000000,
      );

      final json = state.toJson();

      expect(json['reincarnationCount'], 3);
      expect(json['totalPrimordialEssence'], 100);
      expect(json['availablePrimordialEssence'], 25);
      expect(json['purchasedUpgrades'], ['chaos_1', 'gaia_1']);
      expect(json['currentPatron'], 'chaos');
      expect(json['totalCatsAllTime'], 5000000000);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'reincarnationCount': 3,
        'totalPrimordialEssence': 100,
        'availablePrimordialEssence': 25,
        'purchasedUpgrades': ['chaos_1', 'gaia_1'],
        'currentPatron': 'chaos',
        'totalCatsAllTime': 5000000000,
      };

      final state = ReincarnationState.fromJson(json);

      expect(state.reincarnationCount, 3);
      expect(state.totalPrimordialEssence, 100);
      expect(state.availablePrimordialEssence, 25);
      expect(state.purchasedUpgrades.contains('chaos_1'), true);
      expect(state.currentPatron, PrimordialForce.chaos);
      expect(state.totalCatsAllTime, 5000000000);
    });

    test('fromJson handles null currentPatron', () {
      final json = {
        'reincarnationCount': 0,
        'totalPrimordialEssence': 0,
        'availablePrimordialEssence': 0,
        'purchasedUpgrades': <String>[],
        'totalCatsAllTime': 0,
      };

      final state = ReincarnationState.fromJson(json);
      expect(state.currentPatron, isNull);
    });

    test('JSON round-trip preserves data', () {
      const original = ReincarnationState(
        reincarnationCount: 5,
        totalPrimordialEssence: 200,
        availablePrimordialEssence: 50,
        purchasedUpgrades: {'chaos_1', 'chaos_2', 'gaia_1'},
        currentPatron: PrimordialForce.nyx,
        totalCatsAllTime: 10000000000,
      );

      final json = original.toJson();
      final restored = ReincarnationState.fromJson(json);

      expect(restored.reincarnationCount, original.reincarnationCount);
      expect(restored.totalPrimordialEssence, original.totalPrimordialEssence);
      expect(restored.purchasedUpgrades, original.purchasedUpgrades);
      expect(restored.currentPatron, original.currentPatron);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/reincarnation_state_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/models/reincarnation_state.dart`:

```dart
import 'package:mythical_cats/models/primordial_force.dart';

class ReincarnationState {
  final int reincarnationCount;
  final int totalPrimordialEssence;
  final int availablePrimordialEssence;
  final Set<String> purchasedUpgrades;
  final PrimordialForce? currentPatron;
  final double totalCatsAllTime;

  const ReincarnationState({
    this.reincarnationCount = 0,
    this.totalPrimordialEssence = 0,
    this.availablePrimordialEssence = 0,
    this.purchasedUpgrades = const {},
    this.currentPatron,
    this.totalCatsAllTime = 0,
  });

  ReincarnationState copyWith({
    int? reincarnationCount,
    int? totalPrimordialEssence,
    int? availablePrimordialEssence,
    Set<String>? purchasedUpgrades,
    PrimordialForce? currentPatron,
    double? totalCatsAllTime,
  }) {
    return ReincarnationState(
      reincarnationCount: reincarnationCount ?? this.reincarnationCount,
      totalPrimordialEssence: totalPrimordialEssence ?? this.totalPrimordialEssence,
      availablePrimordialEssence: availablePrimordialEssence ?? this.availablePrimordialEssence,
      purchasedUpgrades: purchasedUpgrades ?? this.purchasedUpgrades,
      currentPatron: currentPatron ?? this.currentPatron,
      totalCatsAllTime: totalCatsAllTime ?? this.totalCatsAllTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reincarnationCount': reincarnationCount,
      'totalPrimordialEssence': totalPrimordialEssence,
      'availablePrimordialEssence': availablePrimordialEssence,
      'purchasedUpgrades': purchasedUpgrades.toList(),
      'currentPatron': currentPatron?.name,
      'totalCatsAllTime': totalCatsAllTime,
    };
  }

  factory ReincarnationState.fromJson(Map<String, dynamic> json) {
    return ReincarnationState(
      reincarnationCount: json['reincarnationCount'] as int? ?? 0,
      totalPrimordialEssence: json['totalPrimordialEssence'] as int? ?? 0,
      availablePrimordialEssence: json['availablePrimordialEssence'] as int? ?? 0,
      purchasedUpgrades: (json['purchasedUpgrades'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      currentPatron: json['currentPatron'] != null
          ? PrimordialForce.values
              .firstWhere((f) => f.name == json['currentPatron'])
          : null,
      totalCatsAllTime: (json['totalCatsAllTime'] as num?)?.toDouble() ?? 0,
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/reincarnation_state_test.dart`

Expected: All tests pass (7 passing)

**Step 5: Commit**

```bash
git add lib/models/reincarnation_state.dart test/models/reincarnation_state_test.dart
git commit -m "feat: add ReincarnationState model with JSON serialization"
```

---

## Task 5: GameState Integration

**Files:**
- Modify: `lib/models/game_state.dart`
- Test: `test/models/game_state_test.dart`

**Step 1: Write the failing test**

Add to `test/models/game_state_test.dart`:

```dart
// Add import at top
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

// Add to existing group 'GameState'
test('initial state has empty reincarnation state', () {
  final state = GameState.initial();
  expect(state.reincarnationState.reincarnationCount, 0);
  expect(state.reincarnationState.totalPrimordialEssence, 0);
});

test('reincarnationState serializes in toJson', () {
  final state = GameState.initial().copyWith(
    reincarnationState: const ReincarnationState(
      reincarnationCount: 3,
      totalPrimordialEssence: 100,
      currentPatron: PrimordialForce.chaos,
    ),
  );

  final json = state.toJson();
  expect(json['reincarnationState'], isNotNull);
  expect(json['reincarnationState']['reincarnationCount'], 3);
});

test('reincarnationState deserializes from JSON', () {
  final json = {
    'resources': {},
    'buildings': {},
    'unlockedGods': ['hermes'],
    'lastUpdate': DateTime.now().toIso8601String(),
    'totalCatsEarned': 0.0,
    'unlockedAchievements': <String>[],
    'completedResearch': <String>[],
    'conqueredTerritories': <String>[],
    'reincarnationState': {
      'reincarnationCount': 5,
      'totalPrimordialEssence': 200,
      'availablePrimordialEssence': 50,
      'purchasedUpgrades': <String>[],
      'currentPatron': 'gaia',
      'totalCatsAllTime': 0,
    },
  };

  final state = GameState.fromJson(json);
  expect(state.reincarnationState.reincarnationCount, 5);
  expect(state.reincarnationState.currentPatron, PrimordialForce.gaia);
});

test('hasPrimordialUpgrade returns true when upgrade purchased', () {
  final state = GameState.initial().copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'chaos_1', 'gaia_1'},
    ),
  );

  expect(state.hasPrimordialUpgrade('chaos_1'), true);
  expect(state.hasPrimordialUpgrade('gaia_1'), true);
  expect(state.hasPrimordialUpgrade('nyx_1'), false);
});

test('getPrimordialTier returns highest tier purchased', () {
  final state = GameState.initial().copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'chaos_1', 'chaos_2', 'chaos_3'},
    ),
  );

  expect(state.getPrimordialTier(PrimordialForce.chaos), 3);
  expect(state.getPrimordialTier(PrimordialForce.gaia), 0);
});

test('canReincarnate returns true when >= 1B cats', () {
  final state = GameState.initial().copyWith(totalCatsEarned: 1000000000);
  expect(state.canReincarnate(), true);
});

test('canReincarnate returns false when < 1B cats', () {
  final state = GameState.initial().copyWith(totalCatsEarned: 999999999);
  expect(state.canReincarnate(), false);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/game_state_test.dart`

Expected: FAIL with various errors (missing field, missing methods)

**Step 3: Implement GameState changes**

Modify `lib/models/game_state.dart`:

Add import at top:
```dart
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';
```

Add field to GameState class:
```dart
final ReincarnationState reincarnationState;
```

Update constructor:
```dart
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
});
```

Update initial():
```dart
factory GameState.initial() {
  return GameState(
    resources: {
      ResourceType.cats: 0,
      ResourceType.offerings: 0,
      ResourceType.prayers: 0,
      ResourceType.divineEssence: 0,
      ResourceType.ambrosia: 0,
    },
    buildings: {},
    unlockedGods: {God.hermes},
    lastUpdate: DateTime.now(),
    totalCatsEarned: 0,
    unlockedAchievements: {},
    completedResearch: {},
    conqueredTerritories: {},
    reincarnationState: const ReincarnationState(),
  );
}
```

Update copyWith():
```dart
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
}) {
  return GameState(
    resources: resources ?? this.resources,
    buildings: buildings ?? this.buildings,
    unlockedGods: unlockedGods ?? this.unlockedGods,
    lastUpdate: lastUpdate ?? this.lastUpdate,
    totalCatsEarned: totalCatsEarned ?? this.totalCatsEarned,
    unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    completedResearch: completedResearch ?? this.completedResearch,
    conqueredTerritories: conqueredTerritories ?? this.conqueredTerritories,
    reincarnationState: reincarnationState ?? this.reincarnationState,
  );
}
```

Update toJson():
```dart
Map<String, dynamic> toJson() {
  return {
    'resources': resources.map((key, value) => MapEntry(key.name, value)),
    'buildings': buildings.map((key, value) => MapEntry(key.name, value)),
    'unlockedGods': unlockedGods.map((g) => g.name).toList(),
    'lastUpdate': lastUpdate.toIso8601String(),
    'totalCatsEarned': totalCatsEarned,
    'unlockedAchievements': unlockedAchievements.toList(),
    'completedResearch': completedResearch.toList(),
    'conqueredTerritories': conqueredTerritories.toList(),
    'reincarnationState': reincarnationState.toJson(),
  };
}
```

Update fromJson():
```dart
factory GameState.fromJson(Map<String, dynamic> json) {
  return GameState(
    resources: (json['resources'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        ResourceType.values.firstWhere((r) => r.name == key),
        (value as num).toDouble(),
      ),
    ),
    buildings: (json['buildings'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            BuildingType.values.firstWhere((b) => b.name == key),
            value as int,
          ),
        ) ??
        {},
    unlockedGods: (json['unlockedGods'] as List<dynamic>)
        .map((g) => God.values.firstWhere((god) => god.name == g))
        .toSet(),
    lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    totalCatsEarned: (json['totalCatsEarned'] as num?)?.toDouble() ?? 0,
    unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {},
    completedResearch: (json['completedResearch'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {},
    conqueredTerritories: (json['conqueredTerritories'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {},
    reincarnationState: json['reincarnationState'] != null
        ? ReincarnationState.fromJson(
            json['reincarnationState'] as Map<String, dynamic>)
        : const ReincarnationState(),
  );
}
```

Add helper methods at end of class:
```dart
/// Check if player has purchased an upgrade
bool hasPrimordialUpgrade(String upgradeId) {
  return reincarnationState.purchasedUpgrades.contains(upgradeId);
}

/// Get tier of highest upgrade purchased in a force (0-5)
int getPrimordialTier(PrimordialForce force) {
  final forceUpgrades = PrimordialUpgradeDefinitions.getForceUpgrades(force);
  int maxTier = 0;
  for (final upgrade in forceUpgrades) {
    if (hasPrimordialUpgrade(upgrade.id) && upgrade.tier > maxTier) {
      maxTier = upgrade.tier;
    }
  }
  return maxTier;
}

/// Check if player can reincarnate (1B+ cats)
bool canReincarnate() {
  return totalCatsEarned >= 1000000000;
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/game_state_test.dart`

Expected: All existing tests + 7 new tests pass

**Step 5: Commit**

```bash
git add lib/models/game_state.dart test/models/game_state_test.dart
git commit -m "feat: integrate ReincarnationState into GameState"
```

---

## Task 6: PE Calculation Logic

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

**Step 1: Write the failing test**

Add to `test/providers/game_provider_test.dart`:

```dart
// Add imports at top
import 'dart:math';

// Add new group
group('GameNotifier Primordial Essence', () {
  test('calculatePrimordialEssence returns 0 below threshold', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    expect(notifier.calculatePrimordialEssence(999999999), 0);
    expect(notifier.calculatePrimordialEssence(500000000), 0);
  });

  test('calculatePrimordialEssence returns correct base values', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    expect(notifier.calculatePrimordialEssence(1000000000), 20); // 1B
    expect(notifier.calculatePrimordialEssence(10000000000), 30); // 10B
    expect(notifier.calculatePrimordialEssence(100000000000), 40); // 100B
    expect(notifier.calculatePrimordialEssence(1000000000000), 50); // 1T
  });

  test('calculatePrimordialEssence applies tier 5 bonuses', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    // Buy all 4 tier 5 upgrades (+40% PE total)
    notifier.state = notifier.state.copyWith(
      reincarnationState: const ReincarnationState(
        purchasedUpgrades: {'chaos_5', 'gaia_5', 'nyx_5', 'erebus_5'},
      ),
    );

    // 1B cats = 20 base PE * 1.4 = 28 PE
    expect(notifier.calculatePrimordialEssence(1000000000), 28);
  });

  test('calculatePrimordialEssence with partial tier 5 bonuses', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    // Buy 2 tier 5 upgrades (+20% PE)
    notifier.state = notifier.state.copyWith(
      reincarnationState: const ReincarnationState(
        purchasedUpgrades: {'chaos_5', 'gaia_5'},
      ),
    );

    // 1B cats = 20 base PE * 1.2 = 24 PE
    expect(notifier.calculatePrimordialEssence(1000000000), 24);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: FAIL with "The method 'calculatePrimordialEssence' isn't defined"

**Step 3: Implement PE calculation**

Add to `lib/providers/game_provider.dart`:

Add import at top:
```dart
import 'dart:math';
```

Add method to GameNotifier class:
```dart
/// Calculate PE earned from total cats
int calculatePrimordialEssence(double totalCats) {
  if (totalCats < 1000000000) return 0;

  final basePE = (log(totalCats) / ln10 - 8).floor() * 10;

  // Apply PE bonuses from tier 5 upgrades
  double peBonus = 0;
  if (state.hasPrimordialUpgrade('chaos_5')) peBonus += 0.1;
  if (state.hasPrimordialUpgrade('gaia_5')) peBonus += 0.1;
  if (state.hasPrimordialUpgrade('nyx_5')) peBonus += 0.1;
  if (state.hasPrimordialUpgrade('erebus_5')) peBonus += 0.1;

  return (basePE * (1 + peBonus)).floor();
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: All tests pass (including 4 new PE tests)

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add Primordial Essence calculation with tier 5 bonuses"
```

---

## Task 7: Bonus Calculation Helpers

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

**Step 1: Write the failing test**

Add to `test/providers/game_provider_test.dart` in the Primordial Essence group:

```dart
test('getClickPowerMultiplier with no upgrades', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  expect(notifier.getClickPowerMultiplier(), 1.0);
});

test('getClickPowerMultiplier with Chaos upgrades only', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'chaos_1', 'chaos_2', 'chaos_3'},
    ),
  );

  // 10% + 25% + 50% = 85% = 1.85x
  expect(notifier.getClickPowerMultiplier(), closeTo(1.85, 0.01));
});

test('getClickPowerMultiplier with Chaos patron bonus', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'chaos_1', 'chaos_2', 'chaos_3'},
      currentPatron: PrimordialForce.chaos,
    ),
  );

  // Permanent: 85%, Patron: 50% + 30% (3 tiers) = 80%
  // Total: 1.85 + 0.8 = 2.65x
  expect(notifier.getClickPowerMultiplier(), closeTo(2.65, 0.01));
});

test('getBuildingProductionMultiplier with Gaia upgrades', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'gaia_1', 'gaia_2'},
    ),
  );

  // 10% + 25% = 35% = 1.35x
  expect(notifier.getBuildingProductionMultiplier(), closeTo(1.35, 0.01));
});

test('getBuildingCostReduction with Gaia upgrades', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'gaia_3', 'gaia_4'},
    ),
  );

  // Gaia III: -10%, Gaia IV: -15% (total -15% because IV replaces III)
  expect(notifier.getBuildingCostReduction(), 0.15);
});

test('getOfflineProgressionMultiplier with Nyx upgrades', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'nyx_1', 'nyx_2', 'nyx_3'},
    ),
  );

  // 25% + 50% + 100% = 175% = 2.75x
  expect(notifier.getOfflineProgressionMultiplier(), closeTo(2.75, 0.01));
});

test('getOfflineCapHours with Nyx upgrades', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  // Default cap
  expect(notifier.getOfflineCapHours(), 24);

  // With Nyx III
  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'nyx_3'},
    ),
  );
  expect(notifier.getOfflineCapHours(), 48);

  // With Nyx IV
  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'nyx_4'},
    ),
  );
  expect(notifier.getOfflineCapHours(), 72);
});

test('getTier2ProductionMultiplier with Erebus upgrades', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      purchasedUpgrades: {'erebus_1', 'erebus_2'},
    ),
  );

  // 15% + 30% = 45% = 1.45x
  expect(notifier.getTier2ProductionMultiplier(), closeTo(1.45, 0.01));
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: FAIL with "The method 'getClickPowerMultiplier' isn't defined" (and similar for other methods)

**Step 3: Implement bonus calculation helpers**

Add to `lib/providers/game_provider.dart` in GameNotifier class:

```dart
/// Get total click power multiplier from Chaos upgrades + patron
double getClickPowerMultiplier() {
  double multiplier = 1.0;

  // Permanent Chaos upgrades
  if (state.hasPrimordialUpgrade('chaos_1')) multiplier += 0.10;
  if (state.hasPrimordialUpgrade('chaos_2')) multiplier += 0.25;
  if (state.hasPrimordialUpgrade('chaos_3')) multiplier += 0.50;
  if (state.hasPrimordialUpgrade('chaos_4')) multiplier += 1.00;
  if (state.hasPrimordialUpgrade('chaos_5')) multiplier += 1.50;

  // Chaos patron bonus
  if (state.reincarnationState.currentPatron == PrimordialForce.chaos) {
    final tier = state.getPrimordialTier(PrimordialForce.chaos);
    multiplier += 0.5 + (tier * 0.1);
  }

  return multiplier;
}

/// Get total building production multiplier from Gaia + patron + conquest
double getBuildingProductionMultiplier() {
  double multiplier = 1.0;

  // Permanent Gaia upgrades
  if (state.hasPrimordialUpgrade('gaia_1')) multiplier += 0.10;
  if (state.hasPrimordialUpgrade('gaia_2')) multiplier += 0.25;
  if (state.hasPrimordialUpgrade('gaia_3')) multiplier += 0.50;
  if (state.hasPrimordialUpgrade('gaia_4')) multiplier += 1.00;
  if (state.hasPrimordialUpgrade('gaia_5')) multiplier += 1.50;

  // Gaia patron bonus
  if (state.reincarnationState.currentPatron == PrimordialForce.gaia) {
    final tier = state.getPrimordialTier(PrimordialForce.gaia);
    multiplier += 0.5 + (tier * 0.1);
  }

  // Existing conquest bonuses (keep existing logic)
  for (final territoryId in state.conqueredTerritories) {
    final territory = ConquestDefinitions.getById(territoryId);
    if (territory != null) {
      for (final bonus in territory.productionBonus.values) {
        multiplier += bonus;
      }
    }
  }

  return multiplier;
}

/// Get building cost reduction from Gaia upgrades
double getBuildingCostReduction() {
  double reduction = 0;
  if (state.hasPrimordialUpgrade('gaia_4')) {
    reduction = 0.15; // Gaia IV is -15% (higher tier wins)
  } else if (state.hasPrimordialUpgrade('gaia_3')) {
    reduction = 0.10; // Gaia III is -10%
  }
  return reduction;
}

/// Get offline progression multiplier from Nyx + patron
double getOfflineProgressionMultiplier() {
  double multiplier = 1.0;

  if (state.hasPrimordialUpgrade('nyx_1')) multiplier += 0.25;
  if (state.hasPrimordialUpgrade('nyx_2')) multiplier += 0.50;
  if (state.hasPrimordialUpgrade('nyx_3')) multiplier += 1.00;
  if (state.hasPrimordialUpgrade('nyx_4')) multiplier += 1.50;
  if (state.hasPrimordialUpgrade('nyx_5')) multiplier += 2.00;

  if (state.reincarnationState.currentPatron == PrimordialForce.nyx) {
    final tier = state.getPrimordialTier(PrimordialForce.nyx);
    multiplier += 0.5 + (tier * 0.1);
  }

  return multiplier;
}

/// Get offline cap in hours from Nyx upgrades
int getOfflineCapHours() {
  if (state.hasPrimordialUpgrade('nyx_4')) return 72;
  if (state.hasPrimordialUpgrade('nyx_3')) return 48;
  return 24; // default
}

/// Get Tier 2 resource production multiplier from Erebus + patron
double getTier2ProductionMultiplier() {
  double multiplier = 1.0;

  if (state.hasPrimordialUpgrade('erebus_1')) multiplier += 0.15;
  if (state.hasPrimordialUpgrade('erebus_2')) multiplier += 0.30;
  if (state.hasPrimordialUpgrade('erebus_3')) multiplier += 0.50;
  if (state.hasPrimordialUpgrade('erebus_4')) multiplier += 0.75;
  if (state.hasPrimordialUpgrade('erebus_5')) multiplier += 1.00;

  if (state.reincarnationState.currentPatron == PrimordialForce.erebus) {
    final tier = state.getPrimordialTier(PrimordialForce.erebus);
    multiplier += 0.5 + (tier * 0.1);
  }

  return multiplier;
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: All tests pass (including 8 new bonus calculation tests)

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add bonus calculation helpers for all 4 forces"
```

---

## Task 8: Reincarnation Logic

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

**Step 1: Write the failing test**

Add new group to `test/providers/game_provider_test.dart`:

```dart
group('GameNotifier Reincarnation', () {
  test('reincarnate resets resources to zero', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      resources: {
        ResourceType.cats: 50000000,
        ResourceType.offerings: 10000,
      },
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.getResource(ResourceType.cats), 0);
    expect(notifier.state.getResource(ResourceType.offerings), 0);
  });

  test('reincarnate resets buildings', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      buildings: {BuildingType.smallShrine: 10, BuildingType.temple: 5},
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 0);
    expect(notifier.state.getBuildingCount(BuildingType.temple), 0);
  });

  test('reincarnate resets gods to just Hermes', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      unlockedGods: {God.hermes, God.hestia, God.athena},
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.unlockedGods.length, 1);
    expect(notifier.state.unlockedGods.contains(God.hermes), true);
  });

  test('reincarnate preserves research', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      completedResearch: {'divine_architecture_1', 'essence_refinement'},
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.completedResearch.length, 2);
    expect(notifier.state.hasCompletedResearch('divine_architecture_1'), true);
  });

  test('reincarnate preserves achievements', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      unlockedAchievements: {'cats_100', 'cats_1k'},
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.unlockedAchievements.length, 2);
    expect(notifier.state.hasUnlockedAchievement('cats_100'), true);
  });

  test('reincarnate awards PE and sets patron', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.reincarnationState.totalPrimordialEssence, 20);
    expect(notifier.state.reincarnationState.availablePrimordialEssence, 20);
    expect(notifier.state.reincarnationState.currentPatron, PrimordialForce.chaos);
  });

  test('reincarnate increments reincarnation count', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
    );

    notifier.reincarnate(PrimordialForce.chaos);
    expect(notifier.state.reincarnationState.reincarnationCount, 1);

    notifier.state = notifier.state.copyWith(totalCatsEarned: 5000000000);
    notifier.reincarnate(PrimordialForce.gaia);
    expect(notifier.state.reincarnationState.reincarnationCount, 2);
  });

  test('reincarnate accumulates totalCatsAllTime', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(totalCatsEarned: 2000000000);
    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.reincarnationState.totalCatsAllTime, 2000000000);

    notifier.state = notifier.state.copyWith(totalCatsEarned: 3000000000);
    notifier.reincarnate(PrimordialForce.gaia);

    expect(notifier.state.reincarnationState.totalCatsAllTime, 5000000000);
  });

  test('reincarnate preserves purchased upgrades', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      reincarnationState: const ReincarnationState(
        purchasedUpgrades: {'chaos_1', 'gaia_1'},
      ),
    );

    notifier.reincarnate(PrimordialForce.nyx);

    expect(notifier.state.hasPrimordialUpgrade('chaos_1'), true);
    expect(notifier.state.hasPrimordialUpgrade('gaia_1'), true);
  });

  test('reincarnate resets conquered territories', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      totalCatsEarned: 1000000000,
      conqueredTerritories: {'northern_wilds', 'eastern_mountains'},
    );

    notifier.reincarnate(PrimordialForce.chaos);

    expect(notifier.state.conqueredTerritories.isEmpty, true);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: FAIL with "The method 'reincarnate' isn't defined"

**Step 3: Implement reincarnation logic**

Add to `lib/providers/game_provider.dart` in GameNotifier class:

```dart
void reincarnate(PrimordialForce chosenPatron) {
  // Calculate PE earned
  final peEarned = calculatePrimordialEssence(state.totalCatsEarned);

  // Store persistent data
  final persistedResearch = Set<String>.from(state.completedResearch);
  final persistedAchievements = Set<String>.from(state.unlockedAchievements);
  final persistedUpgrades =
      Set<String>.from(state.reincarnationState.purchasedUpgrades);

  // Reset to initial state but keep reincarnation progress
  state = GameState.initial().copyWith(
    completedResearch: persistedResearch,
    unlockedAchievements: persistedAchievements,
    reincarnationState: ReincarnationState(
      reincarnationCount: state.reincarnationState.reincarnationCount + 1,
      totalPrimordialEssence:
          state.reincarnationState.totalPrimordialEssence + peEarned,
      availablePrimordialEssence:
          state.reincarnationState.availablePrimordialEssence + peEarned,
      purchasedUpgrades: persistedUpgrades,
      currentPatron: chosenPatron,
      totalCatsAllTime:
          state.reincarnationState.totalCatsAllTime + state.totalCatsEarned,
    ),
  );
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: All tests pass (including 10 new reincarnation tests)

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add reincarnation logic with persistence"
```

---

## Task 9: Upgrade Purchase Logic

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

**Step 1: Write the failing test**

Add to Reincarnation group in `test/providers/game_provider_test.dart`:

```dart
test('canPurchasePrimordialUpgrade returns false when insufficient PE', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 5,
    ),
  );

  expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), false);
});

test('canPurchasePrimordialUpgrade returns true when affordable', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 20,
    ),
  );

  expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), true);
});

test('canPurchasePrimordialUpgrade returns false when missing prerequisite', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 100,
    ),
  );

  // Can't buy tier 2 without tier 1
  expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), false);
});

test('canPurchasePrimordialUpgrade returns true with prerequisite met', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 100,
      purchasedUpgrades: {'chaos_1'},
    ),
  );

  expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), true);
});

test('canPurchasePrimordialUpgrade returns false when already purchased', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 100,
      purchasedUpgrades: {'chaos_1'},
    ),
  );

  expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), false);
});

test('purchasePrimordialUpgrade deducts PE and adds upgrade', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 20,
    ),
  );

  notifier.purchasePrimordialUpgrade('chaos_1');

  expect(notifier.state.hasPrimordialUpgrade('chaos_1'), true);
  expect(notifier.state.reincarnationState.availablePrimordialEssence, 10);
});

test('purchasePrimordialUpgrade fails when not affordable', () {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    reincarnationState: const ReincarnationState(
      availablePrimordialEssence: 5,
    ),
  );

  notifier.purchasePrimordialUpgrade('chaos_1');

  // Should not purchase
  expect(notifier.state.hasPrimordialUpgrade('chaos_1'), false);
  expect(notifier.state.reincarnationState.availablePrimordialEssence, 5);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: FAIL with "The method 'canPurchasePrimordialUpgrade' isn't defined"

**Step 3: Implement upgrade purchase logic**

Add to `lib/providers/game_provider.dart` in GameNotifier class:

```dart
bool canPurchasePrimordialUpgrade(String upgradeId) {
  final upgrade = PrimordialUpgradeDefinitions.getById(upgradeId);
  if (upgrade == null) return false;

  // Already purchased
  if (state.hasPrimordialUpgrade(upgradeId)) return false;

  // Check PE cost
  if (state.reincarnationState.availablePrimordialEssence < upgrade.cost) {
    return false;
  }

  // Check prerequisite (must have previous tier)
  if (upgrade.tier > 1) {
    final prevId = '${upgrade.force.name}_${upgrade.tier - 1}';
    if (!state.hasPrimordialUpgrade(prevId)) return false;
  }

  return true;
}

void purchasePrimordialUpgrade(String upgradeId) {
  if (!canPurchasePrimordialUpgrade(upgradeId)) return;

  final upgrade = PrimordialUpgradeDefinitions.getById(upgradeId)!;

  final newUpgrades =
      Set<String>.from(state.reincarnationState.purchasedUpgrades)
        ..add(upgradeId);

  state = state.copyWith(
    reincarnationState: state.reincarnationState.copyWith(
      availablePrimordialEssence:
          state.reincarnationState.availablePrimordialEssence - upgrade.cost,
      purchasedUpgrades: newUpgrades,
    ),
  );
}
```

Add import at top:
```dart
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: All tests pass (including 7 new upgrade purchase tests)

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add upgrade purchase logic with prerequisites"
```

---

## Task 10: Update Production Methods

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

**Step 1: Write the failing test**

Add new group to `test/providers/game_provider_test.dart`:

```dart
group('GameNotifier Production with Primordial Bonuses', () {
  test('performRitual uses Chaos click power multiplier', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      reincarnationState: const ReincarnationState(
        purchasedUpgrades: {'chaos_1'}, // +10% = 1.1x
      ),
    );

    notifier.performRitual();

    expect(notifier.state.getResource(ResourceType.cats), closeTo(1.1, 0.01));
  });

  test('performRitual uses Chaos patron bonus', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      reincarnationState: const ReincarnationState(
        purchasedUpgrades: {'chaos_1', 'chaos_2'}, // 2 tiers
        currentPatron: PrimordialForce.chaos, // +50% + 20% = 70%
      ),
    );

    // Permanent: 10% + 25% = 35%
    // Patron: 70%
    // Total: 1.35 + 0.7 = 2.05x
    notifier.performRitual();
    expect(notifier.state.getResource(ResourceType.cats), closeTo(2.05, 0.01));
  });

  test('building production uses Gaia multiplier', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    // Give player a building and resources
    notifier.state = notifier.state.copyWith(
      resources: {ResourceType.cats: 1000},
      buildings: {},
      reincarnationState: const ReincarnationState(
        purchasedUpgrades: {'gaia_1'}, // +10% building production
      ),
    );

    // Buy a small shrine (produces 0.1 cats/sec)
    notifier.buyBuilding(BuildingType.smallShrine);

    // Simulate 10 seconds of production
    // 0.1 * 10 * 1.1 (Gaia I) = 1.1 cats
    final initialCats = notifier.state.getResource(ResourceType.cats);
    notifier.testUpdateGame(10.0);
    final finalCats = notifier.state.getResource(ResourceType.cats);

    expect(finalCats - initialCats, closeTo(1.1, 0.1));
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: Tests fail because bonuses not applied to production

**Step 3: Update performRitual to use click multiplier**

Modify `performRitual()` in `lib/providers/game_provider.dart`:

```dart
void performRitual() {
  final newResources = Map<ResourceType, double>.from(state.resources);

  final clickMultiplier = getClickPowerMultiplier();
  newResources[ResourceType.cats] =
      state.getResource(ResourceType.cats) + clickMultiplier;

  state = state.copyWith(
    resources: newResources,
    totalCatsEarned: state.totalCatsEarned + clickMultiplier,
  );

  _checkGodUnlocks();
  _checkAchievements();
}
```

**Step 4: Update _updateGame to use building multipliers**

Find the existing `_updateGame` method and modify the production calculation section:

```dart
void _updateGame(double deltaSeconds) {
  // Calculate production with bonuses
  double catsProduced = 0;
  double offeringsProduced = 0;
  double prayersProduced = 0;
  double divineEssenceProduced = 0;
  double ambrosiaProduced = 0;

  final buildingMultiplier = getBuildingProductionMultiplier();
  final tier2Multiplier = getTier2ProductionMultiplier();

  for (final entry in state.buildings.entries) {
    final buildingType = entry.key;
    final count = entry.value;
    final definition = BuildingDefinitions.get(buildingType);

    var production = definition.baseProduction * count * deltaSeconds;

    if (definition.productionType == ResourceType.cats) {
      catsProduced += production * buildingMultiplier;
    } else if (definition.productionType == ResourceType.offerings) {
      offeringsProduced += production * buildingMultiplier;
    } else if (definition.productionType == ResourceType.prayers) {
      prayersProduced += production * buildingMultiplier;
    } else if (definition.productionType == ResourceType.divineEssence) {
      divineEssenceProduced += production * buildingMultiplier * tier2Multiplier;
    } else if (definition.productionType == ResourceType.ambrosia) {
      ambrosiaProduced += production * buildingMultiplier * tier2Multiplier;
    }
  }

  // Update resources if any produced
  if (catsProduced > 0 ||
      offeringsProduced > 0 ||
      prayersProduced > 0 ||
      divineEssenceProduced > 0 ||
      ambrosiaProduced > 0) {
    final newResources = Map<ResourceType, double>.from(state.resources);

    if (catsProduced > 0) {
      newResources[ResourceType.cats] =
          state.getResource(ResourceType.cats) + catsProduced;
    }
    if (offeringsProduced > 0) {
      newResources[ResourceType.offerings] =
          state.getResource(ResourceType.offerings) + offeringsProduced;
    }
    if (prayersProduced > 0) {
      newResources[ResourceType.prayers] =
          state.getResource(ResourceType.prayers) + prayersProduced;
    }
    if (divineEssenceProduced > 0) {
      newResources[ResourceType.divineEssence] =
          state.getResource(ResourceType.divineEssence) + divineEssenceProduced;
    }
    if (ambrosiaProduced > 0) {
      newResources[ResourceType.ambrosia] =
          state.getResource(ResourceType.ambrosia) + ambrosiaProduced;
    }

    state = state.copyWith(
      resources: newResources,
      totalCatsEarned: state.totalCatsEarned + catsProduced,
      lastUpdate: DateTime.now(),
    );

    _checkGodUnlocks();
    _checkAchievements();
  }
}
```

**Step 5: Update buyBuilding to use cost reduction**

Find the existing `buyBuilding` method and add cost reduction:

```dart
bool buyBuilding(BuildingType type, {int amount = 1}) {
  final definition = BuildingDefinitions.get(type);

  // Calculate total cost with Gaia cost reduction
  final costReduction = getBuildingCostReduction();
  final totalCost = definition.calculateBulkCost(
    state.getBuildingCount(type),
    amount,
  );

  final effectiveCost = totalCost.map(
    (resource, cost) => MapEntry(resource, cost * (1 - costReduction)),
  );

  // Check affordability with effective cost
  for (final entry in effectiveCost.entries) {
    if (state.getResource(entry.key) < entry.value) {
      return false;
    }
  }

  // Deduct resources using effective cost
  final newResources = Map<ResourceType, double>.from(state.resources);
  for (final entry in effectiveCost.entries) {
    newResources[entry.key] = state.getResource(entry.key) - entry.value;
  }

  // Add buildings
  final newBuildings = Map<BuildingType, int>.from(state.buildings);
  newBuildings[type] = state.getBuildingCount(type) + amount;

  state = state.copyWith(
    resources: newResources,
    buildings: newBuildings,
  );

  _checkAchievements();
  return true;
}
```

**Step 6: Add test helper method**

Add to GameNotifier class for testing:

```dart
// For testing only - expose _updateGame
void testUpdateGame(double deltaSeconds) {
  _updateGame(deltaSeconds);
}
```

**Step 7: Run test to verify it passes**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: All tests pass (including 3 new production tests)

**Step 8: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: integrate primordial bonuses into production methods"
```

---

## Task 11: Phase 4 Integration Tests

**Files:**
- Create: `test/phase4_integration_test.dart`

**Step 1: Write integration tests**

Create `test/phase4_integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Full reincarnation cycle preserves research and achievements', () {
      final notifier = container.read(gameProvider.notifier);

      // Set up pre-reincarnation state
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        completedResearch: {'divine_architecture_1', 'essence_refinement'},
        unlockedAchievements: {'cats_100', 'cats_1k'},
        buildings: {BuildingType.smallShrine: 10},
        resources: {ResourceType.cats: 50000000},
      );

      // Reincarnate
      notifier.reincarnate(PrimordialForce.chaos);

      // Verify reset
      expect(notifier.state.getResource(ResourceType.cats), 0);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 0);

      // Verify persistence
      expect(notifier.state.completedResearch.length, 2);
      expect(notifier.state.unlockedAchievements.length, 2);
      expect(notifier.state.reincarnationState.reincarnationCount, 1);
      expect(notifier.state.reincarnationState.availablePrimordialEssence, 20);
      expect(
          notifier.state.reincarnationState.currentPatron, PrimordialForce.chaos);
    });

    test('Patron bonuses apply correctly after reincarnation', () {
      final notifier = container.read(gameProvider.notifier);

      // Buy Chaos I (costs 10 PE, gives +10% click)
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 20,
        ),
      );

      notifier.purchasePrimordialUpgrade('chaos_1');
      notifier.reincarnate(PrimordialForce.chaos);

      // Chaos I: +10% permanent
      // Chaos patron with 1 tier: +50% + 10% = 60%
      // Total: 1.7x
      expect(notifier.getClickPowerMultiplier(), closeTo(1.7, 0.01));

      notifier.performRitual();
      expect(notifier.state.getResource(ResourceType.cats), closeTo(1.7, 0.01));
    });

    test('Multiple reincarnations accumulate PE correctly', () {
      final notifier = container.read(gameProvider.notifier);

      // First reincarnation at 1B cats
      notifier.state = notifier.state.copyWith(totalCatsEarned: 1000000000);
      notifier.reincarnate(PrimordialForce.chaos);
      expect(notifier.state.reincarnationState.totalPrimordialEssence, 20);

      // Second reincarnation at 5B cats
      notifier.state = notifier.state.copyWith(totalCatsEarned: 5000000000);
      notifier.reincarnate(PrimordialForce.gaia);
      expect(notifier.state.reincarnationState.totalPrimordialEssence, 47); // 20 + 27
    });

    test('Upgrade prerequisite chain works across tiers', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 500,
        ),
      );

      // Can buy tier 1
      expect(notifier.canPurchasePrimordialUpgrade('chaos_1'), true);

      // Cannot buy tier 2 yet
      expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), false);

      // Buy tier 1
      notifier.purchasePrimordialUpgrade('chaos_1');

      // Now can buy tier 2
      expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), true);

      // Buy tier 2
      notifier.purchasePrimordialUpgrade('chaos_2');

      // Now can buy tier 3
      expect(notifier.canPurchasePrimordialUpgrade('chaos_3'), true);
    });

    test('Gaia cost reduction applies to building purchases', () {
      final notifier = container.read(gameProvider.notifier);

      // Buy Gaia III and IV for -15% cost
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.cats: 1000},
        reincarnationState: const ReincarnationState(
          purchasedUpgrades: {'gaia_3', 'gaia_4'},
        ),
      );

      // Small shrine costs 15 cats normally, -15% = 12.75
      notifier.buyBuilding(BuildingType.smallShrine);

      // Should have spent 12.75 cats
      expect(
          notifier.state.getResource(ResourceType.cats), closeTo(987.25, 0.1));
    });

    test('All 4 forces can be maxed independently', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 2000, // Enough for everything
        ),
      );

      // Max Chaos tree (385 PE total)
      notifier.purchasePrimordialUpgrade('chaos_1');
      notifier.purchasePrimordialUpgrade('chaos_2');
      notifier.purchasePrimordialUpgrade('chaos_3');
      notifier.purchasePrimordialUpgrade('chaos_4');
      notifier.purchasePrimordialUpgrade('chaos_5');

      expect(notifier.state.getPrimordialTier(PrimordialForce.chaos), 5);
      expect(notifier.state.reincarnationState.availablePrimordialEssence,
          2000 - 385);

      // Max Gaia tree
      notifier.purchasePrimordialUpgrade('gaia_1');
      notifier.purchasePrimordialUpgrade('gaia_2');
      notifier.purchasePrimordialUpgrade('gaia_3');
      notifier.purchasePrimordialUpgrade('gaia_4');
      notifier.purchasePrimordialUpgrade('gaia_5');

      expect(notifier.state.getPrimordialTier(PrimordialForce.gaia), 5);
    });

    test('Tier 5 upgrades increase PE earnings', () {
      final notifier = container.read(gameProvider.notifier);

      // With no tier 5 upgrades
      expect(notifier.calculatePrimordialEssence(1000000000), 20);

      // With all 4 tier 5 upgrades (+40% PE)
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          purchasedUpgrades: {'chaos_5', 'gaia_5', 'nyx_5', 'erebus_5'},
        ),
      );

      expect(notifier.calculatePrimordialEssence(1000000000), 28); // 20 * 1.4
    });

    test('Nyx upgrades increase offline cap', () {
      final notifier = container.read(gameProvider.notifier);

      // Default cap is 24 hours
      expect(notifier.getOfflineCapHours(), 24);

      // With Nyx III
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          purchasedUpgrades: {'nyx_3'},
        ),
      );
      expect(notifier.getOfflineCapHours(), 48);

      // With Nyx IV
      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          purchasedUpgrades: {'nyx_4'},
        ),
      );
      expect(notifier.getOfflineCapHours(), 72);
    });

    test('Erebus bonuses apply to Tier 2 resources only', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        reincarnationState: const ReincarnationState(
          purchasedUpgrades: {'erebus_1', 'erebus_2'}, // +45% tier 2
          currentPatron: PrimordialForce.erebus, // +70% tier 2
        ),
      );

      // Tier 2 multiplier should be 2.15x (1.0 + 0.45 + 0.7)
      expect(notifier.getTier2ProductionMultiplier(), closeTo(2.15, 0.01));

      // Regular building multiplier should be 1.0 (no Gaia bonuses)
      expect(notifier.getBuildingProductionMultiplier(), 1.0);
    });
  });
}
```

**Step 2: Run integration tests**

Run: `flutter test test/phase4_integration_test.dart`

Expected: All 10 integration tests pass

**Step 3: Commit**

```bash
git add test/phase4_integration_test.dart
git commit -m "test: add comprehensive Phase 4 integration tests"
```

---

## Task 12: Run Full Test Suite

**Files:**
- None (verification step)

**Step 1: Run all tests**

Run: `flutter test`

Expected: All 116+ existing tests + ~50 new Phase 4 tests pass

**Step 2: Run analyzer**

Run: `flutter analyze`

Expected: No issues found

**Step 3: Verify test coverage**

Run: `flutter test --coverage`

Expected: Good coverage of Phase 4 logic

**Step 4: Create checkpoint commit**

```bash
git add .
git commit -m "milestone: Phase 4 backend complete - all tests passing"
```

---

## Next Steps (Not in this plan)

The UI implementation (Reincarnation screen, force cards, upgrade buttons) will be in a separate plan. This plan focused on:

✅ Data models (PrimordialForce, PrimordialUpgrade, ReincarnationState)
✅ GameState integration with serialization
✅ Business logic (PE calculation, bonuses, reincarnation)
✅ Production integration (click power, building multipliers, cost reduction)
✅ Comprehensive test coverage

**To execute this plan:** Use superpowers:executing-plans in batches of 3 tasks with review checkpoints.
