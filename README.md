# Mythical Cats - Idle Game

A Flutter-based idle game where you play as a minor deity collecting mythical cats to ascend to Mount Olympus.

## Phase 1 MVP Features

- Click to perform rituals and summon cats
- Buy buildings that auto-generate cats
- First 3 generic building tiers (Small Shrine, Temple, Grand Sanctuary)
- God-specific buildings (Hermes' Messenger Waystation, Hestia's Hearth Altar)
- Tier 1 resources (Cats, Offerings, Prayers)
- Auto-save every 30 seconds
- Offline progression (up to 24 hours)
- First two gods unlocked (Hermes at start, Hestia at 1000 cats)

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
  models/          # Data models (GameState, Building, Resource, God)
  providers/       # Riverpod providers (game logic)
  screens/         # UI screens (Home, Buildings)
  widgets/         # Reusable widgets
  services/        # Save/load service
  utils/           # Number formatting utilities
test/              # Unit tests
```

## Next Steps (Future Phases)

- Add gods 3-4 (Demeter, Dionysus)
- Research/tech tree system (unlocked with Athena)
- Achievements
- Random events
- More building types
- Reincarnation/prestige system
