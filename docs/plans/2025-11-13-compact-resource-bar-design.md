# Compact Resource Bar for Buildings Tab - Design Document

**Date:** 2025-11-13
**Status:** Approved
**Author:** User + Claude Code

## Overview

Add a compact, sticky resource display bar to the Buildings tab, showing current resource values and production rates to help players make informed purchasing decisions without switching tabs.

## User Story

As a player browsing buildings to purchase, I want to see my current resources and production rates at a glance, so I can make purchasing decisions without switching back to the Home tab.

## Design Goals

1. **Visibility**: Resources always visible while browsing buildings
2. **Compactness**: Minimal vertical space usage to maximize building list visibility
3. **Informativeness**: Show both current values and production rates
4. **Consistency**: Use existing formatting patterns and visual style
5. **Progressive disclosure**: Show advanced resources only when relevant

## Architecture

### Component Structure

**New Widget:** `CompactResourceBar` (`lib/widgets/compact_resource_bar.dart`)
- ConsumerWidget that watches `gameProvider`
- Displays resources in horizontal format with production rates
- Handles responsive wrapping for narrow screens

**BuildingsScreen Modification:**
Change layout from simple ListView to Column structure:
```dart
body: Column(
  children: [
    const CompactResourceBar(),  // Sticky at top
    Expanded(
      child: ListView.builder(...),  // Existing scrollable content
    ),
  ],
)
```

### Data Flow

1. CompactResourceBar watches `gameProvider`
2. Reads current resource values via `gameState.getResource(ResourceType)`
3. Reads production rates via helper methods (see below)
4. Formats values using `NumberFormatter.format()` and `NumberFormatter.formatRate()`
5. Conditionally displays resources based on unlock status

## Visual Design

### Layout Specifications

**Container:**
- Background: `Theme.of(context).colorScheme.surfaceContainerHighest`
- Padding: Horizontal 16px, Vertical 12px
- Height: Auto-sized (~44-48px)
- Border: Subtle bottom border or shadow for separation

**Resource Display Format:**
```
🐱 1.2K (+10/s) | 🙏 500 (+2/s) | 🎁 100 (+0.5/s) | ✨ 50 (+1/s)
```

**Typography:**
- Font size: `textTheme.bodySmall`
- Color: Default text at 87% opacity (subtle)
- Dividers: `|` character at 50% opacity
- Spacing: 12-16px between resources

**Responsive Behavior:**
- Uses `Wrap` widget for automatic line breaking
- Wide screens: Single horizontal row
- Narrow screens: Wraps to multiple lines as needed

## Resource Display Logic

### Always Visible (Core Resources)
1. **Cats** 🐱 - Primary currency
2. **Prayers** 🙏 - Secondary currency
3. **Offerings** 🎁 - Tertiary currency

### Conditionally Visible (if value > 0)
4. **Divine Essence** ✨ - Mid-game resource
5. **Ambrosia** 🍯 - Late-game resource
6. **Wisdom** 🦉 - Phase 5 resource

### Not Displayed
- **Conquest Points** - Not used for building purchases

## Production Rate Calculation

### Implementation Options

**Option A: Add helper methods to GameProvider**
```dart
double getPrayersPerSecond() { ... }
double getOfferingsPerSecond() { ... }
double getDivineEssencePerSecond() { ... }
double getAmbrosiaPerSecond() { ... }
double getWisdomPerSecond() { ... }
```

**Option B: Calculate inline in CompactResourceBar**
Access building counts and production definitions directly in the widget.

**Decision:** Use Option A - Centralizes production logic in GameProvider, making it reusable and testable.

### Production Rate Sources

- **Cats/s**: Existing `getCatsPerSecond()` method
- **Prayers/s**: From Small Shrines, Temples, Grand Sanctuaries
- **Offerings/s**: From god-specific buildings
- **Divine Essence/s**: From Essence Refineries
- **Ambrosia/s**: From Nectar Breweries
- **Wisdom/s**: From Athena/Apollo buildings (Halls of Wisdom, etc.)

## Implementation Details

### File Structure

```
lib/
  widgets/
    compact_resource_bar.dart (NEW)
  screens/
    buildings_screen.dart (MODIFIED)
  providers/
    game_provider.dart (MODIFIED - add production rate helpers)
test/
  widgets/
    compact_resource_bar_test.dart (NEW)
  screens/
    buildings_screen_test.dart (MODIFIED)
```

### Key Implementation Points

1. **CompactResourceBar Widget:**
   - Stateless ConsumerWidget
   - No parameters needed (gets all from provider)
   - Uses Wrap for responsive layout
   - Builds list of visible resources dynamically

2. **BuildingsScreen Integration:**
   - Minimal change to body: wrap in Column
   - CompactResourceBar at top
   - Existing ListView wrapped in Expanded

3. **GameProvider Additions:**
   - Add production rate helper methods
   - Follow same pattern as getCatsPerSecond()
   - Calculate from building counts and definitions

## Testing Strategy

### Unit Tests

**CompactResourceBar Widget Tests:**
1. Displays core resources (Cats, Prayers, Offerings) always
2. Conditionally shows Divine Essence when > 0
3. Conditionally shows Ambrosia when > 0
4. Conditionally shows Wisdom when > 0
5. Formats large numbers correctly (K/M/B notation)
6. Displays production rates in "+X/s" format
7. Handles zero production rates (shows "+0/s")

**GameProvider Tests:**
Add tests for new production rate methods:
1. `getPrayersPerSecond()` calculates correctly
2. `getOfferingsPerSecond()` calculates correctly
3. `getDivineEssencePerSecond()` calculates correctly
4. `getAmbrosiaPerSecond()` calculates correctly
5. `getWisdomPerSecond()` calculates correctly

### Integration Tests

**BuildingsScreen Tests:**
1. CompactResourceBar is present in widget tree
2. ListView renders below CompactResourceBar
3. Scrolling behavior works correctly
4. Resource bar stays visible during scroll

## Edge Cases

1. **Zero production rates**: Display "+0/s" for consistency
2. **Negative rates**: Would naturally show "-X/s" (shouldn't occur in game)
3. **Very large numbers**: Handled by existing NumberFormatter
4. **Narrow screens**: Wrap widget handles line breaking automatically
5. **Early game (no advanced resources)**: Only shows core 3 resources cleanly
6. **No buildings owned**: Shows "+0/s" for all rates

## Performance Considerations

- CompactResourceBar watches gameProvider (updates frequently via game loop)
- This is acceptable because:
  - Widget is simple with minimal rendering cost
  - Only rebuilds the small resource bar, not the entire ListView
  - Same pattern as ResourcePanel on Home tab (proven performant)
  - Flutter's widget rebuild optimization handles this efficiently

## Future Enhancements

(Not included in initial implementation)

1. **Tap to highlight**: Tap a resource to highlight buildings that cost that resource
2. **Color coding**: Show resources in red when low, green when abundant
3. **Sparkle animation**: Subtle animation when resources increase
4. **Expanded view**: Tap to expand and show more detailed stats
5. **Settings toggle**: Option to show/hide production rates

## Design Rationale

### Why not use full ResourcePanel?
- Too much vertical space for a secondary screen
- Compact bar is more appropriate for utility/reference display

### Why show production rates?
- Helps players understand if they should wait for resources to accumulate
- Provides context for opportunity cost of purchases

### Why sticky at top?
- Players need constant visibility while browsing buildings
- Eliminates need to scroll back up to check resources

### Why Smart 5 resources?
- Balances simplicity (not overwhelming) with completeness
- Progressive disclosure: advanced resources appear when relevant
- Covers all resources used in building purchases

## Success Metrics

- Players spend less time switching between Home and Buildings tabs
- Improved user experience when making building purchase decisions
- No negative performance impact from frequent updates
- Seamless integration with existing UI patterns

## Accessibility

- Text contrast meets WCAG AA standards
- Font size appropriate for readability
- Emojis have semantic meaning but text labels provide clarity
- Screen readers can announce resource values and rates

## Conclusion

The compact resource bar provides a lightweight, always-visible reference for resources while browsing buildings, improving the user experience without cluttering the interface or requiring architectural changes to the app structure.
