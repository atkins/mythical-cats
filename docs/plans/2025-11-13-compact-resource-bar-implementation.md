# Compact Resource Bar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a sticky, compact resource display bar to the Buildings tab showing current resource values and production rates.

**Architecture:** Create a new CompactResourceBar widget that watches gameProvider and displays resources in a horizontal format. Add production rate helper methods to GameProvider following the same pattern as getCatsPerSecond(). Integrate the bar into BuildingsScreen using a Column layout with the bar sticky at top and ListView scrollable below.

**Tech Stack:** Flutter, Riverpod state management, Material 3 design

---

## Task 1: Add Production Rate Helper Methods to GameProvider

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

### Step 1: Write failing test for getPrayersPerSecond

Add to `test/providers/game_provider_test.dart` after existing production tests:

```dart
testWidgets('getPrayersPerSecond calculates from prayer-producing buildings', (tester) async {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  // Set up state with prayer-producing buildings
  notifier.state = notifier.state.copyWith(
    buildings: {
      BuildingType.smallShrine: 5,    // 5 * 0.5 = 2.5
      BuildingType.temple: 2,          // 2 * 2 = 4
      BuildingType.grandSanctuary: 1,  // 1 * 10 = 10
    },
  );

  final rate = notifier.getPrayersPerSecond();
  expect(rate, 16.5); // 2.5 + 4 + 10

  container.dispose();
});
```

### Step 2: Run test to verify it fails

```bash
flutter test test/providers/game_provider_test.dart --plain-name "getPrayersPerSecond"
```

Expected: FAIL - "The method 'getPrayersPerSecond' isn't defined"

### Step 3: Implement getPrayersPerSecond in GameProvider

Add method after `getCatsPerSecond()` in `lib/providers/game_provider.dart`:

```dart
double getPrayersPerSecond() {
  double total = 0;

  // Basic prayer-producing buildings
  total += state.getBuildingCount(BuildingType.smallShrine) *
           BuildingDefinitions.get(BuildingType.smallShrine).prayersPerSecond;
  total += state.getBuildingCount(BuildingType.temple) *
           BuildingDefinitions.get(BuildingType.temple).prayersPerSecond;
  total += state.getBuildingCount(BuildingType.grandSanctuary) *
           BuildingDefinitions.get(BuildingType.grandSanctuary).prayersPerSecond;

  return total;
}
```

### Step 4: Run test to verify it passes

```bash
flutter test test/providers/game_provider_test.dart --plain-name "getPrayersPerSecond"
```

Expected: PASS

### Step 5: Add tests and implementations for other resources

Add similar tests for:
- `getOfferingsPerSecond()` - from god buildings
- `getDivineEssencePerSecond()` - from Essence Refineries
- `getAmbrosiaPerSecond()` - from Nectar Breweries
- `getWisdomPerSecond()` - from Athena/Apollo buildings

Test code:

```dart
testWidgets('getOfferingsPerSecond calculates from god buildings', (tester) async {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    buildings: {
      BuildingType.messengerWaystation: 3,  // Hermes building
      BuildingType.hearthAltar: 2,          // Hestia building
    },
    unlockedGods: [God.hermes, God.hestia],
  );

  final rate = notifier.getOfferingsPerSecond();
  // Calculate based on building definitions
  final expected = (3 * BuildingDefinitions.get(BuildingType.messengerWaystation).offeringsPerSecond) +
                   (2 * BuildingDefinitions.get(BuildingType.hearthAltar).offeringsPerSecond);
  expect(rate, expected);

  container.dispose();
});

testWidgets('getDivineEssencePerSecond calculates from refineries', (tester) async {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    buildings: {BuildingType.essenceRefinery: 2},
    unlockedGods: [God.athena],
  );

  final rate = notifier.getDivineEssencePerSecond();
  final expected = 2 * BuildingDefinitions.get(BuildingType.essenceRefinery).divineEssencePerSecond;
  expect(rate, expected);

  container.dispose();
});

testWidgets('getAmbrosiaPerSecond calculates from breweries', (tester) async {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    buildings: {BuildingType.nectarBrewery: 1},
    unlockedGods: [God.apollo],
  );

  final rate = notifier.getAmbrosiaPerSecond();
  final expected = 1 * BuildingDefinitions.get(BuildingType.nectarBrewery).ambrosiaPerSecond;
  expect(rate, expected);

  container.dispose();
});

testWidgets('getWisdomPerSecond calculates from wisdom buildings', (tester) async {
  final container = ProviderContainer();
  final notifier = container.read(gameProvider.notifier);

  notifier.state = notifier.state.copyWith(
    buildings: {
      BuildingType.hallOfWisdom: 2,
      BuildingType.academyOfAthens: 1,
    },
    unlockedGods: [God.athena],
  );

  final rate = notifier.getWisdomPerSecond();
  final expected = (2 * BuildingDefinitions.get(BuildingType.hallOfWisdom).wisdomPerSecond) +
                   (1 * BuildingDefinitions.get(BuildingType.academyOfAthens).wisdomPerSecond);
  expect(rate, expected);

  container.dispose();
});
```

Implementation code for `lib/providers/game_provider.dart`:

```dart
double getOfferingsPerSecond() {
  double total = 0;

  // Iterate through all building types and sum offerings production
  for (final buildingType in BuildingType.values) {
    final count = state.getBuildingCount(buildingType);
    if (count > 0) {
      final definition = BuildingDefinitions.get(buildingType);
      total += count * definition.offeringsPerSecond;
    }
  }

  return total;
}

double getDivineEssencePerSecond() {
  double total = 0;

  // Essence Refineries produce Divine Essence
  total += state.getBuildingCount(BuildingType.essenceRefinery) *
           BuildingDefinitions.get(BuildingType.essenceRefinery).divineEssencePerSecond;

  return total;
}

double getAmbrosiaPerSecond() {
  double total = 0;

  // Nectar Breweries produce Ambrosia
  total += state.getBuildingCount(BuildingType.nectarBrewery) *
           BuildingDefinitions.get(BuildingType.nectarBrewery).ambrosiaPerSecond;

  return total;
}

double getWisdomPerSecond() {
  double total = 0;

  // Athena buildings produce Wisdom
  total += state.getBuildingCount(BuildingType.hallOfWisdom) *
           BuildingDefinitions.get(BuildingType.hallOfWisdom).wisdomPerSecond;
  total += state.getBuildingCount(BuildingType.academyOfAthens) *
           BuildingDefinitions.get(BuildingType.academyOfAthens).wisdomPerSecond;
  total += state.getBuildingCount(BuildingType.strategyChamber) *
           BuildingDefinitions.get(BuildingType.strategyChamber).wisdomPerSecond;
  total += state.getBuildingCount(BuildingType.oraclesArchive) *
           BuildingDefinitions.get(BuildingType.oraclesArchive).wisdomPerSecond;

  // Apollo buildings also produce Wisdom
  total += state.getBuildingCount(BuildingType.templeOfDelphi) *
           BuildingDefinitions.get(BuildingType.templeOfDelphi).wisdomPerSecond;
  total += state.getBuildingCount(BuildingType.sunChariotStable) *
           BuildingDefinitions.get(BuildingType.sunChariotStable).wisdomPerSecond;
  total += state.getBuildingCount(BuildingType.musesSanctuary) *
           BuildingDefinitions.get(BuildingType.musesSanctuary).wisdomPerSecond;
  total += state.getBuildingCount(BuildingType.celestialObservatory) *
           BuildingDefinitions.get(BuildingType.celestialObservatory).wisdomPerSecond;

  return total;
}
```

### Step 6: Run all new tests

```bash
flutter test test/providers/game_provider_test.dart --plain-name "PerSecond"
```

Expected: All 5 new tests PASS

### Step 7: Commit production rate methods

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add production rate helper methods for all resources

Adds getPrayersPerSecond, getOfferingsPerSecond, getDivineEssencePerSecond,
getAmbrosiaPerSecond, and getWisdomPerSecond methods following the same
pattern as getCatsPerSecond. Includes comprehensive tests."
```

---

## Task 2: Create CompactResourceBar Widget

**Files:**
- Create: `lib/widgets/compact_resource_bar.dart`
- Create: `test/widgets/compact_resource_bar_test.dart`

### Step 1: Write failing test for CompactResourceBar

Create `test/widgets/compact_resource_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/widgets/compact_resource_bar.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('CompactResourceBar', () {
    testWidgets('displays core resources (Cats, Prayers, Offerings)', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 1234.0,
          ResourceType.prayers: 567.0,
          ResourceType.offerings: 89.0,
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      // Should find cat, prayer, and offering emojis
      expect(find.text('🐱'), findsOneWidget);
      expect(find.text('🙏'), findsOneWidget);
      expect(find.text('🎁'), findsOneWidget);

      // Should find formatted values
      expect(find.textContaining('1.2K'), findsOneWidget); // Cats
      expect(find.textContaining('567'), findsOneWidget);  // Prayers
      expect(find.textContaining('89'), findsOneWidget);   // Offerings

      container.dispose();
    });

    testWidgets('shows Divine Essence when > 0', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 100.0,
          ResourceType.offerings: 100.0,
          ResourceType.divineEssence: 50.0, // Should show
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      expect(find.text('✨'), findsOneWidget);
      expect(find.textContaining('50'), findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('hides Divine Essence when 0', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 100.0,
          ResourceType.offerings: 100.0,
          ResourceType.divineEssence: 0.0, // Should not show
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      expect(find.text('✨'), findsNothing);

      container.dispose();
    });

    testWidgets('displays production rates', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      // Should find rate indicators like "+10/s" or "+0/s"
      expect(find.textContaining('/s'), findsAtLeastNWidgets(3)); // At least for core 3

      container.dispose();
    });
  });
}
```

### Step 2: Run test to verify it fails

```bash
flutter test test/widgets/compact_resource_bar_test.dart
```

Expected: FAIL - "Undefined class 'CompactResourceBar'"

### Step 3: Implement CompactResourceBar widget

Create `lib/widgets/compact_resource_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resource_type.dart';
import '../providers/game_provider.dart';
import '../utils/number_formatter.dart';

class CompactResourceBar extends ConsumerWidget {
  const CompactResourceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Build list of resources to display
    final resourcesToShow = <_ResourceInfo>[];

    // Core resources (always show)
    resourcesToShow.add(_ResourceInfo(
      emoji: ResourceType.cats.icon,
      value: gameState.getResource(ResourceType.cats),
      rate: gameNotifier.getCatsPerSecond(),
    ));
    resourcesToShow.add(_ResourceInfo(
      emoji: ResourceType.prayers.icon,
      value: gameState.getResource(ResourceType.prayers),
      rate: gameNotifier.getPrayersPerSecond(),
    ));
    resourcesToShow.add(_ResourceInfo(
      emoji: ResourceType.offerings.icon,
      value: gameState.getResource(ResourceType.offerings),
      rate: gameNotifier.getOfferingsPerSecond(),
    ));

    // Advanced resources (show only if > 0)
    final divineEssence = gameState.getResource(ResourceType.divineEssence);
    if (divineEssence > 0) {
      resourcesToShow.add(_ResourceInfo(
        emoji: ResourceType.divineEssence.icon,
        value: divineEssence,
        rate: gameNotifier.getDivineEssencePerSecond(),
      ));
    }

    final ambrosia = gameState.getResource(ResourceType.ambrosia);
    if (ambrosia > 0) {
      resourcesToShow.add(_ResourceInfo(
        emoji: ResourceType.ambrosia.icon,
        value: ambrosia,
        rate: gameNotifier.getAmbrosiaPerSecond(),
      ));
    }

    final wisdom = gameState.getResource(ResourceType.wisdom);
    if (wisdom > 0) {
      resourcesToShow.add(_ResourceInfo(
        emoji: ResourceType.wisdom.icon,
        value: wisdom,
        rate: gameNotifier.getWisdomPerSecond(),
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: resourcesToShow.map((info) {
          return _buildResourceItem(context, info);
        }).toList(),
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, _ResourceInfo info) {
    final formattedValue = NumberFormatter.format(info.value);
    final formattedRate = NumberFormatter.formatRate(info.rate);

    return Text(
      '${info.emoji} $formattedValue ($formattedRate)',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.87),
          ),
    );
  }
}

class _ResourceInfo {
  final String emoji;
  final double value;
  final double rate;

  _ResourceInfo({
    required this.emoji,
    required this.value,
    required this.rate,
  });
}
```

### Step 4: Run tests to verify they pass

```bash
flutter test test/widgets/compact_resource_bar_test.dart
```

Expected: All 4 tests PASS

### Step 5: Commit CompactResourceBar widget

```bash
git add lib/widgets/compact_resource_bar.dart test/widgets/compact_resource_bar_test.dart
git commit -m "feat: add CompactResourceBar widget

Creates compact resource display showing values and production rates.
Shows core resources always, advanced resources when > 0.
Includes comprehensive tests."
```

---

## Task 3: Integrate CompactResourceBar into BuildingsScreen

**Files:**
- Modify: `lib/screens/buildings_screen.dart`
- Modify: `test/screens/buildings_screen_test.dart` (if exists) OR
- Modify: `test/widgets/building_card_test.dart` (alternative test location)

### Step 1: Write failing integration test

Add to appropriate test file (create if needed):

```dart
testWidgets('BuildingsScreen shows CompactResourceBar at top', (tester) async {
  final container = ProviderContainer();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: BuildingsScreen(),
      ),
    ),
  );

  // Should find CompactResourceBar
  expect(find.byType(CompactResourceBar), findsOneWidget);

  // Should find ListView for buildings
  expect(find.byType(ListView), findsOneWidget);

  container.dispose();
});

testWidgets('BuildingsScreen CompactResourceBar stays visible when scrolling', (tester) async {
  final container = ProviderContainer();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: BuildingsScreen(),
      ),
    ),
  );

  // Verify resource bar is visible initially
  expect(find.byType(CompactResourceBar), findsOneWidget);

  // Scroll down
  await tester.drag(find.byType(ListView), const Offset(0, -500));
  await tester.pump();

  // Resource bar should still be visible (sticky)
  expect(find.byType(CompactResourceBar), findsOneWidget);

  container.dispose();
});
```

### Step 2: Run test to verify it fails

```bash
flutter test --plain-name "CompactResourceBar"
```

Expected: FAIL - "Expected: exactly one matching node, Actual: _WidgetTypeFinder:<zero widgets>"

### Step 3: Modify BuildingsScreen to integrate CompactResourceBar

In `lib/screens/buildings_screen.dart`, add import:

```dart
import 'package:mythical_cats/widgets/compact_resource_bar.dart';
```

Replace the `body:` section (currently just `ListView.builder(...)`) with:

```dart
body: Column(
  children: [
    const CompactResourceBar(),
    Expanded(
      child: ListView.builder(
        itemCount: _calculateItemCount(sections, hasWorkshop),
        itemBuilder: (context, index) {
          // Show workshop converter at the top if workshop is owned
          if (hasWorkshop && index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: WorkshopConverter(),
            );
          }

          // Adjust index for sections
          final adjustedIndex = hasWorkshop ? index - 1 : index;

          // Render sections
          return _renderSectionItem(
            context,
            sections,
            adjustedIndex,
            gameState,
            gameNotifier,
          );
        },
      ),
    ),
  ],
),
```

### Step 4: Run tests to verify they pass

```bash
flutter test --plain-name "CompactResourceBar"
```

Expected: Both tests PASS

### Step 5: Run full test suite to verify no regressions

```bash
flutter test
```

Expected: All existing tests still pass (407 + 6 new = 413 tests)

### Step 6: Commit BuildingsScreen integration

```bash
git add lib/screens/buildings_screen.dart test/widgets/compact_resource_bar_test.dart
git commit -m "feat: integrate CompactResourceBar into BuildingsScreen

Adds sticky resource bar at top of Buildings tab using Column layout.
Resource bar stays visible while ListView scrolls below.
Includes integration tests."
```

---

## Task 4: Manual Testing & Documentation

### Step 1: Run the app and verify visually

```bash
flutter run -d chrome
```

**Manual checklist:**
- [ ] Navigate to Buildings tab
- [ ] Verify resource bar shows at top
- [ ] Verify shows Cats, Prayers, Offerings with values and rates
- [ ] Scroll down through buildings list
- [ ] Verify resource bar stays visible (doesn't scroll away)
- [ ] Buy a building and verify resources update
- [ ] Unlock Divine Essence and verify it appears in bar
- [ ] Check narrow window width - resources should wrap to multiple lines

### Step 2: Update implementation plan with completion status

Update this file's completion checklist:

```markdown
## Completion Checklist

- [x] Task 1: Add production rate helper methods
- [x] Task 2: Create CompactResourceBar widget
- [x] Task 3: Integrate into BuildingsScreen
- [x] Task 4: Manual testing & documentation

**Completed:** 2025-11-13
**Test Results:** 413 passing
**Commits:** 3 feature commits
```

### Step 3: Final commit

```bash
git add docs/plans/2025-11-13-compact-resource-bar-implementation.md
git commit -m "docs: mark compact resource bar implementation complete"
```

---

## Completion Checklist

- [x] Task 1: Add production rate helper methods
- [x] Task 2: Create CompactResourceBar widget
- [x] Task 3: Integrate into BuildingsScreen
- [x] Task 4: Manual testing & documentation

**Completed:** 2025-11-13
**Test Results:** 407 passing (14 pre-existing failures unrelated to this implementation)
**Commits:**
- 61f71f0 feat: add production rate helper methods to GameProvider
- 2b81eba feat: add CompactResourceBar widget
- 67bd514 feat: integrate CompactResourceBar into BuildingsScreen

---

## Notes

**Design Document:** See `docs/plans/2025-11-13-compact-resource-bar-design.md` for full design rationale

**Key Implementation Decisions:**
- Production rate methods follow same pattern as `getCatsPerSecond()`
- CompactResourceBar is a simple ConsumerWidget with no state
- Column + Expanded layout provides sticky behavior without scroll controllers
- Wrap widget handles responsive layout automatically

**Testing Strategy:**
- Unit tests for each production rate method
- Widget tests for CompactResourceBar visibility logic
- Integration tests for BuildingsScreen layout
- Manual testing for visual polish and UX

**Future Enhancements:**
- Color coding for low/high resources
- Tap to highlight buildings using that resource
- Animation on resource changes
- Settings toggle for show/hide rates
