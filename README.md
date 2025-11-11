# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Phase 3 Features (Current)

**Core Gameplay:**
- Click to perform rituals and summon cats
- Buy buildings that auto-generate resources
- **12 building types** (3 generic + 9 god-specific)
- First 4 gods unlocked (Hermes at start, Hestia at 1K, Demeter at 10K, Dionysus at 100K cats)
- **5 resource types**: Cats, Offerings, Prayers, Divine Essence, Ambrosia

**Progression Systems:**
- Auto-save every 30 seconds
- Offline progression (up to 24 hours)
- Achievement system with 8 achievements granting permanent bonuses
- **Research/Tech Tree**: 2 branches (Foundation, Resource) with 8 research nodes
- **Conquest System**: 8 conquerable territories with production bonuses
- **Workshop Conversion**: Transform offerings into Divine Essence
- Statistics tracking (total cats, buildings, gods, achievements)

**UI/UX:**
- Mobile-first Material 3 design
- **6 tabs**: Home, Buildings, Research, Conquest, Achievements, Settings
- Number formatting for large values
- Achievement progress tracking
- Research node cards with prerequisites
- Territory conquest cards with bonuses

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
  models/          # 13 data models (GameState, Buildings, Resources, Gods,
                   # Achievements, Research, Conquest)
  providers/       # 3 Riverpod providers (game, research, conquest logic)
  screens/         # 6 UI screens (Home, Buildings, Research, Conquest,
                   # Achievements, Settings)
  widgets/         # 8 reusable widgets (cards, converters, panels)
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # 18 test files with 116 passing tests
```

## Test Coverage

- **116 tests passing** (Phase 1, 2, 3 integration + unit tests)
- 0 analyzer errors, 0 warnings
- Model tests for all game entities
- Provider tests for game logic
- Integration tests for full gameplay flows

## Next Steps (Future Phases)

### Phase 4: Prestige System
- Reincarnation mechanic
- Primordial forces and skill trees
- Persistent upgrades across runs

### Phase 5: Late Game Content
- Gods 5-8 (Athena, Apollo, Artemis, Ares) with unique mechanics
- Gods 9-12 (Hephaestus, Aphrodite, Poseidon, Zeus)
- Advanced systems (breeding, artifacts, random events)
- Ascension to Olympus endgame

## Live Demo

Play now: https://atkins.github.io/mythical-cats/

## License

MIT
