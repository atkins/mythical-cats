# Unimplemented Features Inventory

**Date**: 2025-11-13
**Status**: Planning Document
**Purpose**: Catalog all designed but unimplemented interactive features and mini-games

## Overview

This document tracks features that were designed in the original game design documents but have not yet been implemented. It serves as a backlog for future development phases.

## Implementation Status Categories

- ✅ **Fully Implemented**: Feature is complete and playable
- ⚠️ **Partially Implemented**: Models/buildings exist but core mechanics missing
- ❌ **Not Implemented**: Only exists in design docs, no code written

---

## Interactive Features & Mini-Games

### 1. Artemis Hunting Mini-Game ❌ NOT IMPLEMENTED

**Unlock**: Artemis unlocks at 100,000,000 total cats
**Design Source**: `docs/plans/2025-11-09-phase3-mid-game-systems-design.md`

#### Designed Mechanics
- **Session Duration**: 30 seconds
- **Cooldown**: 10 minutes between hunts
- **Gameplay**:
  - 5-7 targets spawn randomly on screen
  - Each target visible for 2-3 seconds before despawning
  - Tap/click targets to earn rewards
  - Combo multiplier system: 1x → 1.5x → 2x → 2.5x → 3x max
  - Multiplier resets if no hit for 2 seconds
- **Rewards**: 10 cats per target hit (base), 200-500 cats per session average
- **UI**: Full-screen overlay, animated targets, running counter, timer countdown

#### Current Status
- Artemis god exists in `lib/models/god.dart`
- NO hunting screen implementation
- NO hunt button on home screen
- NO game state tracking for hunt cooldowns

#### Implementation Notes
- Requires: `Stack` widget for positioning, `Timer` for countdown, `GestureDetector` for taps
- State tracking: `lastHuntTime` field in GameState
- Simple state machine: idle → active → complete

---

### 2. Random Events System ⚠️ PARTIALLY IMPLEMENTED

**Unlock**: Available throughout game
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- Occasional pop-up events with bonuses
- Examples:
  - "A wild divine cat appears! Tap to claim bonus cats"
  - "The gods smile upon you: 2x production for 30 seconds"
  - "Offering from mortals: +500 Prayers"
- More frequent with Chaos primordial bonuses
- Not intrusive, purely beneficial

#### Current Status
- ✅ Models defined: `lib/models/random_event.dart`
- ✅ Event definitions: `lib/models/random_event_definitions.dart`
  - Divine Cat Appears (+50 cats)
  - Offering from Mortals (+100 offerings)
  - Divine Favor (2x multiplier for 30 seconds)
  - Prayer Circle (+50 prayers)
  - Cat Blessing (+100 cats, +50 offerings)
- ❌ NOT integrated into game loop
- ❌ NO UI for event pop-ups
- ❌ NO spawn/trigger system

#### Implementation Notes
- Need to add event spawning logic to game loop (probability-based)
- Create pop-up dialog widget for events
- Track active timed effects in GameState
- Apply multipliers during production calculation

---

### 3. Hephaestus Artifact Crafting ❌ NOT IMPLEMENTED

**Unlock**: Hephaestus unlocks at 10,000,000,000 total cats
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- "God of forge. Unlocks: artifact crafting, equipment systems"
- Artifact crafting mechanics (details not specified in docs)
- Equipment system for bonuses

#### Current Status
- Hephaestus god exists in `lib/models/god.dart`
- Only unlocks Workshop building (offerings → divine essence conversion)
- NO artifact models
- NO crafting system
- NO equipment system

#### Implementation Notes
- Needs detailed design specification
- Likely requires: artifact definitions, crafting recipes, inventory system
- Possible UI: crafting screen, artifact slots, material requirements

---

### 4. Aphrodite Cat Breeding/Genetics ❌ NOT IMPLEMENTED

**Unlock**: Aphrodite unlocks at 100,000,000,000 total cats
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- "Goddess of love. Unlocks: cat breeding/genetics system"
- Breeding Grounds building mentioned
- Combine cat types for bonuses
- Genetics system (details not specified)

#### Current Status
- Aphrodite god exists in `lib/models/god.dart`
- NO buildings associated with Aphrodite
- NO breeding models
- NO genetics system
- NO cat variations/types

#### Implementation Notes
- Needs detailed design specification
- Likely requires: cat type definitions, breeding mechanics, genetic traits
- Possible UI: breeding screen, cat collection, trait viewer

---

### 5. Poseidon Naval Exploration ❌ NOT IMPLEMENTED

**Unlock**: Poseidon unlocks at 1,000,000,000,000 total cats
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- "God of sea. Unlocks: naval exploration, new realms"
- Exploration system
- New realms to discover

#### Current Status
- Poseidon god exists in `lib/models/god.dart`
- NO buildings associated with Poseidon
- NO exploration models
- NO realm system
- NO navigation mechanics

#### Implementation Notes
- Needs detailed design specification
- Likely requires: realm definitions, exploration mechanics, navigation UI
- Possible UI: map screen, realm viewer, ship/expedition management

---

### 6. Zeus Ascension & Final Challenges ❌ NOT IMPLEMENTED

**Unlock**: Zeus unlocks at 10,000,000,000,000 total cats
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- "King of gods. Unlocks: path to ascension, Ichor resource, final challenges"
- Ascension to Olympus endgame
- Ichor resource (defined but unused)
- Final challenges/content

#### Current Status
- Zeus god exists in `lib/models/god.dart`
- Ichor resource defined in `lib/models/resource_type.dart` (icon: 💉)
- NO buildings associated with Zeus
- NO ascension mechanics
- NO Ichor producers/consumers
- NO final challenges

#### Implementation Notes
- Needs detailed design specification
- Likely requires: ascension path, challenge definitions, Ichor economy
- May involve second/third prestige layers
- Endgame content design crucial

---

### 7. Demeter Seasonal Cycles ⚠️ BUILDING ONLY

**Unlock**: Demeter unlocks at 10,000 total cats
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- "Goddess of harvest. Unlocks: Prayers resource, seasonal cycles/bonuses"
- Seasonal bonuses that rotate
- Harvest-themed events

#### Current Status
- ✅ Demeter god exists
- ✅ Harvest Field building (produces prayers)
- ❌ NO seasonal cycle system
- ❌ NO seasonal bonuses
- ❌ NO harvest events

#### Implementation Notes
- Needs seasonal timer/rotation logic
- Could tie to real-world seasons or in-game time
- Seasonal bonuses could affect production rates

---

### 8. Dionysus Festival Events ⚠️ BUILDING ONLY

**Unlock**: Dionysus unlocks at 100,000 total cats
**Design Source**: `docs/plans/2025-11-08-mythical-cats-game-design.md`

#### Designed Mechanics
- "God of celebration. Unlocks: festival events, temporary boosts"
- Festival events with bonuses
- Celebration-themed mechanics

#### Current Status
- ✅ Dionysus god exists
- ✅ Festival Grounds building (produces cats)
- ❌ NO festival event system
- ❌ NO temporary boost mechanics specific to festivals
- ❌ NO celebration events

#### Implementation Notes
- Could integrate with Random Events system
- Festival events could be time-based or triggered
- Temporary boost system already exists via prophecies

---

## Unused Resources

### Ichor
- Defined in `lib/models/resource_type.dart`
- Icon: 💉 (syringe)
- Description: "Blood of the gods"
- Tier: 2 (advanced resource)
- **No producers, consumers, or game mechanics**
- Designed for Zeus endgame content

### Celestial Fragments
- Defined in `lib/models/resource_type.dart`
- Icon: 💎 (gem)
- Description: "Fragments of celestial power"
- Tier: 2 (advanced resource)
- **No producers, consumers, or game mechanics**
- Purpose unclear from design docs

---

## Implementation Priority Recommendations

### High Priority (Enhance Mid-Game)
1. **Random Events System** - Models exist, just needs integration
2. **Artemis Hunting Mini-Game** - Well-specified, adds active gameplay variety

### Medium Priority (Late-Game Content)
3. **Demeter Seasonal Cycles** - Building exists, needs event system
4. **Dionysus Festival Events** - Building exists, could integrate with random events

### Low Priority (Requires Design Work)
5. **Hephaestus Artifact Crafting** - Needs full design specification
6. **Aphrodite Breeding/Genetics** - Needs full design specification
7. **Poseidon Naval Exploration** - Needs full design specification
8. **Zeus Ascension/Challenges** - Endgame content, needs careful design

---

## Dependencies & Considerations

### Technical Dependencies
- Random Events and Festival Events could share trigger system
- Seasonal Cycles needs timer/calendar system
- Hunting mini-game needs gesture/animation framework
- Artifact/Breeding/Exploration need new data models

### Design Dependencies
- Late-game features (5-8) need detailed design documents before implementation
- Ichor economy needs to be designed with Zeus content
- Celestial Fragments purpose needs clarification

### Balance Considerations
- Active gameplay (hunting) should not overshadow idle mechanics
- Random events should be beneficial, not disruptive
- Late-game systems should not invalidate earlier progression

---

## Notes for Future Implementation

### When Implementing Features
1. Create detailed design document first (if not exists)
2. Define all models and data structures
3. Write tests for core mechanics
4. Implement UI components
5. Integrate with existing game loop
6. Balance rewards and requirements
7. Test progression impact

### Integration Points
- **GameState**: May need new fields for cooldowns, active events, inventories
- **Game Loop**: Random events, seasonal cycles need periodic checks
- **Home Screen**: Hunting button, event pop-ups need UI space
- **Divine Powers**: New tabs may be needed for some features

### Related Design Documents
- `2025-11-08-mythical-cats-game-design.md` - Original vision
- `2025-11-09-phase3-mid-game-systems-design.md` - Detailed Phase 3 specs
- Future phases will need design docs for late-game features

---

## Changelog

**2025-11-13**: Initial inventory created based on codebase analysis and design document review
