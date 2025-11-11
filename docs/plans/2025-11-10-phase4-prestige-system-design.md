# Phase 4: Prestige System - Design Document

**Date:** 2025-11-10
**Status:** Design Complete
**Timeline Estimate:** 4-6 weeks

## Overview

Phase 4 introduces the reincarnation/prestige system, allowing players to reset their progress in exchange for Primordial Essence (PE) to unlock permanent upgrades. This creates a meta-progression loop that extends the game's longevity and provides meaningful long-term goals.

### Core Features

- **Reincarnation Mechanic**: Reset progress at 1B+ cats to gain Primordial Essence
- **4 Primordial Forces**: Chaos, Gaia, Nyx, Erebus - each with unique upgrade trees
- **Linear Skill Trees**: 5 upgrades per force (385 PE to max one tree)
- **Patron System**: Choose an active force each run for temporary bonuses
- **Persistence**: Research and achievements carry through reincarnation
- **Dedicated UI**: New Reincarnation tab for managing prestige systems

### Design Principles

- **Late-game unlock** (1B cats) ensures players experience all Phase 3 content first
- **Moderate rewards** provide meaningful progression without trivializing runs
- **Strategic depth** through permanent investments + per-run patron choices
- **Clear identity** for each force aligned with different playstyles

---

## 1. Core Mechanic: Reincarnation

### Unlock Requirement

**Trigger:** Reach 1,000,000,000 (1 billion) total cats earned across the current run

**First-Time Experience:**
- When player crosses 1B total cats, show notification: "You sense the Primordial Forces stirring... A new tab has appeared."
- Reincarnation tab unlocks in bottom navigation (6th tab)
- Tab is visible but displays current run stats and available PE preview

### What Happens on Reincarnation

**Reset (Lost):**
- All resources set to 0
- All buildings removed
- All gods reset to just Hermes (starting god)
- All conquered territories lost
- Total cats earned this run resets to 0

**Persist (Kept):**
- All completed research nodes remain unlocked
- All achievements remain unlocked and bonuses active
- All purchased Primordial upgrades remain active
- Reincarnation count increments
- Total cats earned across ALL runs (lifetime stat)

**Gain:**
- Primordial Essence based on total cats earned this run
- Ability to choose a new patron for next run

### Primordial Essence Formula

```
PE = floor(log10(totalCats) - 8) * 10
```

**Examples:**
- 1,000,000,000 cats (1B, minimum) = 20 PE
- 10,000,000,000 cats (10B) = 30 PE
- 100,000,000,000 cats (100B) = 40 PE
- 1,000,000,000,000 cats (1T) = 50 PE

**Rationale:** Logarithmic scaling rewards pushing further without exponential power creep. Each order of magnitude (10x cats) adds 10 PE. Players can also earn bonus PE from tier 5 upgrades (+10% PE per maxed tree).

### Reincarnation Process

1. Player reaches 1B+ cats and opens Reincarnation tab
2. Reviews current PE calculation and available upgrades
3. Chooses patron for next run from dropdown
4. Clicks "Reincarnate" button
5. Confirmation dialog appears with summary
6. On confirm, GameState resets with PE added and patron selected
7. Game returns to initial state (Hermes unlocked, 0 resources)
8. Permanent bonuses and patron bonuses immediately active

---

## 2. Primordial Forces & Skill Trees

### The Four Forces

Each Primordial Force represents a different playstyle and provides permanent upgrades through a linear 5-tier skill tree.

**1. Chaos - Active Play Bonuses**
- Theme: Raw power, randomness, active engagement
- Primary Bonus: Click power (cats per ritual)
- Secondary: Random events (Phase 5 hook)

**2. Gaia - Building & Production Bonuses**
- Theme: Growth, efficiency, passive income
- Primary Bonus: Building production rates
- Secondary: Building cost reduction

**3. Nyx - Offline & Time Bonuses**
- Theme: Patience, time, darkness
- Primary Bonus: Offline progression rate
- Secondary: Extended offline cap duration

**4. Erebus - Resource & Essence Bonuses**
- Theme: Wealth, rarity, divine resources
- Primary Bonus: Tier 2 resource production (Divine Essence, Ambrosia)
- Secondary: Meta-progression (PE gain)

### Skill Tree Structure

Each force has **5 upgrades in a linear path**. Must purchase in order (can't buy tier 3 without tier 2).

**Cost Progression:**
- Tier 1: 10 PE
- Tier 2: 25 PE
- Tier 3: 50 PE
- Tier 4: 100 PE
- Tier 5: 200 PE
- **Total to max one tree: 385 PE**

**Estimated Timeline:**
- Run 1 (1B cats): 20 PE → Buy tier 1-2 of one force
- Run 2 (5B cats): 27 PE → Buy tier 3
- Run 3 (20B cats): 33 PE → Buy tier 4
- Run 4 (100B cats): 40 PE → Buy tier 5
- Runs 5-12: Max other trees or diversify

### Chaos Skill Tree

**Chaos I** (10 PE)
- Effect: +10% click power
- Description: "Channel the primal chaos to empower your rituals"

**Chaos II** (25 PE)
- Effect: +25% click power
- Description: "Embrace disorder and multiply your divine influence"

**Chaos III** (50 PE)
- Effect: +50% click power, unlock random events
- Description: "Chaos breeds opportunity - rare events may now occur"
- Note: Random events are placeholder for Phase 5 expansion

**Chaos IV** (100 PE)
- Effect: +100% click power
- Description: "Your rituals tear through the fabric of reality"

**Chaos V** (200 PE)
- Effect: +150% click power, +10% Primordial Essence earned
- Description: "Master of Chaos - your power knows no bounds"

### Gaia Skill Tree

**Gaia I** (10 PE)
- Effect: +10% building production (all resources)
- Description: "Gaia blesses your structures with abundant growth"

**Gaia II** (25 PE)
- Effect: +25% building production
- Description: "The earth itself works in your favor"

**Gaia III** (50 PE)
- Effect: +50% building production, -10% building costs
- Description: "Gaia provides both bounty and efficiency"

**Gaia IV** (100 PE)
- Effect: +100% building production, -15% building costs
- Description: "Your domain flourishes like never before"

**Gaia V** (200 PE)
- Effect: +150% building production, +10% Primordial Essence earned
- Description: "Embodiment of Growth - Gaia's ultimate champion"

### Nyx Skill Tree

**Nyx I** (10 PE)
- Effect: +25% offline progression rate
- Description: "Nyx watches over you during the long night"

**Nyx II** (25 PE)
- Effect: +50% offline progression rate
- Description: "Time works faster in the realm of darkness"

**Nyx III** (50 PE)
- Effect: +100% offline progression rate, extend offline cap to 48 hours
- Description: "Two days pass in the blink of an eye"

**Nyx IV** (100 PE)
- Effect: +150% offline progression rate, extend offline cap to 72 hours
- Description: "Three full days of progress await your return"

**Nyx V** (200 PE)
- Effect: +200% offline progression rate, +10% Primordial Essence earned
- Description: "Master of Night - time itself bends to your will"

### Erebus Skill Tree

**Erebus I** (10 PE)
- Effect: +15% Divine Essence production
- Description: "Erebus reveals the secrets of divine power"

**Erebus II** (25 PE)
- Effect: +30% Divine Essence production, +15% Ambrosia production
- Description: "Darkness enriches the rarest resources"

**Erebus III** (50 PE)
- Effect: +50% Divine Essence production, +30% Ambrosia production
- Description: "The primordial darkness overflows with treasure"

**Erebus IV** (100 PE)
- Effect: +75% all Tier 2 resource production
- Description: "Command the flow of divine wealth"

**Erebus V** (200 PE)
- Effect: +100% all Tier 2 resource production, +10% Primordial Essence earned
- Description: "Lord of Darkness - wealth beyond mortal comprehension"

### Bonus Stacking

All permanent bonuses are **additive** with each other and with achievement bonuses.

**Example:**
- Achievement bonuses: +4% (8 achievements × 0.5%)
- Chaos I-V: +335% click power total (10+25+50+100+150)
- **Total click power multiplier: 4.39x**

Building production with Gaia V + achievements:
- Achievement bonuses: +4%
- Gaia I-V: +335% production
- **Total production multiplier: 4.39x**

---

## 3. Patron System

### Choosing a Patron

At the start of each run (including reincarnation), players choose one Primordial Force as their **patron**. This provides a temporary bonus for the entire run.

**When Selection Happens:**
- Before first reincarnation: Patron selection screen appears on first game load (default: Chaos)
- After reincarnation: Patron dropdown on Reincarnation tab before confirming
- Can change patron only by reincarnating again

### Patron Bonus Calculation

**Base Bonus:** +50% to the force's primary specialty

**Scaling with Investment:** +10% additional bonus per upgrade purchased in that force's tree

**Formula:**
```
Patron Bonus = 50% + (10% × upgrades_purchased_in_force)
```

**Examples:**
- No Chaos upgrades + Chaos patron = +50% click power
- Chaos I-III purchased (3 upgrades) + Chaos patron = +80% click power (50% + 30%)
- Chaos I-V maxed (5 upgrades) + Chaos patron = +100% click power (50% + 50%)

### Patron Bonuses by Force

**Chaos Patron:**
- Bonus: +(50% + 10% per upgrade) click power
- Stacks multiplicatively with permanent Chaos upgrades
- Best for: Active players who click frequently

**Gaia Patron:**
- Bonus: +(50% + 10% per upgrade) building production
- Applies to all resource types produced by buildings
- Best for: Idle players, long sessions

**Nyx Patron:**
- Bonus: +(50% + 10% per upgrade) offline progression rate
- Stacks with permanent Nyx upgrades
- Best for: Players who play in short bursts

**Erebus Patron:**
- Bonus: +(50% + 10% per upgrade) Tier 2 resource production
- Applies to Divine Essence and Ambrosia only
- Best for: Late-game pushes, workshop-heavy strategies

### Strategic Depth

**Early Runs:** Players typically specialize (buy Chaos I-III, always choose Chaos patron for +80% click power)

**Mid Runs:** Diversification begins (spread PE across multiple trees, choose patron based on current goal)

**Late Runs:** All trees maxed (patron choice becomes pure strategy - pick Chaos for active push, Nyx for offline stretch, etc.)

### UI Display

**On Home Screen:**
- Display current patron near god progression: "⚡ Chaos Patron (+80% click power)"

**On Reincarnation Screen:**
- Dropdown selector: "Choose your patron for next run: [Chaos ▼]"
- Preview text updates: "Chaos Patron: +80% click power (50% base + 30% from 3 upgrades)"

---

## 4. UI & User Experience

### Reincarnation Tab Layout

The Reincarnation tab becomes the 6th tab in bottom navigation, unlocking when player reaches 1B total cats.

#### Top Section: Current Run Stats

Display in a card/panel:
- **Total Cats Earned This Run:** [formatted number]
- **Primordial Essence Gained:** [calculated PE]
  - Show calculation: "20 PE (base) + 2 PE (+10% from maxed trees) = 22 PE"
- **Current Patron:** [Force icon + name]
- **Reincarnation Count:** "Reincarnation #[number]"

#### Middle Section: Four Skill Trees

**Layout:**
- Mobile: Horizontal scrollable row of 4 force cards
- Desktop: 2×2 grid of force cards

**Each Force Card Contains:**
- **Header:** Force name + icon + theme description
- **Available PE Display:** Shared across all cards at very top
- **5 Upgrade Cards** in vertical list:
  - Tier badge (I, II, III, IV, V)
  - Upgrade name
  - Cost (e.g., "10 PE" or "PURCHASED" if owned)
  - Effect description
  - Lock icon if not yet purchasable (insufficient PE or missing prerequisite)
  - Checkmark/unlock icon if already purchased
- **Progress Indicator:** "3/5 upgrades purchased"

**Color Scheme by Force:**
- Chaos: Red/orange (fire, energy)
- Gaia: Green/brown (earth, growth)
- Nyx: Purple/dark blue (night, mystery)
- Erebus: Black/gold (darkness, wealth)

#### Bottom Section: Reincarnation Controls

**Patron Selection:**
- Dropdown: "Choose your patron for next run: [Chaos ▼]"
- Options: Chaos, Gaia, Nyx, Erebus
- Preview text below: "Chaos Patron: +80% click power"

**Reincarnate Button:**
- Large, prominent, red button
- Text: "Reincarnate" or "Begin New Cycle"
- Disabled if below 1B cats threshold
- Helper text below: "You will keep: Research, Achievements | You will lose: Resources, Buildings, Gods, Territories"

**Confirmation Dialog:**
```
⚠️ Reincarnate?

You will gain 25 Primordial Essence.
Your chosen patron is Chaos.

You will lose all resources, buildings, gods, and territories.
You will keep all research and achievements.

This cannot be undone.

[Cancel] [Reincarnate]
```

### Other UI Changes

**Settings Screen (Statistics Section):**
Add:
- Total Reincarnations: [number]
- Primordial Essence Earned (Lifetime): [number]
- Primordial Essence Available: [number]
- Current Patron: [Force name]

**Home Screen:**
Display current patron badge near god progression or resource panel:
- "⚡ Chaos Patron" with hover tooltip showing bonus

**Bottom Navigation:**
- Add 6th tab icon for Reincarnation (locked/grayed until 1B cats)
- Icon suggestion: ♾️ or 🔄 (infinity or cycle symbol)

---

## 5. Technical Implementation

### New Models

**PrimordialForce enum** (`lib/models/primordial_force.dart`)
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

**PrimordialUpgrade class** (`lib/models/primordial_upgrade.dart`)
```dart
class PrimordialUpgrade {
  final String id; // e.g., "chaos_1"
  final PrimordialForce force;
  final int tier; // 1-5
  final int cost; // PE cost
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

**PrimordialUpgradeDefinitions** (`lib/models/primordial_upgrade_definitions.dart`)
```dart
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

  // ... all 20 upgrades defined as constants

  static List<PrimordialUpgrade> getForceUpgrades(PrimordialForce force) {
    return all.where((u) => u.force == force).toList()..sort((a, b) => a.tier.compareTo(b.tier));
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

**ReincarnationState class** (`lib/models/reincarnation_state.dart`)
```dart
class ReincarnationState {
  final int reincarnationCount;
  final int totalPrimordialEssence; // lifetime earned
  final int availablePrimordialEssence; // unspent
  final Set<String> purchasedUpgrades; // upgrade IDs
  final PrimordialForce? currentPatron;
  final double totalCatsAllTime; // across all runs

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
          .toSet() ?? {},
      currentPatron: json['currentPatron'] != null
          ? PrimordialForce.values.firstWhere((f) => f.name == json['currentPatron'])
          : null,
      totalCatsAllTime: (json['totalCatsAllTime'] as num?)?.toDouble() ?? 0,
    );
  }
}
```

### GameState Modifications

**Update `lib/models/game_state.dart`:**

Add field:
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
  this.reincarnationState = const ReincarnationState(), // NEW
});
```

Update `initial()`:
```dart
factory GameState.initial() {
  return GameState(
    resources: {...},
    buildings: {},
    unlockedGods: {God.hermes},
    lastUpdate: DateTime.now(),
    totalCatsEarned: 0,
    unlockedAchievements: {},
    completedResearch: {},
    conqueredTerritories: {},
    reincarnationState: const ReincarnationState(), // NEW
  );
}
```

Update `copyWith()`:
```dart
GameState copyWith({
  // ... existing parameters
  ReincarnationState? reincarnationState,
}) {
  return GameState(
    // ... existing fields
    reincarnationState: reincarnationState ?? this.reincarnationState,
  );
}
```

Update JSON serialization:
```dart
Map<String, dynamic> toJson() {
  return {
    // ... existing fields
    'reincarnationState': reincarnationState.toJson(),
  };
}

factory GameState.fromJson(Map<String, dynamic> json) {
  return GameState(
    // ... existing fields
    reincarnationState: json['reincarnationState'] != null
        ? ReincarnationState.fromJson(json['reincarnationState'])
        : const ReincarnationState(),
  );
}
```

Add helper methods:
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

### GameNotifier Updates

**Modify `lib/providers/game_provider.dart`:**

Add PE calculation:
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

Add bonus calculation helpers:
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

  // Existing conquest bonuses
  for (final territoryId in state.conqueredTerritories) {
    final territory = ConquestDefinitions.getById(territoryId);
    if (territory != null) {
      multiplier += territory.productionBonus;
    }
  }

  return multiplier;
}

/// Get building cost reduction from Gaia upgrades
double getBuildingCostReduction() {
  double reduction = 0;
  if (state.hasPrimordialUpgrade('gaia_3')) reduction += 0.10;
  if (state.hasPrimordialUpgrade('gaia_4')) reduction += 0.15;
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

Update production methods:
```dart
void performRitual() {
  final newResources = Map<ResourceType, double>.from(state.resources);

  final clickMultiplier = getClickPowerMultiplier();
  newResources[ResourceType.cats] = state.getResource(ResourceType.cats) + clickMultiplier;

  state = state.copyWith(
    resources: newResources,
    totalCatsEarned: state.totalCatsEarned + clickMultiplier,
  );

  _checkGodUnlocks();
  _checkAchievements();
}

void _updateGame(double deltaSeconds) {
  // Calculate production with Gaia bonuses
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
  if (catsProduced > 0 || offeringsProduced > 0 || prayersProduced > 0 ||
      divineEssenceProduced > 0 || ambrosiaProduced > 0) {
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
    if (divineEssenceProduced > 0) {
      newResources[ResourceType.divineEssence] = state.getResource(ResourceType.divineEssence) + divineEssenceProduced;
    }
    if (ambrosiaProduced > 0) {
      newResources[ResourceType.ambrosia] = state.getResource(ResourceType.ambrosia) + ambrosiaProduced;
    }

    state = state.copyWith(
      resources: newResources,
      totalCatsEarned: state.totalCatsEarned + catsProduced,
      lastUpdate: DateTime.now(),
    );

    _checkGodUnlocks();
  }
}

void applyOfflineProgress() {
  final now = DateTime.now();
  final lastUpdate = state.lastUpdate;
  final secondsElapsed = now.difference(lastUpdate).inSeconds;

  if (secondsElapsed < 1) return;

  final offlineMultiplier = getOfflineProgressionMultiplier();
  final capHours = getOfflineCapHours();
  final cappedSeconds = min(secondsElapsed, capHours * 3600);
  final effectiveSeconds = cappedSeconds * offlineMultiplier;

  // Calculate production for offline period
  _updateGame(effectiveSeconds.toDouble());

  // Show offline progress dialog if > 60 seconds
  if (secondsElapsed >= 60) {
    // Trigger dialog (implementation depends on UI layer)
  }
}

bool buyBuilding(BuildingType type, {int amount = 1}) {
  // ... existing affordability checks ...

  // Apply cost reduction from Gaia
  final costReduction = getBuildingCostReduction();
  final effectiveCost = totalCost.map((resource, cost) =>
    MapEntry(resource, cost * (1 - costReduction))
  );

  // ... rest of existing logic using effectiveCost ...
}
```

Add reincarnation method:
```dart
void reincarnate(PrimordialForce chosenPatron) {
  // Calculate PE earned
  final peEarned = calculatePrimordialEssence(state.totalCatsEarned);

  // Store persistent data
  final persistedResearch = Set<String>.from(state.completedResearch);
  final persistedAchievements = Set<String>.from(state.unlockedAchievements);
  final persistedUpgrades = Set<String>.from(state.reincarnationState.purchasedUpgrades);

  // Reset to initial state but keep reincarnation progress
  state = GameState.initial().copyWith(
    completedResearch: persistedResearch,
    unlockedAchievements: persistedAchievements,
    reincarnationState: ReincarnationState(
      reincarnationCount: state.reincarnationState.reincarnationCount + 1,
      totalPrimordialEssence: state.reincarnationState.totalPrimordialEssence + peEarned,
      availablePrimordialEssence: state.reincarnationState.availablePrimordialEssence + peEarned,
      purchasedUpgrades: persistedUpgrades,
      currentPatron: chosenPatron,
      totalCatsAllTime: state.reincarnationState.totalCatsAllTime + state.totalCatsEarned,
    ),
  );

  // Save immediately
  SaveService.save(state);
}

bool canPurchasePrimordialUpgrade(String upgradeId) {
  final upgrade = PrimordialUpgradeDefinitions.getById(upgradeId);
  if (upgrade == null) return false;

  // Already purchased
  if (state.hasPrimordialUpgrade(upgradeId)) return false;

  // Check PE cost
  if (state.reincarnationState.availablePrimordialEssence < upgrade.cost) return false;

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

  final newUpgrades = Set<String>.from(state.reincarnationState.purchasedUpgrades)..add(upgradeId);

  state = state.copyWith(
    reincarnationState: state.reincarnationState.copyWith(
      availablePrimordialEssence: state.reincarnationState.availablePrimordialEssence - upgrade.cost,
      purchasedUpgrades: newUpgrades,
    ),
  );
}
```

### UI Implementation

**Create `lib/screens/reincarnation_screen.dart`:**

Main reincarnation screen with tabs layout similar to existing screens.

**Create `lib/widgets/primordial_force_card.dart`:**

Card widget displaying one force's skill tree with upgrade purchase buttons.

**Create `lib/widgets/primordial_upgrade_card.dart`:**

Individual upgrade display with tier badge, cost, effect, and purchase/locked state.

**Modify `lib/screens/home_screen.dart`:**

Add 6th tab to bottom navigation for Reincarnation (conditionally visible when `state.canReincarnate()`).

**Modify `lib/screens/settings_screen.dart`:**

Add reincarnation stats to statistics section.

---

## 6. Testing & Balance

### Unit Tests

**Test Files to Create:**
- `test/models/primordial_upgrade_test.dart`
- `test/models/reincarnation_state_test.dart`
- `test/providers/reincarnation_logic_test.dart`

**Test Cases:**

**PE Calculation:**
```dart
test('calculatePrimordialEssence returns correct values', () {
  expect(calculatePrimordialEssence(1000000000), 20);  // 1B
  expect(calculatePrimordialEssence(10000000000), 30); // 10B
  expect(calculatePrimordialEssence(100000000000), 40); // 100B
  expect(calculatePrimordialEssence(500000000), 0); // below threshold
});

test('PE bonuses from tier 5 upgrades apply correctly', () {
  // With all 4 tier 5 upgrades (+40% PE)
  expect(calculatePrimordialEssence(1000000000), 28); // 20 * 1.4
});
```

**Reincarnation State:**
```dart
test('ReincarnationState serializes correctly', () {
  final state = ReincarnationState(
    reincarnationCount: 3,
    totalPrimordialEssence: 100,
    availablePrimordialEssence: 25,
    purchasedUpgrades: {'chaos_1', 'gaia_1'},
    currentPatron: PrimordialForce.chaos,
    totalCatsAllTime: 5000000000,
  );

  final json = state.toJson();
  final restored = ReincarnationState.fromJson(json);

  expect(restored.reincarnationCount, 3);
  expect(restored.purchasedUpgrades.contains('chaos_1'), true);
  expect(restored.currentPatron, PrimordialForce.chaos);
});
```

**Bonus Calculations:**
```dart
test('Chaos bonuses stack correctly', () {
  // Chaos I-III + Chaos patron with 3 upgrades
  // Permanent: 10% + 25% + 50% = 85%
  // Patron: 50% + 30% = 80%
  // Total: 1.85x
  expect(getClickPowerMultiplier(), closeTo(2.65, 0.01));
});

test('Gaia cost reduction applies', () {
  // Gaia III: -10%, Gaia IV: -15%
  expect(getBuildingCostReduction(), 0.15);

  final baseCost = 100;
  final reducedCost = baseCost * (1 - 0.15);
  expect(reducedCost, 85);
});
```

**Upgrade Prerequisites:**
```dart
test('cannot buy tier 2 without tier 1', () {
  final notifier = GameNotifier();
  notifier.state = notifier.state.copyWith(
    reincarnationState: ReincarnationState(availablePrimordialEssence: 100),
  );

  expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), false);
});

test('can buy tier 2 with tier 1 owned', () {
  final notifier = GameNotifier();
  notifier.state = notifier.state.copyWith(
    reincarnationState: ReincarnationState(
      availablePrimordialEssence: 100,
      purchasedUpgrades: {'chaos_1'},
    ),
  );

  expect(notifier.canPurchasePrimordialUpgrade('chaos_2'), true);
});
```

### Integration Tests

**Create `test/phase4_integration_test.dart`:**

```dart
test('Full reincarnation cycle preserves research and achievements', () {
  final notifier = GameNotifier();

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
  expect(notifier.state.unlockedGods.length, 1); // Just Hermes

  // Verify persistence
  expect(notifier.state.completedResearch.length, 2);
  expect(notifier.state.unlockedAchievements.length, 2);
  expect(notifier.state.reincarnationState.reincarnationCount, 1);
  expect(notifier.state.reincarnationState.availablePrimordialEssence, 20);
  expect(notifier.state.reincarnationState.currentPatron, PrimordialForce.chaos);
});

test('Patron bonuses apply correctly after reincarnation', () {
  final notifier = GameNotifier();

  // Buy Chaos I, reincarnate with Chaos patron
  notifier.state = notifier.state.copyWith(
    totalCatsEarned: 1000000000,
    reincarnationState: ReincarnationState(
      availablePrimordialEssence: 20,
    ),
  );

  notifier.purchasePrimordialUpgrade('chaos_1');
  notifier.reincarnate(PrimordialForce.chaos);

  // Chaos I: +10% permanent, Chaos patron with 1 upgrade: +60%
  // Total: 1.7x
  expect(notifier.getClickPowerMultiplier(), closeTo(1.7, 0.01));

  notifier.performRitual();
  expect(notifier.state.getResource(ResourceType.cats), closeTo(1.7, 0.01));
});

test('Multiple reincarnations accumulate PE correctly', () {
  final notifier = GameNotifier();

  // First reincarnation at 1B cats
  notifier.state = notifier.state.copyWith(totalCatsEarned: 1000000000);
  notifier.reincarnate(PrimordialForce.chaos);
  expect(notifier.state.reincarnationState.totalPrimordialEssence, 20);

  // Second reincarnation at 5B cats
  notifier.state = notifier.state.copyWith(totalCatsEarned: 5000000000);
  notifier.reincarnate(PrimordialForce.gaia);
  expect(notifier.state.reincarnationState.totalPrimordialEssence, 47); // 20 + 27
});
```

### Manual Testing Checklist

- [ ] Reach 1B cats and verify reincarnation tab unlocks
- [ ] View PE calculator and verify formula accuracy
- [ ] Purchase upgrades from all 4 forces
- [ ] Verify prerequisite locking (can't buy tier 2 without tier 1)
- [ ] Choose Chaos patron and reincarnate
- [ ] Verify resources/buildings/gods reset
- [ ] Verify research and achievements persist
- [ ] Verify Chaos patron bonus applies to clicks
- [ ] Reach 1B cats again with different patron choice
- [ ] Second reincarnation with accumulated PE
- [ ] Buy tier 5 upgrade and verify +10% PE bonus on next run
- [ ] Test Gaia patron with building production
- [ ] Test Nyx patron with offline progression
- [ ] Test Erebus patron with Divine Essence production
- [ ] Verify save/load preserves reincarnation state
- [ ] Test on mobile (touch interactions, scrolling)

### Balance Considerations

**PE Economy:**
- Run 1 (1B): 20 PE → Can buy tier 1-2 of one force
- Run 2 (5B): 27 PE → Can buy tier 3
- Run 3 (20B): 33 PE → Can buy tier 4
- Run 4 (100B): 40 PE → Can buy tier 5, max first tree
- Runs 5-12: ~300 PE total → Max remaining trees

**Power Curve:**
- With maxed Chaos tree + Chaos patron: 4.35x click power
- With maxed Gaia tree + Gaia patron: 4.35x building production
- This 4x multiplier is significant but doesn't trivialize progression
- Stacks with achievements (+4%) for ~4.5x total

**Unlock Timing:**
- 1B cats requires extensive Phase 3 play (research + conquest)
- Ensures players see all systems before resetting
- First reincarnation feels like major milestone, not rushed

---

## 7. Implementation Plan Reference

This design document serves as the foundation for creating a detailed implementation plan. The recommended approach:

1. **Use superpowers:writing-plans skill** to create step-by-step tasks
2. **Use superpowers:subagent-driven-development** to execute with quality gates
3. **Follow TDD** for all new models and logic
4. **Test integration** with existing Phase 3 systems

Estimated implementation: **10-12 tasks, 4-6 weeks**

---

## Summary

Phase 4 adds a deep prestige system that extends game longevity through meaningful resets and permanent progression. The hybrid patron system creates both long-term investment (skill trees) and per-run strategy (patron choice), while the late-game unlock ensures players experience all current content before resetting.

**Key Features:**
✅ Reincarnation at 1B cats with PE rewards
✅ 4 Primordial Forces with distinct identities
✅ 20 total upgrades (5 per force, linear trees)
✅ Scaling patron bonuses (base 50% + tier investment)
✅ Research and achievements persist
✅ Dedicated Reincarnation tab UI
✅ Full integration with existing bonus systems

The system is designed for:
- **Accessibility**: Clear unlock, straightforward progression
- **Depth**: Strategic choices between forces and patron selection
- **Longevity**: ~12 runs to max all trees, meaningful power gains
- **Integration**: Works seamlessly with Phase 3 systems
