# Random Events Integration Design

**Date**: 2025-11-14
**Status**: Design Complete - Ready for Implementation
**Phase**: Phase 2 Completion
**Estimated Implementation Time**: 3-4 hours

## Overview

Complete the Phase 2 Random Events system by integrating existing event models (`RandomEvent`, `RandomEventDefinitions`) into the game loop and UI. This adds dynamic, beneficial events that grant instant resource bonuses or temporary production multipliers.

## Existing Foundation

**Already Implemented:**
- `lib/models/random_event.dart` - Event model with types (bonus, multiplier, discovery)
- `lib/models/random_event_definitions.dart` - 5 event definitions:
  - Divine Cat Appears (+50 cats)
  - Offering from Mortals (+100 offerings)
  - Divine Favor (2x multiplier for 30 seconds)
  - Prayer Circle (+50 prayers)
  - Cat Blessing (+100 cats, +50 offerings)

**Missing Implementation:**
- Event spawning logic in game loop
- Event state tracking in GameState
- Multiplier application in production calculations
- UI notification system

## Design Decisions

### Spawn Mechanism: Hybrid (Probability + Cooldown)
- **Probability**: 0.1% chance per second (~0.00167% per tick at 60 FPS)
- **Cooldown**: Minimum 5 minutes between events
- **Result**: ~1 event every 5-15 minutes (natural feel, controlled pacing)
- **Rationale**: Prevents event spam while maintaining unpredictability

### UI Approach: Banner Notification (Non-Interruptive)
- Banner slides in from top
- Auto-dismisses after 3 seconds
- Auto-claims bonuses (no manual interaction required)
- Color-coded by event type (green=bonus, purple=multiplier, blue=discovery)
- **Rationale**: Doesn't interrupt gameplay flow, suitable for idle game

### Multiplier Stacking: Multiplicative
- Event multipliers stack multiplicatively with all existing bonuses
- Example: 50% prophecy × 20% research × 2.0 event = 3.6x total
- **Rationale**: Consistent with existing prophecy system, makes events feel impactful

### Persistence: No Persistence (Expires on App Close)
- Active event effects expire when app closes
- No offline multiplier application
- **Rationale**: Events are frequent enough that losing one isn't critical, keeps implementation simple

## Architecture

### Approach: Mirror Prophecy System
Follow the existing prophecy architecture pattern for consistency and code reuse.

**State Management:**
- Extend GameState with event-specific fields
- Use immutable state pattern (copyWith)
- Track active events and cooldowns

**Data Flow:**
1. GameProvider ticker (60 FPS) checks spawn conditions
2. If conditions met → spawn event → update GameState
3. Ticker applies event multipliers in production calculations
4. Ticker checks expiration → clears active event
5. UI listens to state changes → shows banner notification

**Integration Points:**
- `GameState` - Add event tracking fields
- `GameProvider._onTick()` - Event spawn + expiration checks
- `GameProvider.getProductionRate()` - Apply event multipliers
- `RandomEventBanner` widget - Display notifications
- `HomeScreen` - Render banner overlay

## Implementation Details

### 1. GameState Modifications

**New Fields:**
```dart
class GameState {
  // Random Events
  final RandomEvent? activeRandomEvent;
  final DateTime? randomEventEndTime;
  final DateTime lastRandomEventSpawnTime;

  const GameState({
    // ... existing params ...
    this.activeRandomEvent,
    this.randomEventEndTime,
    DateTime? lastRandomEventSpawnTime,
  }) : lastRandomEventSpawnTime = lastRandomEventSpawnTime ?? DateTime(2000);
}
```

**Field Purposes:**
- `activeRandomEvent`: Current event (null = no active event). For bonus events, set briefly during claim then cleared. For multiplier events, stays set until duration expires.
- `randomEventEndTime`: When multiplier effect expires (null for instant bonus events)
- `lastRandomEventSpawnTime`: Last spawn time for cooldown enforcement (initialized to year 2000 for immediate first event)

**Helper Methods:**
```dart
bool get hasActiveRandomEvent => activeRandomEvent != null;

bool get hasActiveRandomEventMultiplier =>
    activeRandomEvent?.type == RandomEventType.multiplier &&
    randomEventEndTime != null &&
    DateTime.now().isBefore(randomEventEndTime!);
```

### 2. Event Spawning Logic

**Location:** `GameProvider._onTick()`

**Spawn Conditions (all must be true):**
1. No event currently active (`activeRandomEvent == null`)
2. Cooldown elapsed (5+ minutes since `lastRandomEventSpawnTime`)
3. Random check passes (0.1% chance per second)

**Implementation:**
```dart
void _onTick(Duration elapsed) {
  // ... existing production logic ...

  _checkRandomEventSpawn(elapsed);
  _updateActiveRandomEvent();

  // ... existing achievement/god unlock checks ...
}

void _checkRandomEventSpawn(Duration elapsed) {
  // Don't spawn if event already active
  if (state.activeRandomEvent != null) return;

  // Check cooldown (5 minutes minimum)
  final timeSinceLastEvent = DateTime.now().difference(state.lastRandomEventSpawnTime);
  if (timeSinceLastEvent.inMinutes < 5) return;

  // Probability check: 0.1% per second
  final random = Random();
  final spawnChance = 0.001 * (elapsed.inMilliseconds / 1000.0);
  if (random.nextDouble() > spawnChance) return;

  // Spawn event!
  final event = RandomEventDefinitions.getRandom(DateTime.now());
  _activateRandomEvent(event);
}
```

### 3. Event Activation & Effects

**Instant Bonus Events:**
```dart
void _activateRandomEvent(RandomEvent event) {
  final now = DateTime.now();

  if (event.type == RandomEventType.bonus) {
    // Grant resources immediately
    final newResources = Map<ResourceType, double>.from(state.resources);
    event.bonusResources.forEach((type, amount) {
      newResources[type] = (newResources[type] ?? 0) + amount;
    });

    state = state.copyWith(
      resources: newResources,
      activeRandomEvent: event, // Set for UI notification
      lastRandomEventSpawnTime: now,
    );

    // Clear after notification duration (3 seconds)
    Future.delayed(Duration(seconds: 3), () {
      if (state.activeRandomEvent?.id == event.id) {
        state = state.copyWith(activeRandomEvent: null);
      }
    });
  }

  // Timed Multiplier Events
  else if (event.type == RandomEventType.multiplier) {
    state = state.copyWith(
      activeRandomEvent: event,
      randomEventEndTime: now.add(event.duration!),
      lastRandomEventSpawnTime: now,
    );
  }
}
```

**Multiplier Application:**
```dart
double getProductionRate(ResourceType type) {
  double rate = _calculateBaseProduction(type);
  rate *= _getResearchMultiplier(type);
  rate *= _getAchievementMultiplier(type);
  rate *= _getPrimordialMultiplier(type);
  rate *= _getProphecyMultiplier(type);
  rate *= _getRandomEventMultiplier(type); // NEW
  return rate;
}

double _getRandomEventMultiplier(ResourceType type) {
  if (!state.hasActiveRandomEventMultiplier) return 1.0;
  return state.activeRandomEvent!.multiplier;
}
```

**Event Expiration:**
```dart
void _updateActiveRandomEvent() {
  if (state.randomEventEndTime == null) return;

  if (DateTime.now().isAfter(state.randomEventEndTime!)) {
    state = state.copyWith(
      activeRandomEvent: null,
      randomEventEndTime: null,
    );
  }
}
```

### 4. UI Components

**RandomEventBanner Widget:**
```dart
class RandomEventBanner extends StatelessWidget {
  final RandomEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getEventColor(event.type),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_getEventIcon(event.type), color: Colors.white, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(event.description, style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(RandomEventType type) {
    switch (type) {
      case RandomEventType.bonus: return Colors.green.shade700;
      case RandomEventType.multiplier: return Colors.purple.shade700;
      case RandomEventType.discovery: return Colors.blue.shade700;
    }
  }

  IconData _getEventIcon(RandomEventType type) {
    switch (type) {
      case RandomEventType.bonus: return Icons.star;
      case RandomEventType.multiplier: return Icons.bolt;
      case RandomEventType.discovery: return Icons.explore;
    }
  }
}
```

**HomeScreen Integration:**
```dart
// Add at top of Stack in build()
if (gameState.hasActiveRandomEvent)
  Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: RandomEventBanner(event: gameState.activeRandomEvent!),
  ),
```

## Testing Strategy

### Unit Tests (GameProvider)

**Spawn Condition Tests:**
- Event spawns when cooldown elapsed + random check passes
- Event doesn't spawn if already active
- Event doesn't spawn if cooldown not elapsed
- Cooldown properly enforced (5 minutes minimum)

**Event Activation Tests:**
- Bonus events grant resources immediately
- Multiplier events set end time correctly
- `lastRandomEventSpawnTime` updates on spawn

**Multiplier Application Tests:**
- `_getRandomEventMultiplier()` returns correct multiplier when active
- Returns 1.0 when no active event
- Multiplier stacks multiplicatively with prophecies/research/achievements

**Event Expiration Tests:**
- Multiplier events clear after duration expires
- Bonus events clear after notification duration (3 sec)

### Integration Tests

**File:** `test/e2e/random_events_integration_test.dart`

**Test Scenarios:**
- Full flow: spawn → activate → apply multiplier → expire
- Verify resources granted for bonus events
- Verify production boost for multiplier events
- Test multiple event cycles (spawn → expire → cooldown → spawn again)

**Edge Cases:**
- App restart during active event (should clear)
- Multiple events trying to spawn simultaneously (cooldown prevents)
- Event spawning at exactly cooldown boundary

## Implementation Sequence (Test-Driven)

1. **GameState modifications**
   - Add three new fields to GameState
   - Add helper methods (`hasActiveRandomEvent`, etc.)
   - Update `copyWith()`, `toJson()`, `fromJson()`
   - Update initial state
   - **Test**: Serialization roundtrip with new fields

2. **Event activation logic**
   - Add `_activateRandomEvent()` method to GameProvider
   - Handle bonus events (instant resource grant)
   - Handle multiplier events (set end time)
   - **Test**: Event activation updates state correctly

3. **Multiplier application**
   - Add `_getRandomEventMultiplier()` method
   - Integrate into `getProductionRate()` for all resource types
   - **Test**: Multipliers apply correctly and stack multiplicatively

4. **Event expiration**
   - Add `_updateActiveRandomEvent()` method
   - Call in `_onTick()` to check expiration
   - **Test**: Events clear after duration expires

5. **Event spawning**
   - Add `_checkRandomEventSpawn()` method
   - Implement probability + cooldown logic
   - Call in `_onTick()`
   - **Test**: Spawn conditions work correctly

6. **UI - RandomEventBanner widget**
   - Create banner widget
   - Add to HomeScreen Stack
   - **Test**: Widget test for rendering

7. **Integration tests**
   - Create e2e test file
   - Test full event lifecycle
   - Test multiple event cycles

## Success Criteria

- [ ] Random events spawn during gameplay (~1 per 5-15 min)
- [ ] Bonus events grant resources instantly
- [ ] Multiplier events boost production for duration
- [ ] Events display in non-intrusive banner notification
- [ ] 5-minute cooldown enforced between events
- [ ] Event multipliers stack with prophecies/research/achievements
- [ ] Events expire on app close (no persistence)
- [ ] All tests passing (unit + integration)
- [ ] 0 analyzer errors/warnings

## Future Enhancements (Out of Scope)

- Chaos primordial upgrade: Increase event spawn rate
- Discovery event type implementation (currently unused)
- Event history/statistics tracking
- Offline event simulation
- Player-triggered events (consume resources to spawn)
