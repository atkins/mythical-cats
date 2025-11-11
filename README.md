# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Phase 4 Features (Current)

**Core Gameplay:**
- Click to perform rituals and summon cats
- Buy buildings that auto-generate resources
- **12 building types** (3 generic + 9 god-specific)
- First 4 gods unlocked (Hermes at start, Hestia at 1K, Demeter at 10K, Dionysus at 100K cats)
- **5 resource types**: Cats, Offerings, Prayers, Divine Essence, Ambrosia

**Progression Systems:**
- Auto-save every 30 seconds
- Offline progression (up to 24 hours, expandable to 72h with upgrades)
- Achievement system with 8 achievements granting permanent bonuses
- **Research/Tech Tree**: 2 branches (Foundation, Resource) with 8 research nodes
- **Conquest System**: 8 conquerable territories with production bonuses
- **Workshop Conversion**: Transform offerings into Divine Essence
- **Reincarnation/Prestige System** (unlocks at 1 billion cats):
  - Reset progress to earn **Primordial Essence (PE)** currency
  - **4 Primordial Forces** with unique upgrade trees (20 upgrades total):
    - **Chaos**: Click power and active play bonuses
    - **Gaia**: Building production and cost reduction
    - **Nyx**: Offline progression bonuses
    - **Erebus**: Tier 2 resource generation bonuses
  - **Patron System**: Select one active force for enhanced temporary bonuses
  - **Persistent Upgrades**: Keep research, achievements, and purchased upgrades across runs
- Statistics tracking (total cats, buildings, gods, achievements, reincarnations, lifetime PE)

**UI/UX:**
- Mobile-first Material 3 design
- **7 tabs**: Home, Buildings, Research, Conquest, Achievements, Reincarnation, Settings
- Number formatting for large values (K, M, B, T suffixes)
- Achievement progress tracking
- Research node cards with prerequisites
- Territory conquest cards with bonuses
- **Reincarnation screen** with patron selector and upgrade cards
- **Prestige stats panel** on home screen showing PE and active patron
- Confirmation dialogs with detailed reset/persist information

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
  models/          # 15 data models (GameState, Buildings, Resources, Gods,
                   # Achievements, Research, Conquest, Reincarnation,
                   # Primordial Forces & Upgrades)
  providers/       # 3 Riverpod providers (game, research, conquest logic)
  screens/         # 7 UI screens (Home, Buildings, Research, Conquest,
                   # Achievements, Reincarnation, Settings)
  widgets/         # 13 reusable widgets (cards, converters, panels,
                   # primordial upgrade cards, patron selector, prestige panel)
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # 24 test files with 230 passing tests
```

## Test Coverage

- **230 tests passing** (Phases 1-4 integration + unit tests)
- 0 analyzer errors, 0 warnings
- Model tests for all game entities including reincarnation state
- Provider tests for game logic and prestige mechanics
- Integration tests for full gameplay flows
- **22 UI widget tests** for Phase 4 reincarnation screens

## Next Steps (Future Phases)

### Phase 5: Mid-Late Game Gods & Systems
- **Gods 5-6**: Athena (1M cats - Research bonuses), Ares (100M cats - Combat/conquest)
- **Tier 3 Resources**: Favor, Glory, Divinity
- **God-specific buildings** for Athena and Ares
- **Advanced conquest** mechanics
- **Divine favor** system

### Phase 6: Late Game Content
- **Gods 7-8**: Apollo (Sun/Arts), Artemis (Moon/Hunting)
- **Gods 9-12**: Hephaestus (Crafting), Aphrodite (Influence), Poseidon (Seas), Zeus (Thunder)
- **Advanced systems**: Breeding, Artifacts, Random Events
- **Ascension to Olympus** endgame
- **Meta-progression** beyond reincarnation

## Live Demo

Play now: https://atkins.github.io/mythical-cats/

## License

MIT
