# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Phase 2 Features (Current)

**Core Gameplay:**
- Click to perform rituals and summon cats
- Buy buildings that auto-generate cats, offerings, and prayers
- 7 building types (3 generic + 4 god-specific)
- First 4 gods unlocked (Hermes at start, Hestia at 1K, Demeter at 10K, Dionysus at 100K cats)
- Tier 1 resources: Cats, Offerings, Prayers

**Progression Systems:**
- Auto-save every 30 seconds
- Offline progression (up to 24 hours)
- Achievement system with 8 achievements granting permanent bonuses
- Statistics tracking (total cats, buildings, gods, achievements)

**UI/UX:**
- Mobile-first Material 3 design
- 4 tabs: Home, Buildings, Achievements, Settings
- Number formatting for large values
- Achievement progress tracking

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
  models/          # Data models (GameState, Building, Resource, God, Achievement)
  providers/       # Riverpod providers (game logic)
  screens/         # UI screens (Home, Buildings, Achievements, Settings)
  widgets/         # Reusable widgets
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # Unit and integration tests
```

## Next Steps (Future Phases)

### Phase 3: Mid-Game Systems
- Research/tech tree system (unlocked with Athena)
- Gods 5-8 with unique mechanics
- Tier 2 resources (Divine Essence, Ambrosia)
- Functional buildings (Workshops, Academies)
- Random events system

### Phase 4: Prestige System
- Reincarnation mechanic
- Primordial forces and skill trees
- Persistent upgrades across runs

### Phase 5: Late Game Content
- Gods 9-12 (Hephaestus through Zeus)
- Advanced systems (breeding, artifacts, conquest)
- Ascension to Olympus endgame

## Live Demo

Play now: https://atkins.github.io/mythical-cats/

## License

MIT
