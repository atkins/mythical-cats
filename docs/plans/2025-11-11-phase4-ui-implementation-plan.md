# Phase 4 UI: Reincarnation Screen - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the complete Reincarnation screen UI with patron selection, upgrade cards, FAB, confirmation dialog, and home screen integration.

**Architecture:** Widget-based Flutter UI following existing patterns (building_card, research_node_card). TDD approach building widgets bottom-up: upgrade cards → force sections → screen assembly. Integrates with existing game_provider state management.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, Material Design widgets

---

## Task 1: Add setActivePatron Method

**Files:**
- Modify: `lib/providers/game_provider.dart`
- Test: `test/providers/game_provider_test.dart`

**Step 1: Write the failing test**

Add to `test/providers/game_provider_test.dart` in a new test group at the end:

```dart
group('Patron Management', () {
  test('setActivePatron updates patron', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    // Set up state with some PE
    notifier.state = notifier.state.copyWith(
      reincarnationState: ReincarnationState(
        totalPrimordialEssence: 100,
        availablePrimordialEssence: 100,
        ownedUpgradeIds: {'chaos_1'},
      ),
    );

    // Set patron
    notifier.setActivePatron(PrimordialForce.chaos);

    expect(
      notifier.state.reincarnationState.activePatron,
      PrimordialForce.chaos,
    );

    // Change patron
    notifier.setActivePatron(PrimordialForce.gaia);

    expect(
      notifier.state.reincarnationState.activePatron,
      PrimordialForce.gaia,
    );

    container.dispose();
  });

  test('setActivePatron can set patron to null', () {
    final container = ProviderContainer();
    final notifier = container.read(gameProvider.notifier);

    notifier.state = notifier.state.copyWith(
      reincarnationState: ReincarnationState(
        activePatron: PrimordialForce.chaos,
      ),
    );

    notifier.setActivePatron(null);

    expect(notifier.state.reincarnationState.activePatron, null);

    container.dispose();
  });
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: FAIL with "The method 'setActivePatron' isn't defined"

**Step 3: Write minimal implementation**

Add to `lib/providers/game_provider.dart` after the `purchasePrimordialUpgrade` method (around line 494):

```dart
/// Set the active patron force.
/// Pass null to clear the patron.
void setActivePatron(PrimordialForce? patron) {
  state = state.copyWith(
    reincarnationState: state.reincarnationState.copyWith(
      activePatron: patron,
    ),
  );
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/providers/game_provider_test.dart`

Expected: All tests pass (206 total)

**Step 5: Commit**

```bash
git add lib/providers/game_provider.dart test/providers/game_provider_test.dart
git commit -m "feat: add setActivePatron method for patron switching"
```

---

## Task 2: PrimordialUpgradeCard Widget

**Files:**
- Create: `lib/widgets/primordial_upgrade_card.dart`
- Test: `test/widgets/primordial_upgrade_card_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/primordial_upgrade_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/primordial_upgrade_card.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialUpgradeCard', () {
    testWidgets('displays owned state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'chaos_1',
              force: PrimordialForce.chaos,
              tier: 1,
              name: 'Chaos I',
              effect: '+10% click power',
              cost: 10,
              isOwned: true,
              canAfford: false,
              isLocked: false,
              onPurchase: () {},
            ),
          ),
        ),
      );

      expect(find.text('Chaos I'), findsOneWidget);
      expect(find.text('+10% click power'), findsOneWidget);
      expect(find.text('Owned'), findsOneWidget);
      expect(find.text('Tier 1'), findsOneWidget);
    });

    testWidgets('displays affordable state with purchase button', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'chaos_2',
              force: PrimordialForce.chaos,
              tier: 2,
              name: 'Chaos II',
              effect: '+25% click power',
              cost: 25,
              isOwned: false,
              canAfford: true,
              isLocked: false,
              onPurchase: () => wasTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Purchase'), findsOneWidget);
      expect(find.text('25 PE'), findsOneWidget);

      await tester.tap(find.text('Purchase'));
      expect(wasTapped, true);
    });

    testWidgets('displays locked state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'chaos_3',
              force: PrimordialForce.chaos,
              tier: 3,
              name: 'Chaos III',
              effect: '+50% click power',
              cost: 50,
              isOwned: false,
              canAfford: false,
              isLocked: true,
              onPurchase: () {},
            ),
          ),
        ),
      );

      expect(find.text('Requires Tier 2'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays unaffordable state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'gaia_1',
              force: PrimordialForce.gaia,
              tier: 1,
              name: 'Gaia I',
              effect: '+15% production',
              cost: 10,
              isOwned: false,
              canAfford: false,
              isLocked: false,
              onPurchase: () {},
            ),
          ),
        ),
      );

      expect(find.text('10 PE'), findsOneWidget);
      // Button should be disabled when not affordable
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Purchase'),
      );
      expect(button.onPressed, null);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primordial_upgrade_card_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/widgets/primordial_upgrade_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PrimordialUpgradeCard extends StatelessWidget {
  final String upgradeId;
  final PrimordialForce force;
  final int tier;
  final String name;
  final String effect;
  final int cost;
  final bool isOwned;
  final bool canAfford;
  final bool isLocked;
  final VoidCallback onPurchase;

  const PrimordialUpgradeCard({
    super.key,
    required this.upgradeId,
    required this.force,
    required this.tier,
    required this.name,
    required this.effect,
    required this.cost,
    required this.isOwned,
    required this.canAfford,
    required this.isLocked,
    required this.onPurchase,
  });

  Color get _forceColor {
    switch (force) {
      case PrimordialForce.chaos:
        return Colors.deepPurple;
      case PrimordialForce.gaia:
        return Colors.green;
      case PrimordialForce.nyx:
        return Colors.indigo;
      case PrimordialForce.erebus:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 160,
      child: Card(
        elevation: isOwned ? 2 : (canAfford && !isLocked ? 4 : 1),
        color: isOwned ? _forceColor.withOpacity(0.2) : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLocked)
                    Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _forceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tier $tier',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Effect
              Text(
                effect,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Cost/Status
              if (isOwned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _forceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: _forceColor),
                      const SizedBox(width: 4),
                      const Text(
                        'Owned',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isLocked)
                Text(
                  'Requires Tier ${tier - 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Column(
                  children: [
                    Text(
                      '$cost PE',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canAfford ? onPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _forceColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        child: const Text('Purchase'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primordial_upgrade_card_test.dart`

Expected: All 4 tests pass

**Step 5: Commit**

```bash
git add lib/widgets/primordial_upgrade_card.dart test/widgets/primordial_upgrade_card_test.dart
git commit -m "feat: add PrimordialUpgradeCard widget with states"
```

---

## Task 3: PrimordialForceSection Widget

**Files:**
- Create: `lib/widgets/primordial_force_section.dart`
- Test: `test/widgets/primordial_force_section_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/primordial_force_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/primordial_force_section.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';

void main() {
  group('PrimordialForceSection', () {
    testWidgets('displays force header correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimordialForceSection(
                force: PrimordialForce.chaos,
                ownedUpgradeIds: const {'chaos_1', 'chaos_2'},
                availablePE: 50,
                onPurchase: (id) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('⚡ Chaos'), findsOneWidget);
      expect(find.text('Active Play - Click Power'), findsOneWidget);
      expect(find.text('2/5 upgrades owned'), findsOneWidget);
    });

    testWidgets('displays all 5 upgrade cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimordialForceSection(
                force: PrimordialForce.gaia,
                ownedUpgradeIds: const {},
                availablePE: 100,
                onPurchase: (id) {},
              ),
            ),
          ),
        ),
      );

      // Should have 5 upgrade cards
      expect(find.byType(Card), findsNWidgets(5));
      expect(find.text('Tier 1'), findsOneWidget);
      expect(find.text('Tier 2'), findsOneWidget);
      expect(find.text('Tier 3'), findsOneWidget);
      expect(find.text('Tier 4'), findsOneWidget);
      expect(find.text('Tier 5'), findsOneWidget);
    });

    testWidgets('calls onPurchase with correct upgrade ID', (tester) async {
      String? purchasedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimordialForceSection(
                force: PrimordialForce.chaos,
                ownedUpgradeIds: const {},
                availablePE: 100,
                onPurchase: (id) => purchasedId = id,
              ),
            ),
          ),
        ),
      );

      // Find and tap first purchase button
      await tester.tap(find.text('Purchase').first);
      expect(purchasedId, 'chaos_1');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/primordial_force_section_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/widgets/primordial_force_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';
import 'package:mythical_cats/widgets/primordial_upgrade_card.dart';

class PrimordialForceSection extends StatelessWidget {
  final PrimordialForce force;
  final Set<String> ownedUpgradeIds;
  final int availablePE;
  final Function(String upgradeId) onPurchase;

  const PrimordialForceSection({
    super.key,
    required this.force,
    required this.ownedUpgradeIds,
    required this.availablePE,
    required this.onPurchase,
  });

  Color get _forceColor {
    switch (force) {
      case PrimordialForce.chaos:
        return Colors.deepPurple;
      case PrimordialForce.gaia:
        return Colors.green;
      case PrimordialForce.nyx:
        return Colors.indigo;
      case PrimordialForce.erebus:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final upgrades = PrimordialUpgradeDefinitions.getForceUpgrades(force);
    final ownedCount = upgrades.where((u) => ownedUpgradeIds.contains(u.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    force.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    force.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _forceColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                force.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$ownedCount/5 upgrades owned',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _forceColor,
                    ),
              ),
            ],
          ),
        ),
        // Divider
        Divider(
          color: _forceColor,
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
        const SizedBox(height: 8),
        // Upgrade cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: upgrades.map((upgrade) {
              final isOwned = ownedUpgradeIds.contains(upgrade.id);
              final isLocked = upgrade.tier > 1 &&
                  !ownedUpgradeIds.contains('${force.name}_${upgrade.tier - 1}');
              final canAfford = availablePE >= upgrade.cost;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PrimordialUpgradeCard(
                  upgradeId: upgrade.id,
                  force: force,
                  tier: upgrade.tier,
                  name: upgrade.name,
                  effect: upgrade.effect,
                  cost: upgrade.cost,
                  isOwned: isOwned,
                  canAfford: canAfford,
                  isLocked: isLocked,
                  onPurchase: () => onPurchase(upgrade.id),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/primordial_force_section_test.dart`

Expected: All 3 tests pass

**Step 5: Commit**

```bash
git add lib/widgets/primordial_force_section.dart test/widgets/primordial_force_section_test.dart
git commit -m "feat: add PrimordialForceSection widget with header and upgrade grid"
```

---

## Task 4: PatronSelector Widget

**Files:**
- Create: `lib/widgets/patron_selector.dart`
- Test: `test/widgets/patron_selector_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/patron_selector_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/patron_selector.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PatronSelector', () {
    testWidgets('displays all 4 force buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'gaia_1'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      expect(find.text('Chaos'), findsOneWidget);
      expect(find.text('Gaia'), findsOneWidget);
      expect(find.text('Nyx'), findsOneWidget);
      expect(find.text('Erebus'), findsOneWidget);
      expect(find.text('Active Patron'), findsOneWidget);
    });

    testWidgets('highlights active patron', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.gaia,
              ownedUpgradeIds: const {'gaia_1'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('🌿 Gaia'), findsOneWidget);
    });

    testWidgets('calls onPatronSelected when button tapped', (tester) async {
      PrimordialForce? selectedForce;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'gaia_1', 'nyx_1'},
              onPatronSelected: (force) => selectedForce = force,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Gaia'));
      expect(selectedForce, PrimordialForce.gaia);
    });

    testWidgets('disables forces with no upgrades', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      // Chaos should be enabled, others disabled
      final chaosButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Chaos'),
      );
      expect(chaosButton.onPressed, isNotNull);

      final gaiaButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gaia'),
      );
      expect(gaiaButton.onPressed, isNull);
    });

    testWidgets('displays active patron bonus text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'chaos_2'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      // Should show chaos icon and bonus (0.5 + 2*0.1 = 0.7 = 70%)
      expect(find.textContaining('⚡ Chaos'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/patron_selector_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/widgets/patron_selector.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PatronSelector extends StatelessWidget {
  final PrimordialForce? activePatron;
  final Set<String> ownedUpgradeIds;
  final Function(PrimordialForce) onPatronSelected;

  const PatronSelector({
    super.key,
    required this.activePatron,
    required this.ownedUpgradeIds,
    required this.onPatronSelected,
  });

  bool _hasUpgrades(PrimordialForce force) {
    return ownedUpgradeIds.any((id) => id.startsWith('${force.name}_'));
  }

  Color _getForceColor(PrimordialForce force) {
    switch (force) {
      case PrimordialForce.chaos:
        return Colors.deepPurple;
      case PrimordialForce.gaia:
        return Colors.green;
      case PrimordialForce.nyx:
        return Colors.indigo;
      case PrimordialForce.erebus:
        return Colors.amber;
    }
  }

  String _getPatronBonusText() {
    if (activePatron == null) return 'No patron selected';

    final tier = ownedUpgradeIds
        .where((id) => id.startsWith('${activePatron!.name}_'))
        .length;
    final bonus = (0.5 + (tier * 0.1)) * 100;

    String effectText;
    switch (activePatron!) {
      case PrimordialForce.chaos:
        effectText = 'click power';
        break;
      case PrimordialForce.gaia:
        effectText = 'building production';
        break;
      case PrimordialForce.nyx:
        effectText = 'offline progression';
        break;
      case PrimordialForce.erebus:
        effectText = 'tier 2 production';
        break;
    }

    return '${activePatron!.icon} ${activePatron!.displayName}: +${bonus.toStringAsFixed(0)}% $effectText';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Patron',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPatronBonusText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: activePatron != null
                        ? _getForceColor(activePatron!)
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Force buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PrimordialForce.values.map((force) {
                final hasUpgrades = _hasUpgrades(force);
                final isActive = force == activePatron;

                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: ElevatedButton(
                    onPressed: hasUpgrades ? () => onPatronSelected(force) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? _getForceColor(force)
                          : Colors.grey.shade200,
                      foregroundColor: isActive ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              force.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            Text(force.displayName),
                          ],
                        ),
                        if (isActive)
                          const Text(
                            'Active',
                            style: TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/patron_selector_test.dart`

Expected: All 5 tests pass

**Step 5: Commit**

```bash
git add lib/widgets/patron_selector.dart test/widgets/patron_selector_test.dart
git commit -m "feat: add PatronSelector widget with force buttons and bonus display"
```

---

## Task 5: ReincarnationFab Widget

**Files:**
- Create: `lib/widgets/reincarnation_fab.dart`
- Test: `test/widgets/reincarnation_fab_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/reincarnation_fab_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/reincarnation_fab.dart';

void main() {
  group('ReincarnationFab', () {
    testWidgets('displays PE preview when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 25,
              isEnabled: true,
              catsRemaining: 0,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Reincarnate for 25 PE'), findsOneWidget);
      expect(find.byIcon(Icons.autorenew), findsOneWidget);
    });

    testWidgets('shows remaining cats when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 0,
              isEnabled: false,
              catsRemaining: 500000000,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Need 1B cats'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped and enabled', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 30,
              isEnabled: true,
              catsRemaining: 0,
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      expect(wasTapped, true);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 0,
              isEnabled: false,
              catsRemaining: 999999999,
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      // FAB should not be tappable when disabled
      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNull);
      expect(wasTapped, false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/reincarnation_fab_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/widgets/reincarnation_fab.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class ReincarnationFab extends StatelessWidget {
  final int peEarned;
  final bool isEnabled;
  final double catsRemaining;
  final VoidCallback onPressed;

  const ReincarnationFab({
    super.key,
    required this.peEarned,
    required this.isEnabled,
    required this.catsRemaining,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isEnabled ? onPressed : null,
      backgroundColor:
          isEnabled ? Colors.deepPurple : Colors.grey.shade400,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.autorenew),
      label: Text(
        isEnabled
            ? 'Reincarnate for $peEarned PE'
            : 'Need 1B cats (${NumberFormatter.format(catsRemaining)} more)',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/reincarnation_fab_test.dart`

Expected: All 4 tests pass

**Step 5: Commit**

```bash
git add lib/widgets/reincarnation_fab.dart test/widgets/reincarnation_fab_test.dart
git commit -m "feat: add ReincarnationFab widget with PE preview"
```

---

## Task 6: ReincarnationScreen Main Assembly

**Files:**
- Create: `lib/screens/reincarnation_screen.dart`
- Test: `test/widgets/reincarnation_screen_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/reincarnation_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('ReincarnationScreen', () {
    testWidgets('displays patron selector and all 4 force sections',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 2000000000,
                    reincarnationState: ReincarnationState(
                      totalPrimordialEssence: 50,
                      availablePrimordialEssence: 50,
                      ownedUpgradeIds: const {'chaos_1'},
                      activePatron: PrimordialForce.chaos,
                      totalReincarnations: 1,
                      lifetimeCatsEarned: 1000000000,
                      thisRunCatsEarned: 1000000000,
                    ),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      expect(find.text('Active Patron'), findsOneWidget);
      expect(find.text('⚡ Chaos'), findsOneWidget);
      expect(find.text('🌿 Gaia'), findsOneWidget);
      expect(find.text('🌙 Nyx'), findsOneWidget);
      expect(find.text('💎 Erebus'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      container.dispose();
    });

    testWidgets('FAB shows correct PE calculation', (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 10000000000, // 10B cats = 30 PE
                    reincarnationState: const ReincarnationState(),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      expect(find.textContaining('30 PE'), findsOneWidget);

      container.dispose();
    });

    testWidgets('shows confirmation dialog on FAB tap', (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 2000000000,
                    reincarnationState: ReincarnationState(
                      availablePrimordialEssence: 20,
                      activePatron: PrimordialForce.chaos,
                    ),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Reincarnate?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reincarnate'), findsOneWidget);

      container.dispose();
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/reincarnation_screen_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/screens/reincarnation_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/widgets/patron_selector.dart';
import 'package:mythical_cats/widgets/primordial_force_section.dart';
import 'package:mythical_cats/widgets/reincarnation_fab.dart';

class ReincarnationScreen extends ConsumerWidget {
  const ReincarnationScreen({super.key});

  void _showReincarnationDialog(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final peEarned =
        gameNotifier.calculatePrimordialEssence(gameState.totalCatsEarned);
    final activePatron = gameState.reincarnationState.activePatron;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reincarnate?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You will gain:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text('  • +$peEarned Primordial Essence'),
              const SizedBox(height: 12),
              Text(
                'Active patron:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                activePatron != null
                    ? '  • ${activePatron.icon} ${activePatron.displayName}'
                    : '  • None',
              ),
              const SizedBox(height: 12),
              Text(
                'You will reset:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Text('  • Cats, Offerings, Prayers, Divine Essence, Ambrosia'),
              const Text('  • All Buildings'),
              const Text('  • God unlocks (except Hermes)'),
              const Text('  • Conquered territories'),
              const SizedBox(height: 12),
              Text(
                'You will keep:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Text('  • Research progress'),
              const Text('  • Achievements'),
              const Text('  • Primordial upgrades'),
              const Text('  • Total PE earned'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (activePatron != null) {
                gameNotifier.reincarnate(activePatron);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reincarnated! Earned $peEarned PE'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reincarnate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final reincState = gameState.reincarnationState;
    final peEarned =
        gameNotifier.calculatePrimordialEssence(gameState.totalCatsEarned);
    final threshold = 1000000000.0;
    final isEnabled = gameState.totalCatsEarned >= threshold;
    final catsRemaining =
        isEnabled ? 0.0 : threshold - gameState.totalCatsEarned;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Patron Selector
              PatronSelector(
                activePatron: reincState.activePatron,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                onPatronSelected: (force) =>
                    gameNotifier.setActivePatron(force),
              ),
              const SizedBox(height: 8),
              // Force Sections
              PrimordialForceSection(
                force: PrimordialForce.chaos,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              PrimordialForceSection(
                force: PrimordialForce.gaia,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              PrimordialForceSection(
                force: PrimordialForce.nyx,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              PrimordialForceSection(
                force: PrimordialForce.erebus,
                ownedUpgradeIds: reincState.ownedUpgradeIds,
                availablePE: reincState.availablePrimordialEssence,
                onPurchase: (id) =>
                    gameNotifier.purchasePrimordialUpgrade(id),
              ),
              // Bottom padding for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: ReincarnationFab(
        peEarned: peEarned,
        isEnabled: isEnabled,
        catsRemaining: catsRemaining,
        onPressed: () => _showReincarnationDialog(context, ref),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/reincarnation_screen_test.dart`

Expected: All 3 tests pass

**Step 5: Commit**

```bash
git add lib/screens/reincarnation_screen.dart test/widgets/reincarnation_screen_test.dart
git commit -m "feat: add ReincarnationScreen with patron selector and force sections"
```

---

## Task 7: PrestigeStatsPanel Widget

**Files:**
- Create: `lib/widgets/prestige_stats_panel.dart`
- Test: `test/widgets/prestige_stats_panel_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/prestige_stats_panel_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrestigeStatsPanel', () {
    testWidgets('is hidden when no reincarnations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 0,
              totalPE: 0,
              reincarnations: 0,
              activePatron: null,
              ownedUpgradeIds: const {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Prestige Progress'), findsNothing);
    });

    testWidgets('displays stats after first reincarnation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 45,
              totalPE: 120,
              reincarnations: 3,
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'chaos_2'},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Prestige Progress'), findsOneWidget);
      expect(find.text('Available PE: 45 / 120 Total'), findsOneWidget);
      expect(find.text('Reincarnations: 3'), findsOneWidget);
    });

    testWidgets('displays active patron bonus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 50,
              totalPE: 100,
              reincarnations: 2,
              activePatron: PrimordialForce.gaia,
              ownedUpgradeIds: const {'gaia_1', 'gaia_2', 'gaia_3'},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('🌿 Gaia'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 30,
              totalPE: 50,
              reincarnations: 1,
              activePatron: PrimordialForce.nyx,
              ownedUpgradeIds: const {'nyx_1'},
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(wasTapped, true);
    });

    testWidgets('shows "No patron" when patron is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 20,
              totalPE: 20,
              reincarnations: 1,
              activePatron: null,
              ownedUpgradeIds: const {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('No patron selected'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/prestige_stats_panel_test.dart`

Expected: FAIL with "Target of URI doesn't exist"

**Step 3: Write minimal implementation**

Create `lib/widgets/prestige_stats_panel.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mythical_cats/models/primordial_force.dart';

class PrestigeStatsPanel extends StatelessWidget {
  final int availablePE;
  final int totalPE;
  final int reincarnations;
  final PrimordialForce? activePatron;
  final Set<String> ownedUpgradeIds;
  final VoidCallback onTap;

  const PrestigeStatsPanel({
    super.key,
    required this.availablePE,
    required this.totalPE,
    required this.reincarnations,
    required this.activePatron,
    required this.ownedUpgradeIds,
    required this.onTap,
  });

  Color? _getPatronColor() {
    if (activePatron == null) return null;
    switch (activePatron!) {
      case PrimordialForce.chaos:
        return Colors.deepPurple;
      case PrimordialForce.gaia:
        return Colors.green;
      case PrimordialForce.nyx:
        return Colors.indigo;
      case PrimordialForce.erebus:
        return Colors.amber;
    }
  }

  String _getPatronBonusText() {
    if (activePatron == null) return 'No patron selected';

    final tier = ownedUpgradeIds
        .where((id) => id.startsWith('${activePatron!.name}_'))
        .length;
    final bonus = (0.5 + (tier * 0.1)) * 100;

    String effectText;
    switch (activePatron!) {
      case PrimordialForce.chaos:
        effectText = 'click power';
        break;
      case PrimordialForce.gaia:
        effectText = 'building production';
        break;
      case PrimordialForce.nyx:
        effectText = 'offline progression';
        break;
      case PrimordialForce.erebus:
        effectText = 'tier 2 production';
        break;
    }

    return '${activePatron!.icon} ${activePatron!.displayName}: +${bonus.toStringAsFixed(0)}% $effectText';
  }

  @override
  Widget build(BuildContext context) {
    // Hide panel if never reincarnated
    if (reincarnations == 0) {
      return const SizedBox.shrink();
    }

    final patronColor = _getPatronColor();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: patronColor != null
            ? BorderSide(color: patronColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.autorenew, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Prestige Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatRow(
                label: 'Available PE:',
                value: '$availablePE / $totalPE Total',
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: 'Reincarnations:',
                value: '$reincarnations',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: patronColor?.withOpacity(0.1) ?? Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getPatronBonusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: patronColor ?? Colors.grey.shade600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/prestige_stats_panel_test.dart`

Expected: All 5 tests pass

**Step 5: Commit**

```bash
git add lib/widgets/prestige_stats_panel.dart test/widgets/prestige_stats_panel_test.dart
git commit -m "feat: add PrestigeStatsPanel widget for home screen"
```

---

## Task 8: Update HomeScreen Integration

**Files:**
- Modify: `lib/screens/home_screen.dart`

**Step 1: Add Reincarnation tab and PrestigeStatsPanel**

Modify `lib/screens/home_screen.dart`:

1. Add import at top:
```dart
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';
```

2. In the `build` method after line 23, add:
```dart
final hasReincarnation = gameState.totalCatsEarned >= 1000000000;
```

3. In the `tabs` list after line 32, add:
```dart
if (hasReincarnation)
  const Tab(icon: Icon(Icons.autorenew), text: 'Reincarnation'),
```

4. In the `tabViews` list after line 42, add:
```dart
if (hasReincarnation) const ReincarnationScreen(),
```

5. In the `_HomeTab` widget's `build` method, add PrestigeStatsPanel after the ResourcePanel (after line 97):

```dart
// Prestige stats (if player has reincarnated)
if (gameState.reincarnationState.totalReincarnations > 0)
  PrestigeStatsPanel(
    availablePE: gameState.reincarnationState.availablePrimordialEssence,
    totalPE: gameState.reincarnationState.totalPrimordialEssence,
    reincarnations: gameState.reincarnationState.totalReincarnations,
    activePatron: gameState.reincarnationState.activePatron,
    ownedUpgradeIds: gameState.reincarnationState.ownedUpgradeIds,
    onTap: () {
      // Navigate to Reincarnation tab
      DefaultTabController.of(context).animateTo(
        5 + (gameState.hasUnlockedGod(God.athena) ? 1 : 0) +
            (gameState.hasUnlockedGod(God.ares) ? 1 : 0),
      );
    },
  ),
const SizedBox(height: 24),
```

**Step 2: Run app to verify changes**

Run: `flutter run`

Expected: App runs, Reincarnation tab appears when totalCatsEarned >= 1B

**Step 3: Run all tests to verify no regressions**

Run: `flutter test`

Expected: All tests pass (206+ tests)

**Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: integrate Reincarnation tab and PrestigeStatsPanel in HomeScreen"
```

---

## Task 9: Phase 4 UI Integration Tests

**Files:**
- Create: `test/phase4_ui_integration_test.dart`

**Step 1: Write integration tests**

Create `test/phase4_ui_integration_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 UI Integration Tests', () {
    testWidgets('Reincarnation tab appears at 1B cats', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Initially no Reincarnation tab
      expect(find.text('Reincarnation'), findsNothing);

      // Earn 1B cats
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
      );

      await tester.pumpAndSettle();

      // Now tab should appear
      expect(find.text('Reincarnation'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Can purchase upgrade and see updated stats', (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 2000000000,
                    reincarnationState: ReincarnationState(
                      totalPrimordialEssence: 50,
                      availablePrimordialEssence: 50,
                      activePatron: PrimordialForce.chaos,
                      totalReincarnations: 1,
                    ),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Go to Reincarnation tab
      await tester.tap(find.text('Reincarnation'));
      await tester.pumpAndSettle();

      // Should see Chaos upgrades
      expect(find.text('⚡ Chaos'), findsWidgets);

      // Purchase chaos_1 (costs 10 PE)
      await tester.tap(find.text('Purchase').first);
      await tester.pumpAndSettle();

      // PE should be reduced
      final notifier = container.read(gameProvider.notifier);
      expect(
        notifier.state.reincarnationState.availablePrimordialEssence,
        40,
      );
      expect(
        notifier.state.reincarnationState.ownedUpgradeIds,
        contains('chaos_1'),
      );

      container.dispose();
    });

    testWidgets('Patron switching updates bonuses', (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 2000000000,
                    reincarnationState: ReincarnationState(
                      totalPrimordialEssence: 100,
                      availablePrimordialEssence: 50,
                      ownedUpgradeIds: const {'chaos_1', 'gaia_1'},
                      activePatron: PrimordialForce.chaos,
                      totalReincarnations: 1,
                    ),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Go to Reincarnation tab
      await tester.tap(find.text('Reincarnation'));
      await tester.pumpAndSettle();

      // Current patron should be Chaos
      expect(find.textContaining('⚡ Chaos'), findsWidgets);

      // Switch to Gaia
      await tester.tap(find.text('Gaia'));
      await tester.pumpAndSettle();

      // Patron should update
      final notifier = container.read(gameProvider.notifier);
      expect(
        notifier.state.reincarnationState.activePatron,
        PrimordialForce.gaia,
      );

      container.dispose();
    });

    testWidgets('Reincarnation flow completes successfully', (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 2000000000,
                    resources: {ResourceType.cats: 500000},
                    reincarnationState: ReincarnationState(
                      totalPrimordialEssence: 20,
                      availablePrimordialEssence: 20,
                      ownedUpgradeIds: const {'chaos_1'},
                      activePatron: PrimordialForce.chaos,
                      totalReincarnations: 1,
                    ),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Go to Reincarnation tab
      await tester.tap(find.text('Reincarnation'));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Reincarnate?'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Reincarnate').last);
      await tester.pumpAndSettle();

      // State should be reset
      final notifier = container.read(gameProvider.notifier);
      expect(notifier.state.getResource(ResourceType.cats), 0);
      expect(
        notifier.state.reincarnationState.totalReincarnations,
        2,
      );

      container.dispose();
    });

    testWidgets('PrestigeStatsPanel appears after reincarnation',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) {
            return GameNotifier()
              ..state = GameNotifier().state.copyWith(
                    totalCatsEarned: 2000000000,
                    reincarnationState: ReincarnationState(
                      totalPrimordialEssence: 40,
                      availablePrimordialEssence: 20,
                      activePatron: PrimordialForce.gaia,
                      totalReincarnations: 2,
                      ownedUpgradeIds: const {'gaia_1'},
                    ),
                  );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Should see prestige stats on home screen
      expect(find.text('Prestige Progress'), findsOneWidget);
      expect(find.text('Available PE: 20 / 40 Total'), findsOneWidget);
      expect(find.text('Reincarnations: 2'), findsOneWidget);

      container.dispose();
    });
  });
}
```

**Step 2: Run tests to verify they pass**

Run: `flutter test test/phase4_ui_integration_test.dart`

Expected: All 5 integration tests pass

**Step 3: Commit**

```bash
git add test/phase4_ui_integration_test.dart
git commit -m "test: add Phase 4 UI integration tests"
```

---

## Task 10: Run Full Test Suite

**Step 1: Run all tests**

Run: `flutter test`

Expected: All tests pass (211+ tests total)

**Step 2: Verify no regressions**

Check output for:
- All existing tests still passing
- New Phase 4 UI tests passing
- No compilation errors

**Step 3: Final commit**

```bash
git add .
git commit -m "feat: complete Phase 4 UI implementation

- Reincarnation screen with vertical scrolling force sections
- Patron selector for switching active bonuses
- Upgrade cards with owned/locked/affordable states
- FAB with PE preview and confirmation dialog
- Home screen prestige stats panel
- Full integration with existing game state
- 211+ tests passing, zero regressions"
```

---

## Verification Checklist

Manual testing steps:

1. **Tab Unlock**
   - [ ] Start new game, verify no Reincarnation tab
   - [ ] Earn 1B cats, verify tab appears
   - [ ] Tab shows autorenew icon and "Reincarnation" label

2. **Patron Selector**
   - [ ] Active patron highlighted correctly
   - [ ] Tapping force buttons switches patron
   - [ ] Forces with no upgrades are disabled
   - [ ] Bonus text shows correct percentage

3. **Upgrade Cards**
   - [ ] Owned upgrades show checkmark and filled background
   - [ ] Affordable upgrades show enabled Purchase button
   - [ ] Locked upgrades show lock icon and "Requires Tier X"
   - [ ] Unaffordable upgrades show disabled Purchase button

4. **Reincarnation FAB**
   - [ ] Shows correct PE calculation
   - [ ] Disabled below 1B cats threshold
   - [ ] Opens confirmation dialog on tap

5. **Confirmation Dialog**
   - [ ] Shows PE gain amount
   - [ ] Shows active patron
   - [ ] Lists what resets and what persists
   - [ ] Cancel dismisses dialog
   - [ ] Reincarnate executes reset correctly

6. **Prestige Stats Panel**
   - [ ] Hidden before first reincarnation
   - [ ] Shows correct PE and reincarnation count
   - [ ] Displays active patron with bonuses
   - [ ] Tapping navigates to Reincarnation tab
   - [ ] Border color matches active patron

7. **Integration**
   - [ ] Purchase upgrade → PE decreases
   - [ ] Switch patron → bonuses update
   - [ ] Reincarnate → state resets correctly
   - [ ] Upgrades persist through reincarnation

---

## Success Criteria

Phase 4 UI is complete when:

✅ Reincarnation tab unlocks at 1B cats
✅ All 4 forces display with 5 upgrades each
✅ Patron selector allows switching between forces
✅ Upgrade cards show correct states (owned/locked/affordable)
✅ FAB calculates PE correctly and shows confirmation
✅ Reincarnation executes and resets state properly
✅ Prestige stats appear on home screen after first reincarnation
✅ All tests pass (211+ total)
✅ No regressions in existing features
✅ UI follows existing design patterns

---

## Notes

- All widgets follow existing card-based patterns
- Colors match force themes (purple/green/indigo/amber)
- Mobile-first responsive design
- Proper state management via Riverpod
- Complete test coverage for all components
