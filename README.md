# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Live Demo

Play now: https://atkins.github.io/mythical-cats/

## Phase 5 Features (Current)

**Core Gameplay:**
- Click to perform rituals and summon cats
- Buy buildings that auto-generate resources
- **20 building types** (3 generic + 17 god-specific)
- First 6 gods unlocked (Hermes at start, Hestia at 1K, Demeter at 10K, Dionysus at 100K, Athena at 1M, Apollo at 10M cats)
- **6 resource types**: Cats, Offerings, Prayers, Divine Essence, Ambrosia, Wisdom

**Progression Systems:**
- Auto-save every 30 seconds
- Offline progression (up to 24 hours, expandable to 72h with upgrades)
- Achievement system with **18 achievements** granting permanent bonuses (2 hidden)
- **Research/Tech Tree**: 3 branches (Foundation, Resource, Knowledge) with **15 research nodes**
- **Conquest System**: **11 conquerable territories** with production bonuses
- **Workshop Conversion**: Transform offerings into Divine Essence
- **Prophecy System**: 10 divine prophecies with timed boost effects and cooldowns
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
- **8 tabs**: Home, Buildings, Research, Conquest, Achievements, Prophecy, Reincarnation, Settings
- Number formatting for large values (K, M, B, T suffixes)
- Achievement progress tracking with hidden achievements
- Research node cards with prerequisites
- Territory conquest cards with bonuses
- **Prophecy screen** with 10 divine prophecy cards showing cooldowns and effects
- **Wisdom display** on home screen
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
  models/          # 17 data models (GameState, Buildings, Resources, Gods,
                   # Achievements, Research, Conquest, Prophecy, Reincarnation,
                   # Primordial Forces & Upgrades)
  providers/       # 3 Riverpod providers (game, research, conquest logic)
  screens/         # 8 UI screens (Home, Buildings, Research, Conquest,
                   # Achievements, Prophecy, Reincarnation, Settings)
  widgets/         # 14 reusable widgets (cards, converters, panels,
                   # prophecy cards, primordial upgrade cards, patron selector)
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # 36 test files with comprehensive coverage
  e2e/           # End-to-end integration tests for all phases
```

## Test Coverage

- **Comprehensive test suite** covering all 5 phases
- 0 analyzer errors, 0 warnings
- Model tests for all game entities (GameState, Prophecy, Achievements, etc.)
- Provider tests for game logic, research, conquest, and prestige mechanics
- **Phase 5 integration tests**: 8 tests verifying Knowledge & Prophecy systems
- **62 achievement tests**: All 18 achievements with unlock conditions and rewards
- **UI widget tests** for all screens including Prophecy tab
- End-to-end integration tests for complete gameplay flows

## Phase 5 Highlights (Latest Update)

**Knowledge & Prophecy Systems:**
- **Athena (Goddess of Wisdom)** - Unlocks at 1M cats, introduces Wisdom resource
- **Apollo (God of Prophecy)** - Unlocks at 10M cats, enhances prophecy system
- **8 new buildings**: 4 for Athena (Hall of Wisdom, Academy of Athens, Strategy Chamber, Oracle's Archive), 4 for Apollo (Temple of Light, Oracle's Sanctum, Muse's Chamber, Delphic Treasury)
- **Prophecy System**: 10 unique prophecies with powerful timed boosts (production multipliers, instant resources, cost reductions)
- **Knowledge Research Branch**: 7 new research nodes enhancing Wisdom production and reducing costs
- **3 new territories**: Athens, Delphi, Alexandria (with Wisdom production bonuses up to +50%)
- **10 new achievements** with powerful rewards:
  - Flat production bonuses (+0.5 and +1.0 Wisdom/sec)
  - Percentage bonuses (+2% all resources, +5% Athena buildings, +10% Wisdom)
  - Cost reductions (-5% research, -10% conquest)
  - Cooldown reductions (-5% all prophecies, -30 minutes for Grand Vision)
  - Offline bonus (+25% offline cat production)

## Next Steps (Future Phases)

### Phase 6: Combat & War
- **Ares (God of War)** - Unlocks at 100M cats
- **Combat system** with battles and victories
- **War resources**: Might, Glory
- **Conquest enhancements** with combat mechanics
- **Competitive elements**

### Phase 7: Late Game Content
- **Gods 8-12**: Artemis (Hunting), Hephaestus (Crafting), Aphrodite (Influence), Poseidon (Seas), Zeus (Thunder)
- **Advanced systems**: Breeding, Artifacts, Random Events
- **Ascension to Olympus** endgame
- **Meta-progression** beyond reincarnation

## License

MIT
