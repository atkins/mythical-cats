# Phase 4: Prestige System UI - Design Document

**Date**: 2025-11-11
**Status**: Approved
**Backend**: Complete (all models, business logic, and tests implemented)

## Overview

Design for the Phase 4 Prestige/Reincarnation System UI, allowing players to reset their game progress after reaching 1 billion cats to earn Primordial Essence (PE), purchase permanent upgrades across 4 primordial forces, and select an active patron for temporary bonuses.

## Screen Architecture

### Tab Unlock

The Reincarnation screen unlocks as a new tab when `totalCatsEarned >= 1,000,000,000` (1 billion cats).

**Pattern consistency:**
- Athena unlock (1K cats) → Research tab
- Ares unlock (100K cats) → Conquest tab
- 1B cats milestone → Reincarnation tab

**Tab configuration:**
- Icon: `Icons.autorenew` or `Icons.loop`
- Label: "Reincarnation"
- Added to `home_screen.dart` tab list conditionally

### File Structure

New files to create:

```
lib/screens/reincarnation_screen.dart          # Main screen
lib/widgets/patron_selector.dart               # Patron switching header
lib/widgets/primordial_force_section.dart      # Force section with upgrades
lib/widgets/primordial_upgrade_card.dart       # Individual upgrade card
lib/widgets/reincarnation_fab.dart             # Floating action button
lib/widgets/prestige_stats_panel.dart          # Home screen stats display
```

## Component Designs

### 1. Patron Selector (Header)

**Location**: Top of Reincarnation screen

**Layout:**
- Title: "Active Patron"
- Current patron display: Icon + name + bonuses
- 4 force buttons in horizontal row
- Each button: Force icon, name, "Active" badge if selected
- Active patron bonus text below: "⚡ Chaos: +150% click power, +60% patron bonus"

**Interaction:**
- Tap any force button to switch active patron immediately (no confirmation)
- Active patron: Highlighted border/background with force color
- Disabled state: If no upgrades owned in force, grayed out with "No upgrades owned"

**Data binding:**
```dart
final activePatron = gameState.reincarnationState.activePatron;
final ownedUpgrades = gameState.reincarnationState.ownedUpgradeIds;
// Call: gameNotifier.setActivePatron(PrimordialForce.chaos)
```

**Styling:**
- Force colors: Chaos=purple, Gaia=green, Nyx=indigo, Erebus=amber
- Card with elevation (similar to Resource Panel)
- Height: ~100-120px

### 2. Primordial Force Section

**Structure**: Vertical scrolling list of 4 force sections (Chaos, Gaia, Nyx, Erebus)

**Each section contains:**

**Section Header:**
- Force icon + name (e.g., "⚡ Chaos")
- Force description (e.g., "Active Play - Click Power")
- Progress: "3/5 upgrades owned"
- Colored divider line

**Upgrade Display:**
- 5 upgrade cards per force
- Arranged in horizontal scrollable row OR 2-3 per row if wrapping
- Order: Tier 1 → Tier 5 (left to right)

### 3. Primordial Upgrade Card

**Card dimensions**: ~140px width × ~160px height

**Visual States:**

1. **Owned**:
   - Filled background (force color)
   - Checkmark icon
   - "Owned" text instead of button

2. **Affordable** (can purchase):
   - White background
   - Highlighted border (force color)
   - Enabled "Purchase" button

3. **Locked** (missing prerequisite):
   - Grayed out
   - Lock icon
   - "Requires Tier X" text
   - Disabled button

4. **Unaffordable** (insufficient PE):
   - Normal colors
   - Disabled "Purchase" button with cost

**Card Content:**
- Tier badge (top-right): "Tier 3"
- Name: "Chaos III: Ritual Mastery"
- Effect: "+50% click power"
- Cost: "50 PE"
- Action: "Purchase" button or "Owned" checkmark

**Pattern**: Similar to `building_card.dart` but more compact

### 4. Reincarnation FAB (Floating Action Button)

**Position**: Bottom-right corner (standard FAB position), stays visible while scrolling

**Display:**
- Extended FAB (icon + text)
- Icon: `Icons.autorenew`
- Text: "Reincarnate for X PE" (live calculation)
- Background: Purple/blue gradient with mystical feel

**States:**

1. **Enabled** (`totalCatsEarned >= 1B`):
   - Shows calculated PE from `gameNotifier.calculatePrimordialEssence()`
   - Pulsing animation to draw attention
   - Tappable

2. **Disabled** (below threshold):
   - Grayed out
   - Text: "Need 1B cats (X remaining)"
   - Not tappable

**Action**: Opens confirmation dialog

### 5. Reincarnation Confirmation Dialog

**Trigger**: Tap Reincarnation FAB

**Dialog Layout:**

**Title**: "Reincarnate?"

**Content sections:**

1. **You will gain:**
   - "+20 Primordial Essence" (calculated from current run)

2. **Active patron:**
   - "⚡ Chaos" (shows currently selected patron from header)

3. **You will reset:**
   ```
   • Cats, Offerings, Prayers, Divine Essence, Ambrosia
   • All Buildings
   • God unlocks (except Hermes)
   • Conquered territories
   ```

4. **You will keep:**
   ```
   • Research progress
   • Achievements
   • Primordial upgrades
   • Total PE earned
   ```

**Buttons:**
- "Cancel" (gray, left)
- "Reincarnate" (purple, prominent, right)

**Action**: Calls `gameNotifier.reincarnate(selectedPatron)`

### 6. Prestige Stats Panel (Home Screen)

**Location**: Home tab, between Resource Panel and Ritual Button

**Visibility:**
- Hidden before first reincarnation OR shows teaser: "Unlock reincarnation at 1B cats" with progress bar
- Visible after first reincarnation

**Display:**

Card showing:
- **Header**: "Prestige Progress" with autorenew icon
- **Row 1**: "Available PE: 45 / 120 Total"
- **Row 2**: "Reincarnations: 3"
- **Active Patron section**:
  - Force icon + name (colored background)
  - Bonus text: "+150% click power, +60% patron bonus"
  - Small "Change" button

**Styling:**
- Similar to Quick Stats card
- Accent/border uses active patron color
- Height: ~100-120px when collapsed
- Optional: Collapsible to save screen space

**Interaction:**
- Tap card → Navigate to Reincarnation tab
- Tap "Change" → Navigate to Reincarnation tab focused on patron selector

## Data Flow

### Reading State

```dart
// Access reincarnation state
final reincState = gameState.reincarnationState;

// Key properties
final availablePE = reincState.availablePrimordialEssence;
final totalPE = reincState.totalPrimordialEssence;
final ownedUpgrades = reincState.ownedUpgradeIds;
final activePatron = reincState.activePatron;
final reincarnations = reincState.totalReincarnations;
```

### Actions

```dart
// Calculate PE preview
final peEarned = gameNotifier.calculatePrimordialEssence(
  gameState.totalCatsEarned
);

// Purchase upgrade
gameNotifier.purchasePrimordialUpgrade('chaos_1');

// Check if can purchase
final canBuy = gameNotifier.canPurchasePrimordialUpgrade('chaos_2');

// Switch patron (no method needed yet - will add)
// gameNotifier.setActivePatron(PrimordialForce.gaia);

// Reincarnate
gameNotifier.reincarnate(PrimordialForce.chaos);
```

## Implementation Notes

### New Provider Method Needed

Add to `game_provider.dart`:

```dart
void setActivePatron(PrimordialForce patron) {
  state = state.copyWith(
    reincarnationState: state.reincarnationState.copyWith(
      activePatron: patron,
    ),
  );
}
```

### Tab Unlock Logic

Add to `home_screen.dart`:

```dart
final hasReincarnation = gameState.totalCatsEarned >= 1000000000;

// In tabs list:
if (hasReincarnation)
  const Tab(icon: Icon(Icons.autorenew), text: 'Reincarnation'),

// In tab views:
if (hasReincarnation) const ReincarnationScreen(),
```

### Color Palette

```dart
// Force colors
const chaosColor = Colors.deepPurple;
const gaiaColor = Colors.green;
const nyxColor = Colors.indigo;
const erebusColor = Colors.amber;
```

### Upgrade Definition Access

```dart
// Get upgrade details
final upgrade = PrimordialUpgradeDefinitions.getById('chaos_1');
// Returns: PrimordialUpgrade with id, force, tier, cost, name, effect

// Get all upgrades for a force
final chaosUpgrades = PrimordialUpgradeDefinitions.getForceUpgrades(
  PrimordialForce.chaos
);
```

## Testing Strategy

### Widget Tests

1. **PatronSelector**:
   - Shows all 4 forces
   - Highlights active patron
   - Disables forces with no upgrades
   - Calls setActivePatron on tap

2. **PrimordialUpgradeCard**:
   - Displays owned state correctly
   - Disables when locked/unaffordable
   - Shows prerequisite message
   - Calls purchasePrimordialUpgrade on tap

3. **ReincarnationFab**:
   - Calculates PE correctly
   - Disables below 1B threshold
   - Shows dialog on tap

4. **PrestigeStatsPanel**:
   - Hidden before first reincarnation
   - Shows correct stats after reincarnation
   - Navigates to Reincarnation tab on tap

### Integration Tests

1. Full reincarnation flow: browse upgrades → select patron → reincarnate → verify reset
2. Upgrade purchase flow: earn PE → purchase upgrades → verify bonuses apply
3. Patron switching: change patron → verify bonuses update

## UI/UX Principles

1. **Progressive disclosure**: Only show Reincarnation tab when relevant (1B cats)
2. **Clear consequences**: Confirmation dialog explicitly shows what resets and what persists
3. **Visual feedback**: Colors, states, and animations make upgrade status clear
4. **Consistency**: Follow existing patterns (cards, tabs, color scheme)
5. **Mobile-first**: Scrollable content, touch-friendly buttons, readable text sizes

## Success Metrics

UI is successful when:
- Players understand what reincarnation does before triggering it
- Upgrade purchase decisions are clear (owned/affordable/locked states)
- Patron switching is discoverable and easy
- Prestige progress feels rewarding and visible

## Future Enhancements (Post-MVP)

- Animations: Particle effects on reincarnation, upgrade purchase celebrations
- Tooltips: Long-press upgrades to see detailed effect breakdowns
- Comparison mode: Preview how different patrons would affect current production
- Preset loadouts: Save favorite patron/upgrade combinations
- Reincarnation history: Track PE earned per run, fastest runs, etc.
