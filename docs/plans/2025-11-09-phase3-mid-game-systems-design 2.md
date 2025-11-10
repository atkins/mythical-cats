# Phase 3: Mid-Game Systems - Design Document

**Date:** 2025-11-09
**Status:** Design Complete
**Timeline Estimate:** 6-8 weeks

## Overview

Phase 3 transforms the game from early-game idle mechanics into a deep mid-game experience with strategic choices, active engagement opportunities, and meaningful progression systems.

### Core Additions

- **Tech Tree System**: Two complete branches (Foundation, Resource) with 8 research nodes providing permanent upgrades
- **Gods 5-8**: Athena (1M cats), Apollo (10M), Artemis (100M), Ares (1B) - each with unique mechanics
- **Tier 2 Resources**: Divine Essence and Ambrosia production and consumption
- **New Buildings**: Academy, Essence Refinery, Nectar Brewery, Workshop, War Monument
- **God-Specific Mechanics**:
  - Athena: Tech tree system + Academy buildings + Divine Essence
  - Apollo: Oracle screen with production forecasts and milestone predictions
  - Artemis: Target hunting mini-game for bonus resources
  - Ares: Building-based conquest system generating territory bonuses

### Design Principles

- Research provides permanent unlocks (persists through future reincarnation)
- God mechanics add variety without fragmenting core idle loop
- All systems integrate with existing resource/building framework
- Mobile-first UI for all new screens

---

## Tech Tree System

### Data Model

Each research node contains:

```dart
class ResearchNode {
  final String id;              // e.g., "divine_architecture_1"
  final String name;            // e.g., "Divine Architecture I"
  final String description;     // What it unlocks/provides
  final ResearchBranch branch;  // Category
  final Map<ResourceType, double> cost;  // Resources required
  final List<String> prerequisites;      // Node IDs that must be completed first
  final ResearchEffect effect;  // What changes when unlocked
}

enum ResearchBranch {
  foundation,
  resource,
  automation,
  godFavor,
  advanced,
}

enum ResearchEffect {
  unlockBuilding,      // Enables new building type
  productionMultiplier, // Increases production by X%
  unlockResource,      // Enables new resource
  costReduction,       // Reduces building costs
}
```

### Foundation Branch Nodes

1. **Divine Architecture I**
   - Cost: 5,000 cats, 1,000 prayers
   - Effect: Unlocks next tier shrine buildings
   - Prerequisites: None

2. **Sacred Geometry**
   - Cost: 10,000 cats, 2,000 prayers
   - Effect: Required for future god-specific buildings
   - Prerequisites: Divine Architecture I

3. **Divine Architecture II**
   - Cost: 50,000 cats, 5,000 prayers
   - Effect: Unlocks higher shrine tier buildings
   - Prerequisites: Sacred Geometry

4. **Immortal Craftsmanship**
   - Cost: 100,000 cats, 10,000 prayers, 1,000 Divine Essence
   - Effect: Unlocks Workshop buildings
   - Prerequisites: Divine Architecture II

### Resource Branch Nodes

1. **Essence Refinement**
   - Cost: 25,000 cats, 5,000 prayers
   - Effect: Unlocks Divine Essence production buildings (Essence Refinery)
   - Prerequisites: None

2. **Divine Alchemy**
   - Cost: 100,000 cats, 50 Divine Essence
   - Effect: +25% resource conversion efficiency in Workshops
   - Prerequisites: Essence Refinement

3. **Nectar Brewing**
   - Cost: 500,000 cats, 500 Divine Essence
   - Effect: Unlocks Ambrosia production (Nectar Brewery)
   - Prerequisites: Divine Alchemy

4. **Ambrosia Infusion**
   - Cost: 1,000,000 cats, 100 Ambrosia
   - Effect: +50% Ambrosia production rate
   - Prerequisites: Nectar Brewing

### Storage & Persistence

- Completed research stored in `GameState.completedResearch` as `Set<String>` of node IDs
- Persists through save/load
- Never lost (permanent progression, even through reincarnation)
- Research mechanic: Instant unlock when resources paid (no time delay)

---

## Tech Tree UI - Hybrid List Approach

### Screen Structure

The Research screen is added as a new tab in the bottom navigation (visible when Athena unlocked).

### Layout Design

```
┌─────────────────────────────┐
│ Research                    │
│ ─────────────────────────── │
│ Foundation Branch          ▼│ ← Expandable section header
│   [●] Divine Architecture I │ ← Completed (filled circle)
│       └─→ [○] Sacred Geo... │ ← Available (empty circle) + indent
│            └─→ [ ] Divine...│ ← Locked (grayed) + further indent
│   [○] Sacred Geometry       │ ← Also shown in flat list
│                             │
│ Resource Branch            ▼│
│   [○] Essence Refinement    │
│       └─→ [ ] Divine Alchemy│
│   [ ] Divine Alchemy        │
│       └─→ [ ] Nectar Brewing│
│                             │
└─────────────────────────────┘
```

### Research Node Card Components

Each node displays:
- **Status Icon**: ● (completed), ○ (available), □ (locked)
- **Node Name**: Bold, primary text
- **Description**: Secondary text, describes effect
- **Cost Display**: Resource icons + amounts with affordability coloring
- **Visual Indent**: └─→ arrow showing prerequisite relationship
- **Action Button**: "Research" button (only on available, affordable nodes)

### Visual States

- **Green border**: Can afford right now
- **Amber border**: Available but can't afford yet
- **Gray**: Locked (prerequisites not met)
- **Blue glow**: Recently completed (fades after 3 seconds)

### Branch Organization

- Collapsible sections per branch
- Default: Foundation and Resource expanded, others collapsed
- Tap header to expand/collapse
- Scroll within each section for long branches

### Interaction Flow

1. Player taps available research node
2. Confirmation dialog shows cost and effect
3. Player confirms → resources deducted → research completed immediately
4. UI updates: node marked completed, dependent nodes unlock
5. Effects applied to production/unlock gating

---

## Tier 2 Resources & New Buildings

### New Resources

#### Divine Essence
- **Icon**: ✨ (sparkle/essence visual)
- **Display Name**: "Divine Essence"
- **Purpose**: Required for advanced research and god-specific buildings
- **Unlocked**: When Athena god is unlocked (1M cats)
- **Production**: Essence Refinery building

#### Ambrosia
- **Icon**: 🍯 (nectar/honey visual)
- **Display Name**: "Ambrosia"
- **Purpose**: Required for late-game research and prestige system (Phase 4)
- **Unlocked**: When Ares god is unlocked (1B cats)
- **Production**: Nectar Brewery building

#### Conquest Points
- **Icon**: ⚔️ (sword/battle visual)
- **Display Name**: "Conquest Points"
- **Purpose**: Spent to unlock territory bonuses
- **Unlocked**: When Ares god is unlocked
- **Production**: War Monument buildings

### New Buildings

#### Essence Refinery (unlocked via Essence Refinement research)
- **Type**: Resource production
- **Base Cost**: 100,000 cats, 10,000 offerings
- **Base Production**: 0.5 Divine Essence/sec
- **Cost Multiplier**: 1.20
- **God Requirement**: Athena

#### Nectar Brewery (unlocked via Nectar Brewing research)
- **Type**: Resource production
- **Base Cost**: 1,000,000 cats, 500 Divine Essence
- **Base Production**: 0.1 Ambrosia/sec
- **Cost Multiplier**: 1.25
- **God Requirement**: Ares

#### Academy (unlocked with Athena god)
- **Type**: God-specific production
- **Base Cost**: 50,000 cats, 5,000 prayers
- **Base Production**: 1.0 cats/sec
- **Cost Multiplier**: 1.15
- **God Requirement**: Athena
- **Thematic Purpose**: Centers of learning, modest production boost

#### Workshop (unlocked via Immortal Craftsmanship research)
- **Type**: Resource conversion
- **Base Cost**: 250,000 cats, 100 Divine Essence
- **Conversion**: Offerings → Divine Essence at 10:1 ratio (passive/automatic)
- **Cost Multiplier**: 1.18
- **Purpose**: Resource optimization and flexibility
- **No God Requirement** (tech tree gated)

#### War Monument (unlocked with Ares god)
- **Type**: God-specific production
- **Base Cost**: 5,000,000 cats, 1,000 Ambrosia
- **Base Production**: 1.0 Conquest Points/sec
- **Cost Multiplier**: 1.22
- **God Requirement**: Ares

---

## God-Specific Mechanics

### Athena (1M cats) - Tech Tree & Research

**Unlock Trigger**: When player earns 1,000,000 total cats

**What Unlocks**:
- Research tab appears in bottom navigation
- Academy building becomes available
- Divine Essence resource enabled
- Access to Foundation and Resource branch research nodes

**No Additional Mechanics**: Athena's value is in unlocking the entire tech tree system

---

### Apollo (10M cats) - Oracle/Prophecy System

**Unlock Trigger**: When player earns 10,000,000 total cats

**UI Addition**: "Oracle" button appears on Home screen (below ritual button)

#### Oracle Screen

```
┌─────────────────────────────┐
│ Oracle of Apollo            │
│ ─────────────────────────── │
│ Production Forecast         │
│ Next 1 min:  +2.5K cats     │
│ Next 5 min:  +12.5K cats    │
│ Next 10 min: +25K cats      │
│                             │
│ Next 1 min:  +125 offerings │
│ Next 5 min:  +625 offerings │
│ Next 10 min: +1.25K offer.  │
│                             │
│ Milestone Predictions       │
│ 100K cats    in 8 minutes   │
│ 1M cats      in 2.5 hours   │
│ 10M cats     in 1.2 days    │
│                             │
│ Next God Unlock             │
│ Artemis (100M) in 4.8 days  │
└─────────────────────────────┘
```

**Features**:
- **Production Forecast**: Shows projected gains for 1/5/10 minute windows based on current production rates
- **Milestone Predictions**: Calculates time to reach cat thresholds (100K, 1M, 10M, 100M, 1B)
- **Next God Unlock**: Shows which god unlocks next and estimated time
- **Real-Time Updates**: Recalculates when production changes
- **Purely Informational**: No gameplay mechanics, helps players plan

**Implementation**:
- Calculations based on current `catsPerSecond()` rate
- Simple math: `timeToGoal = (goal - current) / productionRate`
- Updates every second or on production change

---

### Artemis (100M cats) - Hunting Mini-Game

**Unlock Trigger**: When player earns 100,000,000 total cats

**UI Addition**: "Hunt" button appears on Home screen (cooldown timer shown)

#### Hunt Session Screen

```
┌─────────────────────────────┐
│ Divine Hunt - 30 seconds!   │
│                             │
│    [🎯]      [🎯]          │
│         [🎯]                │
│                 [🎯]        │
│  [🎯]                       │
│                             │
│ Targets Hit: 12/∞           │
│ Bonus Multiplier: 2.5x      │
│ Time Remaining: 23s         │
└─────────────────────────────┘
```

**Mechanics**:
- **Session Duration**: 30 seconds
- **Cooldown**: 10 minutes between hunts (stored in `GameState.lastHuntTime`)
- **Targets**: 5-7 targets visible at once, randomly positioned
- **Target Lifetime**: Each target visible for 2-3 seconds before despawning
- **Spawning**: New target spawns immediately when one is clicked or despawns
- **Hit Detection**: Tap/click target to "hit" it
- **Scoring**:
  - Base reward: 10 cats per target hit
  - Combo multiplier: Consecutive hits increase multiplier (1x → 1.5x → 2x → 2.5x → 3x max)
  - Multiplier resets if no hit for 2 seconds
- **Total Rewards**: Average session yields 200-500 cats (skill-dependent)

**UI Elements**:
- Full-screen overlay (darkened background)
- Animated targets (fade in/out)
- Running counter of hits
- Timer countdown
- "End Hunt" button to exit early

**Implementation**:
- Use `Stack` widget for target positioning
- Random `Positioned` widgets for target placement
- `Timer` for session countdown and target despawn
- `GestureDetector` for tap detection
- Simple state machine: idle → active → complete

---

### Ares (1B cats) - Conquest System

**Unlock Trigger**: When player earns 1,000,000,000 total cats

**What Unlocks**:
- Conquest tab appears in bottom navigation
- War Monument building becomes available
- Conquest Points resource enabled
- Ambrosia resource enabled

#### Conquest Points Resource

- Generated by War Monument buildings (1 point/sec per monument)
- Displayed in resource counter at top of screen
- Not consumed when spent (accumulates permanently)
- Used as currency for unlocking territories

#### Conquest Screen

```
┌─────────────────────────────┐
│ Conquest Map                │
│ Conquest Points: 1,247      │
│ ─────────────────────────── │
│ Territories                 │
│                             │
│ [✓] Northern Wilds          │
│     Cost: 100 CP            │
│     Bonus: +5% cat prod     │
│                             │
│ [○] Eastern Mountains       │
│     Cost: 500 CP            │
│     Bonus: +10% offerings   │
│     Requires: Northern Wilds│
│                             │
│ [ ] Southern Seas           │
│     Cost: 2,500 CP          │
│     Bonus: +25% all prod    │
│     Requires: Eastern Mtns  │
│                             │
│ [... 5 more territories]    │
└─────────────────────────────┘
```

#### Territory System (Phase 3)

**8 Territories Total**, linear progression:

1. **Northern Wilds** - Cost: 100 CP, Bonus: +5% cat production
2. **Eastern Mountains** - Cost: 500 CP, Bonus: +10% offerings, Requires: Northern Wilds
3. **Southern Seas** - Cost: 2,500 CP, Bonus: +25% all production, Requires: Eastern Mountains
4. **Western Deserts** - Cost: 10,000 CP, Bonus: +15% Divine Essence, Requires: Southern Seas
5. **Central Citadel** - Cost: 50,000 CP, Bonus: +50% cat production, Requires: Western Deserts
6. **Underworld Gates** - Cost: 250,000 CP, Bonus: +30% prayers, Requires: Central Citadel
7. **Olympus Foothills** - Cost: 1,000,000 CP, Bonus: +75% all production, Requires: Underworld Gates
8. **Titan's Realm** - Cost: 5,000,000 CP, Bonus: +100% all production, Requires: Olympus Foothills

**Mechanics**:
- Territories unlock in linear order (must conquer prerequisites)
- "Conquer" button spends Conquest Points if affordable + requirements met
- Bonuses apply immediately and permanently to production calculations
- Bonuses stack (conquering all 8 territories = massive production boost)
- Persists through save/load
- Not lost on reincarnation (permanent progression)

**Integration**:
- Production bonuses calculated in `GameProvider._updateGame()`
- Applied as multipliers to base production rates
- Example: If you have +5% cats from Northern Wilds and +50% from Central Citadel, total cat production is multiplied by 1.55

---

## Technical Implementation

### State Management Extensions

#### GameState Additions

```dart
class GameState {
  // Existing fields...
  final Map<ResourceType, double> resources;
  final Map<BuildingType, int> buildings;
  final Set<God> unlockedGods;
  final Set<String> unlockedAchievements;

  // NEW Phase 3 fields
  final Set<String> completedResearch;      // Research node IDs
  final Set<String> conqueredTerritories;   // Territory IDs
  final DateTime? lastHuntTime;             // Cooldown tracking

  // Constructor and methods updated accordingly...
}
```

#### ResourceType Enum Additions

```dart
enum ResourceType {
  // Existing Tier 1
  cats,
  offerings,
  prayers,

  // NEW Tier 2
  divineEssence,
  ambrosia,
  conquestPoints,

  // Future Tier 3 (not Phase 3)
  ichor,
  celestialFragments,
}
```

### New Models

#### ResearchNode

```dart
class ResearchNode {
  final String id;
  final String name;
  final String description;
  final ResearchBranch branch;
  final Map<ResourceType, double> cost;
  final List<String> prerequisites;
  final ResearchEffect effect;
  final Map<String, dynamic>? effectData; // Extra data for effect

  const ResearchNode({...});
}
```

#### Territory

```dart
class Territory {
  final String id;
  final String name;
  final String description;
  final double cost; // Conquest Points
  final String? prerequisite; // Territory ID
  final TerritoryBonus bonus;

  const Territory({...});
}

class TerritoryBonus {
  final ResourceType? resourceType; // null = all resources
  final double multiplier; // e.g., 1.05 for +5%

  const TerritoryBonus({...});
}
```

#### HuntSession

```dart
class HuntSession {
  final DateTime startTime;
  final int targetsHit;
  final double comboMultiplier;
  final List<HuntTarget> activeTargets;

  HuntSession({...});
}

class HuntTarget {
  final String id;
  final Offset position;
  final DateTime spawnTime;

  HuntTarget({...});
}
```

### New Providers

#### ResearchProvider

```dart
final researchProvider = StateNotifierProvider<ResearchNotifier, ResearchState>((ref) {
  return ResearchNotifier(ref);
});

class ResearchNotifier extends StateNotifier<ResearchState> {
  // Methods:
  bool canResearch(String nodeId);
  void completeResearch(String nodeId);
  List<ResearchNode> getAvailableNodes();
  List<ResearchNode> getNodesByBranch(ResearchBranch branch);
}
```

#### ConquestProvider

```dart
final conquestProvider = StateNotifierProvider<ConquestNotifier, ConquestState>((ref) {
  return ConquestNotifier(ref);
});

class ConquestNotifier extends StateNotifier<ConquestState> {
  // Methods:
  bool canConquerTerritory(String territoryId);
  void conquerTerritory(String territoryId);
  double getTotalProductionMultiplier(ResourceType? type);
}
```

#### HuntProvider

```dart
final huntProvider = StateNotifierProvider<HuntNotifier, HuntState>((ref) {
  return HuntNotifier(ref);
});

class HuntNotifier extends StateNotifier<HuntState> {
  // Methods:
  void startHunt();
  void hitTarget(String targetId);
  void endHunt();
  bool canStartHunt(); // Checks cooldown
  Duration getTimeUntilNextHunt();
}
```

### Production Calculation Updates

The existing `_updateGame()` in `GameProvider` needs extensions:

```dart
void _updateGame(double deltaSeconds) {
  // Existing production calculation...
  double catsProduced = 0;
  double offeringsProduced = 0;
  double prayersProduced = 0;

  // NEW: Tier 2 resource production
  double divineEssenceProduced = 0;
  double ambrosiaProduced = 0;
  double conquestPointsProduced = 0;

  // Calculate base production from buildings...

  // NEW: Apply research bonuses
  final researchMultipliers = _getResearchMultipliers();
  catsProduced *= researchMultipliers[ResourceType.cats] ?? 1.0;
  // ... apply to all resources

  // NEW: Apply conquest territory bonuses
  final conquestMultipliers = ref.read(conquestProvider.notifier)
    .getTotalProductionMultiplier(null); // null = all resources
  catsProduced *= conquestMultipliers;
  // ... apply to all resources

  // NEW: Handle Workshop resource conversion
  if (state.buildings.containsKey(BuildingType.workshop)) {
    final workshopCount = state.buildings[BuildingType.workshop]!;
    final conversionRate = 10.0; // 10 offerings = 1 Divine Essence
    final conversionEfficiency = _getResearchBonus('divine_alchemy') ? 1.25 : 1.0;

    // Calculate how many offerings to convert
    final offeringsToConvert = offeringsProduced * 0.1; // Convert 10% automatically
    final essenceGenerated = (offeringsToConvert / conversionRate) * conversionEfficiency;

    offeringsProduced -= offeringsToConvert;
    divineEssenceProduced += essenceGenerated * workshopCount;
  }

  // Update resources...
}

Map<ResourceType, double> _getResearchMultipliers() {
  // Calculate multipliers based on completedResearch
  // Example: Divine Architecture I adds +10% to shrines
  // Return map of resource -> multiplier
}
```

### Navigation Changes

Bottom navigation expands dynamically based on unlocked gods:

```dart
List<BottomNavigationBarItem> _getNavItems() {
  final items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Buildings'),
  ];

  // Add Research tab when Athena unlocked
  if (gameState.hasUnlockedGod(God.athena)) {
    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.science),
      label: 'Research',
    ));
  }

  // Add Conquest tab when Ares unlocked
  if (gameState.hasUnlockedGod(God.ares)) {
    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.shield),
      label: 'Conquest',
    ));
  }

  items.add(BottomNavigationBarItem(
    icon: Icon(Icons.emoji_events),
    label: 'Achievements',
  ));

  items.add(BottomNavigationBarItem(
    icon: Icon(Icons.settings),
    label: 'Settings',
  ));

  return items;
}
```

Final tab order (when all Phase 3 gods unlocked):
1. Home
2. Buildings
3. Research (Athena+)
4. Conquest (Ares+)
5. Achievements
6. Settings

---

## Testing Strategy

### Unit Tests

- `ResearchNode` model tests (cost calculation, prerequisite checking)
- `Territory` model tests (bonus calculation)
- Research unlocking logic (prerequisites, costs)
- Conquest point spending logic
- Production multiplier calculations (research + conquest bonuses)
- Workshop conversion calculations

### Integration Tests

- Complete research path (Foundation I → Sacred Geometry → Divine Architecture II)
- Unlock Athena → verify Research tab appears
- Research Essence Refinement → build Essence Refinery → verify Divine Essence production
- Conquer territories → verify production bonuses apply correctly
- Hunt session → verify scoring and rewards
- Save/load with Phase 3 data

### UI Tests

- Research screen rendering
- Node unlock visual states
- Conquest screen territory list
- Hunt mini-game target interaction
- Oracle screen calculations

---

## Balance Considerations

### Research Costs

- Early research (Divine Architecture I) should be affordable within first hour of Phase 3
- Mid research (Divine Alchemy) gates Ambrosia, requires ~2-3 hours of Phase 3 play
- Late research (Ambrosia Infusion) requires significant investment, 5+ hours

### Territory Costs

- First territory (100 CP) achievable within 30 minutes of unlocking Ares
- Middle territories (10K-50K CP) require 2-4 hours
- Final territory (5M CP) is long-term goal, 10+ hours

### Hunt Rewards

- Average hunt yields 200-500 cats
- At 1B cats to unlock Artemis, this is 0.00005% of total progress
- Provides active engagement without breaking progression balance
- Cooldown prevents farming

### God Unlock Pacing

- Athena at 1M: ~2-3 hours after completing Phase 2 (from 100K Dionysus unlock)
- Apollo at 10M: ~5-8 hours
- Artemis at 100M: ~15-20 hours
- Ares at 1B: ~40-50 hours
- Total Phase 3 content: 60-80 hours of gameplay

---

## Future Expansion Hooks

### Planned for Phase 4 (Prestige)

- Additional research branches (Automation, God Favor)
- Research affects prestige bonuses
- Ambrosia used in prestige mechanics

### Planned for Phase 5 (Late Game)

- Advanced research branch nodes
- More territories in conquest (up to 20 total)
- Workshop converts Tier 2 → Tier 3 resources
- Hunting rewards scale with late-game progression

---

## Summary

Phase 3 delivers substantial strategic depth through the tech tree system while adding variety via god-specific mechanics. The foundation is laid for long-term progression (permanent research, territory bonuses) that will carry into prestige systems.

**Key Deliverables:**
- 8 research nodes across 2 branches
- 4 new gods with unique mechanics
- 5 new building types
- 3 new resources (Divine Essence, Ambrosia, Conquest Points)
- 8 conquest territories
- Oracle forecasting system
- Hunt mini-game
- Tech tree UI
- Conquest UI

**Success Metrics:**
- Players engage with research choices (not just rushing one path)
- God mechanics feel distinct and valuable
- Hunt mini-game is fun, not tedious
- Production growth curve remains satisfying
- No progression bottlenecks or dead zones
