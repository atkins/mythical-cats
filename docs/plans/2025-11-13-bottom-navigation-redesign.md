# Bottom Navigation Redesign - iOS Style

**Date:** 2025-11-13
**Status:** Approved Design

## Overview

Redesign the app's navigation to follow modern iOS/Apple UI/UX guidelines by moving tabs from the top to a bottom navigation bar. This includes consolidating god-specific features and relocating achievements to reduce navigation complexity.

## Bottom Navigation Structure

The app will use a fixed iOS-style bottom navigation bar with 5 tabs, always visible:

1. **Home** (`home` icon) - Main dashboard with cat counter, ritual button, resources, prestige stats
2. **Buildings** (`apartment` icon) - Building purchase and management
3. **Divine Powers** (`auto_awesome` icon) - Consolidated god-specific features with internal segmented control
4. **Reincarnation** (`autorenew` icon) - Prestige system and achievements
5. **Settings** (`settings` icon) - Game settings

### Visual Styling
- iOS Standard style: icons on top, labels below
- Inactive tabs: gray (`Colors.grey`)
- Active tab: app accent color (amber)
- Standard iOS spacing and sizing (Material3 `NavigationBar` widget)
- Safe area respected at bottom

### Key Changes from Current
- Replace `DefaultTabController` + `TabBar` at top with `NavigationBar` at bottom
- Remove AppBar bottom property (tabs)
- Use `IndexedStack` to switch between screens instead of `TabBarView`
- Achievements relocated from dedicated tab to Reincarnation screen
- God-specific screens (Research, Conquest, Prophecy) consolidated into Divine Powers

## Divine Powers Screen (New)

### When Unlocked

**Header Section:**
- Title: "Divine Powers"
- iOS Segmented Control (`SegmentedButton`) showing unlocked gods:
  - "Research" (Athena) - when unlocked
  - "Conquest" (Ares) - when unlocked
  - "Prophecy" (Apollo) - when unlocked
- Tapping a segment switches the content below

**Content Area:**
- Shows the full screen content for the selected god (ResearchScreen, ConquestScreen, or ProphecyScreen widgets)
- Content area is scrollable independently
- Default selection: first unlocked god (or last selected, persisted)

### Pre-Unlock State (Teaser Content)

Before any gods are unlocked, the Divine Powers tab shows:
- Header: "Divine Powers" with subtitle "Unlock gods to access their powers"
- Cards for each god (Athena, Ares, Apollo) showing:
  - God icon/name
  - Brief description of their power domain
  - Unlock requirement (e.g., "Unlock Athena at 100M total cats")
  - Progress bar toward unlock
  - Grayed out/disabled appearance

### Implementation Details
- Use `SegmentedButton` widget (Material3 iOS-style segmented control)
- State management to track selected segment
- Conditional rendering based on unlocked gods

## Reincarnation Screen Updates

### Structure

The Reincarnation screen integrates achievements using internal segmented control:
- Segmented control at top: "Prestige | Achievements"
- **Prestige tab**: Existing reincarnation content (patron selection, upgrades, reincarnate button, PE stats)
- **Achievements tab**: Full achievements list from AchievementsScreen

### Pre-Unlock State (Teaser Content)

Before 1B total cats earned, the Reincarnation tab shows:
- Header: "Reincarnation"
- Explanation of the prestige system and its benefits
- Current progress toward 1B cats with progress bar
- Preview of what Primordial Essence does
- Teaser about patron gods and permanent upgrades
- Preview 1-2 locked achievements related to reincarnation

## Navigation State Management

### State Management Approach

Replace `DefaultTabController` with explicit state management:

**Selected Index State:**
- Use `StatefulWidget` to track `selectedBottomNavIndex` (0-4)
- Persist selected index optionally (or always default to Home on app restart)

**Screen Switching:**
- Use `IndexedStack` widget to preserve state across all 5 screens when switching tabs
  - Advantage: Screens maintain scroll position, form state, etc.
  - Trade-off: All 5 screens kept in memory
- Recommended approach for better UX

**Navigation Bar Implementation:**
```dart
NavigationBar(
  selectedIndex: selectedIndex,
  onDestinationSelected: (index) => setState(() => selectedIndex = index),
  destinations: [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.apartment), label: 'Buildings'),
    NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Divine Powers'),
    NavigationDestination(icon: Icon(Icons.autorenew), label: 'Reincarnation'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ],
)
```

**Deep Linking:**
- Update PrestigeStatsPanel tap handler to set `selectedBottomNavIndex = 3` instead of using `DefaultTabController.of(context).animateTo()`

## File Changes

### 1. lib/screens/home_screen.dart
- Remove `DefaultTabController`, `AppBar` with `TabBar`, and `TabBarView`
- Add `StatefulWidget` to manage `selectedBottomNavIndex`
- Replace `Scaffold` body with `IndexedStack` containing all 5 screens
- Add `NavigationBar` to `Scaffold.bottomNavigationBar`
- Remove dynamic tab building logic
- Update PrestigeStatsPanel navigation to use state update

### 2. lib/screens/divine_powers_screen.dart (new file)
- Create new screen for god-specific features
- Implement segmented control for Research/Conquest/Prophecy
- Handle pre-unlock teaser state with god preview cards
- Manage selected segment state

### 3. lib/screens/reincarnation_screen.dart
- Add segmented control at top: "Prestige | Achievements"
- Integrate AchievementsScreen content into Achievements tab
- Keep existing reincarnation UI in Prestige tab
- Handle pre-unlock teaser state

### 4. lib/screens/achievements_screen.dart
- Keep as-is, will be embedded in ReincarnationScreen
- Or refactor into reusable widget if needed

## Testing Considerations

- Update widget tests that reference tab navigation
- Test state preservation when switching bottom nav tabs
- Test deep linking from Home to Reincarnation tab
- Test pre-unlock teaser states for both Divine Powers and Reincarnation
- Test segmented control switching in both Divine Powers and Reincarnation

## Edge Cases

- Safe area handling on devices with bottom notches/home indicators
- Ensure NavigationBar doesn't overlap with content
- Handle very long tab labels (truncation)

## Benefits

1. **iOS Compliance**: Follows Apple's Human Interface Guidelines for bottom tab navigation
2. **Reduced Complexity**: Consolidating god features reduces max tabs from 8 to 5
3. **Better Discoverability**: Teaser content helps players understand what they're working toward
4. **Improved UX**: Bottom navigation is easier to reach on mobile devices
5. **State Preservation**: IndexedStack maintains screen state when switching tabs
