# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mythical Cats is a Flutter-based idle/incremental game where players collect mythical cats to ascend Mount Olympus. The game features a prestige system, multiple resource types, god unlocks, achievements, research trees, territory conquest, prophecies, and reincarnation mechanics.

**Live Demo**: https://atkins.github.io/mythical-cats/

## Development Commands

### Setup & Running
```bash
# Install dependencies
flutter pub get

# Run on web (Chrome)
flutter run -d chrome

# Run tests (all tests)
flutter test

# Run specific test file
flutter test test/providers/game_provider_test.dart

# Run tests with verbose output
flutter test --verbose

# Analyze code for errors/warnings
flutter analyze
```

### Building
```bash
# Build web version (production)
flutter build web

# Build with verbose output
flutter build web --verbose
```

### Code Generation
The project uses code generation for Riverpod providers and JSON serialization. If you modify provider annotations or JSON models, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Architecture

### State Management: Riverpod
- **GameNotifier** (lib/providers/game_provider.dart): Core game state and logic with 60 FPS ticker-based game loop
- **ResearchNotifier** (lib/providers/research_provider.dart): Research system logic
- **ConquestNotifier** (lib/providers/conquest_provider.dart): Territory conquest logic
- All state is **immutable** - use `copyWith()` methods to create new states

### Immutable State Pattern
The entire game state (GameState) is immutable. Every state change creates a new instance using `copyWith()`. This is critical for:
- Riverpod reactivity
- Debugging (state changes are explicit)
- Time-travel debugging capability
- Preventing subtle mutation bugs

**Example**:
```dart
// ❌ NEVER mutate state directly
state.resources[ResourceType.cats] = 100;

// ✅ ALWAYS use copyWith
state = state.copyWith(
  resources: {...state.resources, ResourceType.cats: 100},
);
```

### Game Loop Architecture
The game uses Flutter's `Ticker` class (60 FPS) in GameNotifier to:
1. Calculate time delta between frames
2. Update resources based on production rates
3. Check for god unlocks and achievements
4. Auto-save every 30 seconds
5. Update prophecy effects and expirations

**Critical**: The ticker runs continuously. Do not create additional game loops.

### Data-Driven Design
Game content is defined in centralized "definitions" files, not scattered across code:
- **BuildingDefinition** (lib/models/building_definition.dart): All 20 building types with costs, production rates
- **AchievementDefinitions** (lib/models/achievement_definitions.dart): All 18 achievements with unlock conditions
- **ResearchDefinitions** (lib/models/research_definitions.dart): 15 research nodes across 3 branches
- **ConquestDefinitions** (lib/models/conquest_definitions.dart): 11 conquerable territories
- **PrimordialUpgradeDefinitions** (lib/models/primordial_upgrade_definitions.dart): 20 prestige upgrades
- **RandomEventDefinitions** (lib/models/random_event_definitions.dart): Future random events

When adding new content (buildings, achievements, etc.), add to these definition files first.

### Resource System
6 resource types (ResourceType enum):
- **Cats**: Primary currency, earned through clicks and buildings
- **Offerings**: Tier 2 resource, produced by certain buildings
- **Prayers**: Tier 2 resource, produced by certain buildings
- **Divine Essence**: Tier 2 resource, created via Workshop conversion
- **Ambrosia**: Tier 3 resource for advanced features
- **Wisdom**: Phase 5 resource (Athena), used for prophecies

All production rates are calculated dynamically with multipliers from:
- Building bonuses
- Research bonuses
- Achievement bonuses
- Territory conquest bonuses
- Primordial Force upgrades
- Active prophecy effects

### God Progression System
12 Olympian gods unlock sequentially based on total cats earned:
- Hermes (starting god)
- Hestia (1K), Demeter (10K), Dionysus (100K)
- Athena (1M), Apollo (10M) - **Currently implemented**
- Artemis (100M), Ares (1B), Hephaestus (10B), Aphrodite (100B), Poseidon (1T), Zeus (10T) - **Future**

Each god unlocks 4 god-specific buildings. See lib/models/god.dart for unlock thresholds.

### Prestige/Reincarnation System
Unlocks at 1 billion cats. Key mechanics:
- **Primordial Essence (PE)**: Prestige currency earned on reset
- **4 Primordial Forces**: Chaos, Gaia, Nyx, Erebus (each with 5 upgrades)
- **Patron System**: Select one active force for temporary enhanced bonuses
- **Persistence**: Research, achievements, and purchased upgrades carry over
- **Formula**: PE earned = sqrt(totalCatsEarned / 1e9) - totalPEEarned

### Prophecy System (Phase 5)
10 divine prophecies with timed boost effects:
- Activated by spending Wisdom resource
- Each has a cooldown period (tracked via ProphecyState)
- Effects can be instant (resource grants) or timed boosts (production multipliers, cost reductions)
- Active timed boost is tracked globally (only one at a time)
- See lib/models/prophecy.dart for all prophecy types and mechanics

## Project Structure

```
lib/
  models/          # 17+ data models (immutable state classes)
    - game_state.dart           # Root game state (contains everything)
    - building_definition.dart  # Building cost/production formulas
    - achievement_definitions.dart
    - research_definitions.dart
    - conquest_definitions.dart
    - primordial_upgrade_definitions.dart
    - reincarnation_state.dart  # Prestige system state
    - prophecy.dart             # Prophecy types and state
    - god.dart, resource_type.dart, building_type.dart

  providers/       # 3 Riverpod StateNotifiers
    - game_provider.dart        # Core game loop + actions
    - research_provider.dart
    - conquest_provider.dart

  screens/         # 8 full-screen tabs
    - home_screen.dart          # Main game view with click button
    - buildings_screen.dart
    - research_screen.dart
    - conquest_screen.dart
    - achievements_screen.dart
    - prophecy_screen.dart      # Phase 5 prophecy UI
    - reincarnation_screen.dart # Prestige system
    - settings_screen.dart

  widgets/         # 14+ reusable components
    - resource_panel.dart       # Displays all resources
    - compact_resource_bar.dart # Navigation tab resource display
    - building_card.dart
    - achievement_card.dart
    - research_node_card.dart
    - territory_card.dart
    - prophecy_card.dart        # Phase 5 prophecy display
    - workshop_converter.dart   # Convert offerings → divine essence
    - prestige_stats_panel.dart
    - patron_selector.dart
    - primordial_force_section.dart
    - primordial_upgrade_card.dart

  services/
    - save_service.dart         # SharedPreferences persistence

  utils/
    - number_formatter.dart     # K, M, B, T formatting for large numbers
```

## Testing

**Comprehensive test suite** with 39 test files (~7400 lines):
- Model tests: Verify data model serialization, calculations, and business logic
- Provider tests: Test game logic, state transitions, and calculations
- Widget tests: UI component testing
- Integration tests: End-to-end phase testing (test/e2e/)
  - phase2_integration_test.dart (achievements, research)
  - phase3_integration_test.dart (conquest)
  - phase4_integration_test.dart (prestige/reincarnation)
  - phase5_integration_test.dart (wisdom, prophecy)

**Testing patterns**:
- Always use `TestWidgetsFlutterBinding.ensureInitialized()` at the start of test files
- Use `ProviderContainer` for testing Riverpod providers in isolation
- Create fresh containers in `setUp()`, dispose in `tearDown()`
- For multi-step integration tests, verify state at each step

**Running specific tests**:
```bash
flutter test test/providers/game_provider_test.dart
flutter test test/e2e/phase5_integration_test.dart
```

## Persistence

Uses `shared_preferences` package for browser local storage (web) or native storage (mobile):
- Auto-saves every 30 seconds
- Manual save/load via SaveService
- JSON serialization via `toJson()`/`fromJson()` methods on GameState
- Offline progression calculated on load (up to 24 hours, expandable via research)

## Adding New Features

### Adding a New Building
1. Add enum to BuildingType (lib/models/building_type.dart)
2. Add definition to BuildingDefinitions (lib/models/building_definition.dart)
3. Add display logic to buildings_screen.dart
4. Add tests for the new building

### Adding a New Achievement
1. Add definition to AchievementDefinitions (lib/models/achievement_definitions.dart)
2. Add unlock condition check in GameNotifier._checkAchievements()
3. Add bonus application in relevant production/cost calculation methods
4. Add tests verifying unlock conditions and rewards

### Adding a New Resource Type
1. Add enum to ResourceType (lib/models/resource_type.dart)
2. Update GameState.initial() to initialize the resource
3. Update resource_panel.dart to display it
4. Update relevant production calculation methods

### Adding a New Research Node
1. Add definition to ResearchDefinitions (lib/models/research_definitions.dart)
2. Update research_screen.dart if adding a new branch
3. Add bonus application in relevant calculation methods
4. Add tests

### Adding a New God
1. Add enum to God (lib/models/god.dart) with unlock threshold
2. Add god-specific buildings to BuildingType and BuildingDefinitions
3. Update unlock check in GameNotifier._checkGodUnlocks()
4. Add achievements if needed
5. Add integration test

## Number Formatting

Use `NumberFormatter.format(value)` for all resource/cost displays:
- < 1,000: Shows decimals (e.g., "42.5")
- ≥ 1,000: Shows suffixes (e.g., "1.2K", "5.3M", "2.1B", "8.7T")

Implemented in lib/utils/number_formatter.dart.

## Future Phases

**Phase 6** (Combat & War): Ares god, combat system, war resources (Might, Glory)
**Phase 7** (Late Game): Final 5 gods, breeding, artifacts, random events, ascension endgame

See README.md for detailed phase roadmap.

## Code Quality

- Project maintains **0 analyzer errors, 0 warnings**
- Follow existing patterns for immutability and state management
- All new features should have corresponding tests
- Use Material 3 design patterns for UI consistency
- Mobile-first design (test on narrow viewports)
