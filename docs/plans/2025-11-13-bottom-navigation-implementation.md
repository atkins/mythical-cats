# Bottom Navigation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign app navigation to use iOS-style bottom navigation bar, consolidating god-specific features into Divine Powers tab and moving achievements into Reincarnation tab.

**Architecture:** Replace top TabBar with bottom NavigationBar using IndexedStack for state preservation. Create new DivinePowersScreen with internal segmented control for god features. Update ReincarnationScreen to include achievements via segmented control. Both new screens show teaser content when locked.

**Tech Stack:** Flutter, Material3 NavigationBar, SegmentedButton, Riverpod

---

## Task 1: Create DivinePowersScreen with Teaser State

**Files:**
- Create: `lib/screens/divine_powers_screen.dart`
- Test: `test/widgets/divine_powers_screen_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/divine_powers_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/divine_powers_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('DivinePowersScreen', () {
    testWidgets('shows teaser content when no gods unlocked', (tester) async {
      final gameState = GameState.initial().copyWith(
        unlockedGods: [God.hermes], // Only Hermes (doesn't count)
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
          ],
          child: const MaterialApp(
            home: DivinePowersScreen(),
          ),
        ),
      );

      expect(find.text('Divine Powers'), findsOneWidget);
      expect(find.text('Unlock gods to access their powers'), findsOneWidget);
      expect(find.text('Athena'), findsOneWidget);
      expect(find.text('Ares'), findsOneWidget);
      expect(find.text('Apollo'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/divine_powers_screen_test.dart`
Expected: FAIL with "DivinePowersScreen not found"

**Step 3: Write minimal implementation**

Create `lib/screens/divine_powers_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class DivinePowersScreen extends ConsumerWidget {
  const DivinePowersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    // Check if any divine gods are unlocked (not Hermes)
    final hasAthena = gameState.hasUnlockedGod(God.athena);
    final hasAres = gameState.hasUnlockedGod(God.ares);
    final hasApollo = gameState.hasUnlockedGod(God.apollo);
    final hasDivineGods = hasAthena || hasAres || hasApollo;

    if (!hasDivineGods) {
      return _buildTeaserContent(context, gameState);
    }

    return _buildDivinePowersContent(context, gameState);
  }

  Widget _buildTeaserContent(BuildContext context, gameState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divine Powers'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock gods to access their powers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildGodTeaserCard(
                context,
                god: God.athena,
                description: 'Goddess of Wisdom - Unlock powerful research abilities',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
              const SizedBox(height: 16),
              _buildGodTeaserCard(
                context,
                god: God.ares,
                description: 'God of War - Conquer territories for bonuses',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
              const SizedBox(height: 16),
              _buildGodTeaserCard(
                context,
                god: God.apollo,
                description: 'God of Prophecy - Unlock divine foresight',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGodTeaserCard(
    BuildContext context, {
    required God god,
    required String description,
    required double totalCatsEarned,
  }) {
    final requirement = god.unlockRequirement ?? 0;
    final progress = (totalCatsEarned / requirement).clamp(0.0, 1.0);
    final isLocked = totalCatsEarned < requirement;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? Colors.grey.shade400 : Colors.amber.shade700,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock,
                color: isLocked ? Colors.grey.shade600 : Colors.amber.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                god.displayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isLocked ? Colors.grey.shade700 : Colors.amber.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isLocked ? Colors.grey.shade600 : Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock at ${NumberFormatter.format(requirement)} total cats',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLocked ? Colors.grey.shade500 : Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${NumberFormatter.format(totalCatsEarned)} / ${NumberFormatter.format(requirement)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivinePowersContent(BuildContext context, gameState) {
    // Placeholder for now
    return const Scaffold(
      body: Center(child: Text('Divine Powers Content')),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/divine_powers_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/screens/divine_powers_screen.dart test/widgets/divine_powers_screen_test.dart
git commit -m "feat: add DivinePowersScreen with teaser state

Shows locked god cards with progress bars when no divine gods unlocked.
Displays Athena, Ares, and Apollo with descriptions and unlock requirements."
```

---

## Task 2: Add Segmented Control to DivinePowersScreen

**Files:**
- Modify: `lib/screens/divine_powers_screen.dart`
- Modify: `test/widgets/divine_powers_screen_test.dart`

**Step 1: Write the failing test**

Add to `test/widgets/divine_powers_screen_test.dart`:

```dart
testWidgets('shows segmented control when gods unlocked', (tester) async {
  final gameState = GameState.initial().copyWith(
    unlockedGods: [God.hermes, God.athena, God.ares],
    totalCatsEarned: 1000000000, // 1B
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
      ],
      child: const MaterialApp(
        home: DivinePowersScreen(),
      ),
    ),
  );

  expect(find.text('Divine Powers'), findsOneWidget);
  expect(find.text('Research'), findsOneWidget);
  expect(find.text('Conquest'), findsOneWidget);
  expect(find.text('Prophecy'), findsNothing); // Apollo not unlocked
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/divine_powers_screen_test.dart`
Expected: FAIL - segmented control not shown

**Step 3: Write implementation**

Update `lib/screens/divine_powers_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/screens/research_screen.dart';
import 'package:mythical_cats/screens/conquest_screen.dart';
import 'package:mythical_cats/screens/prophecy_screen.dart';

enum DivinePowerTab { research, conquest, prophecy }

class DivinePowersScreen extends ConsumerStatefulWidget {
  const DivinePowersScreen({super.key});

  @override
  ConsumerState<DivinePowersScreen> createState() => _DivinePowersScreenState();
}

class _DivinePowersScreenState extends ConsumerState<DivinePowersScreen> {
  DivinePowerTab? _selectedTab;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Check if any divine gods are unlocked (not Hermes)
    final hasAthena = gameState.hasUnlockedGod(God.athena);
    final hasAres = gameState.hasUnlockedGod(God.ares);
    final hasApollo = gameState.hasUnlockedGod(God.apollo);
    final hasDivineGods = hasAthena || hasAres || hasApollo;

    if (!hasDivineGods) {
      return _buildTeaserContent(context, gameState);
    }

    // Build available tabs
    final availableTabs = <DivinePowerTab>[];
    if (hasAthena) availableTabs.add(DivinePowerTab.research);
    if (hasAres) availableTabs.add(DivinePowerTab.conquest);
    if (hasApollo) availableTabs.add(DivinePowerTab.prophecy);

    // Set initial selection if not set
    if (_selectedTab == null || !availableTabs.contains(_selectedTab)) {
      _selectedTab = availableTabs.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Divine Powers'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<DivinePowerTab>(
                segments: [
                  if (hasAthena)
                    const ButtonSegment(
                      value: DivinePowerTab.research,
                      label: Text('Research'),
                    ),
                  if (hasAres)
                    const ButtonSegment(
                      value: DivinePowerTab.conquest,
                      label: Text('Conquest'),
                    ),
                  if (hasApollo)
                    const ButtonSegment(
                      value: DivinePowerTab.prophecy,
                      label: Text('Prophecy'),
                    ),
                ],
                selected: {_selectedTab!},
                onSelectionChanged: (Set<DivinePowerTab> selected) {
                  setState(() {
                    _selectedTab = selected.first;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildSelectedContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedTab!) {
      case DivinePowerTab.research:
        return const ResearchScreen();
      case DivinePowerTab.conquest:
        return const ConquestScreen();
      case DivinePowerTab.prophecy:
        return const ProphecyScreen();
    }
  }

  Widget _buildTeaserContent(BuildContext context, gameState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divine Powers'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlock gods to access their powers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildGodTeaserCard(
                context,
                god: God.athena,
                description: 'Goddess of Wisdom - Unlock powerful research abilities',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
              const SizedBox(height: 16),
              _buildGodTeaserCard(
                context,
                god: God.ares,
                description: 'God of War - Conquer territories for bonuses',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
              const SizedBox(height: 16),
              _buildGodTeaserCard(
                context,
                god: God.apollo,
                description: 'God of Prophecy - Unlock divine foresight',
                totalCatsEarned: gameState.totalCatsEarned,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGodTeaserCard(
    BuildContext context, {
    required God god,
    required String description,
    required double totalCatsEarned,
  }) {
    final requirement = god.unlockRequirement ?? 0;
    final progress = (totalCatsEarned / requirement).clamp(0.0, 1.0);
    final isLocked = totalCatsEarned < requirement;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? Colors.grey.shade400 : Colors.amber.shade700,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock,
                color: isLocked ? Colors.grey.shade600 : Colors.amber.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                god.displayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isLocked ? Colors.grey.shade700 : Colors.amber.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isLocked ? Colors.grey.shade600 : Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock at ${NumberFormatter.format(requirement)} total cats',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLocked ? Colors.grey.shade500 : Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${NumberFormatter.format(totalCatsEarned)} / ${NumberFormatter.format(requirement)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/divine_powers_screen_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/screens/divine_powers_screen.dart test/widgets/divine_powers_screen_test.dart
git commit -m "feat: add segmented control to DivinePowersScreen

Shows Research/Conquest/Prophecy segments based on unlocked gods.
Clicking segment switches between god-specific screens."
```

---

## Task 3: Update ReincarnationScreen with Segmented Control

**Files:**
- Modify: `lib/screens/reincarnation_screen.dart`
- Create: `test/widgets/reincarnation_screen_test.dart`

**Step 1: Write the failing test**

Create `test/widgets/reincarnation_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';

void main() {
  group('ReincarnationScreen', () {
    testWidgets('shows teaser content when below 1B cats', (tester) async {
      final gameState = GameState.initial().copyWith(
        totalCatsEarned: 500000000, // 500M - below threshold
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
          ],
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      expect(find.text('Reincarnation'), findsOneWidget);
      expect(find.textContaining('Primordial Essence'), findsOneWidget);
      expect(find.textContaining('1.00B'), findsOneWidget); // Shows requirement
    });

    testWidgets('shows segmented control when unlocked', (tester) async {
      final gameState = GameState.initial().copyWith(
        totalCatsEarned: 2000000000, // 2B - above threshold
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
          ],
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      expect(find.text('Reincarnation'), findsOneWidget);
      expect(find.text('Prestige'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/reincarnation_screen_test.dart`
Expected: FAIL - teaser content and segmented control not present

**Step 3: Read current ReincarnationScreen**

```bash
cat lib/screens/reincarnation_screen.dart
```

**Step 4: Update ReincarnationScreen implementation**

Modify `lib/screens/reincarnation_screen.dart` to add enum and convert to StatefulWidget with segmented control:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/patron.dart';
import 'package:mythical_cats/models/primordial_upgrade.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/screens/achievements_screen.dart';

enum ReincarnationTab { prestige, achievements }

class ReincarnationScreen extends ConsumerStatefulWidget {
  const ReincarnationScreen({super.key});

  @override
  ConsumerState<ReincarnationScreen> createState() => _ReincarnationScreenState();
}

class _ReincarnationScreenState extends ConsumerState<ReincarnationScreen> {
  ReincarnationTab _selectedTab = ReincarnationTab.prestige;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final isUnlocked = gameState.totalCatsEarned >= 1000000000; // 1B

    if (!isUnlocked) {
      return _buildTeaserContent(context, gameState);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reincarnation'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<ReincarnationTab>(
                segments: const [
                  ButtonSegment(
                    value: ReincarnationTab.prestige,
                    label: Text('Prestige'),
                  ),
                  ButtonSegment(
                    value: ReincarnationTab.achievements,
                    label: Text('Achievements'),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (Set<ReincarnationTab> selected) {
                  setState(() {
                    _selectedTab = selected.first;
                  });
                },
              ),
            ),
            Expanded(
              child: _selectedTab == ReincarnationTab.prestige
                  ? _buildPrestigeContent(context, gameState, gameNotifier)
                  : const AchievementsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeaserContent(BuildContext context, gameState) {
    final progress = (gameState.totalCatsEarned / 1000000000).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reincarnation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade700, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.autorenew, size: 32, color: Colors.purple.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Reincarnation',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reset your progress to gain Primordial Essence, a powerful currency that persists across reincarnations.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Benefits:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet(context, 'Permanent production multipliers'),
                    _buildBullet(context, 'Choose a Patron god for unique bonuses'),
                    _buildBullet(context, 'Unlock powerful permanent upgrades'),
                    _buildBullet(context, 'Progress faster with each reincarnation'),
                    const SizedBox(height: 24),
                    Text(
                      'Unlock Requirement:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1.00B total cats earned',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormatter.format(gameState.totalCatsEarned)} / 1.00B',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
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

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildPrestigeContent(BuildContext context, gameState, gameNotifier) {
    // Keep existing prestige content (patron selection, upgrades, reincarnate button)
    // This is the current ReincarnationScreen body content
    final pe = gameNotifier.calculatePrimordialEssence();
    final currentPE = gameState.reincarnationState.availablePrimordialEssence;
    final totalPE = gameState.reincarnationState.totalPrimordialEssence;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PE Stats
          _PEStats(available: currentPE, total: totalPE, willEarn: pe),
          const SizedBox(height: 24),

          // Patron Selection
          Text(
            'Choose Your Patron',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PatronGrid(
            activePatron: gameState.reincarnationState.activePatron,
            onPatronSelected: (patron) {
              gameNotifier.setActivePatron(patron);
            },
          ),
          const SizedBox(height: 24),

          // Primordial Upgrades
          Text(
            'Primordial Upgrades',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _UpgradesList(
            ownedUpgradeIds: gameState.reincarnationState.ownedUpgradeIds,
            availablePE: currentPE,
            onPurchase: (upgrade) {
              gameNotifier.purchasePrimordialUpgrade(upgrade);
            },
            canPurchase: (upgrade) {
              return gameNotifier.canPurchasePrimordialUpgrade(upgrade);
            },
          ),
          const SizedBox(height: 24),

          // Reincarnate Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: pe > 0
                  ? () {
                      gameNotifier.reincarnate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reincarnated! Earned ${NumberFormatter.format(pe)} PE'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: Text(
                'Reincarnate (+${NumberFormatter.format(pe)} PE)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep existing helper widgets: _PEStats, _PatronGrid, _UpgradesList, etc.
// (Copy from current reincarnation_screen.dart)
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/widgets/reincarnation_screen_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/screens/reincarnation_screen.dart test/widgets/reincarnation_screen_test.dart
git commit -m "feat: add segmented control and teaser to ReincarnationScreen

Adds Prestige/Achievements segmented control when unlocked.
Shows teaser content with unlock progress when below 1B cats.
Integrates AchievementsScreen into Achievements tab."
```

---

## Task 4: Refactor HomeScreen to Use Bottom Navigation

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `test/widgets/phase4_ui_test.dart` (if needed)

**Step 1: Write the failing test**

Add to existing test file or create new test:

```dart
testWidgets('HomeScreen shows bottom navigation bar', (tester) async {
  final gameState = GameState.initial();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );

  // Should have bottom navigation with 5 destinations
  expect(find.byType(NavigationBar), findsOneWidget);
  expect(find.text('Home'), findsOneWidget);
  expect(find.text('Buildings'), findsOneWidget);
  expect(find.text('Divine Powers'), findsOneWidget);
  expect(find.text('Reincarnation'), findsOneWidget);
  expect(find.text('Settings'), findsOneWidget);

  // Should NOT have TabBar at top
  expect(find.byType(TabBar), findsNothing);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/phase4_ui_test.dart`
Expected: FAIL - TabBar still present, NavigationBar not found

**Step 3: Update HomeScreen implementation**

Modify `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/utils/number_formatter.dart';
import 'package:mythical_cats/screens/buildings_screen.dart';
import 'package:mythical_cats/screens/divine_powers_screen.dart';
import 'package:mythical_cats/screens/settings_screen.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/widgets/resource_panel.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Build screens for IndexedStack
    final screens = [
      const _HomeTab(),
      const BuildingsScreen(),
      const DivinePowersScreen(),
      const ReincarnationScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment),
            label: 'Buildings',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Divine Powers',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew),
            label: 'Reincarnation',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  God? _getNextGod(gameState) {
    final currentGodIndex = gameState.unlockedGods.last.index;
    if (currentGodIndex < God.values.length - 1) {
      return God.values[currentGodIndex + 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    final cats = gameState.getResource(ResourceType.cats);
    final catsPerSecond = gameNotifier.catsPerSecond;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mythical Cats'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Resource display
                _ResourceDisplay(
                  icon: ResourceType.cats.icon,
                  label: ResourceType.cats.displayName,
                  value: cats,
                  rate: catsPerSecond,
                ),
                const SizedBox(height: 16),

                // All resources panel
                const ResourcePanel(),
                const SizedBox(height: 24),

                // Prestige stats (if player has reincarnated)
                if (gameState.reincarnationState.totalReincarnations > 0)
                  PrestigeStatsPanel(
                    availablePE: gameState.reincarnationState.availablePrimordialEssence,
                    totalPE: gameState.reincarnationState.totalPrimordialEssence,
                    reincarnations: gameState.reincarnationState.totalReincarnations,
                    activePatron: gameState.reincarnationState.activePatron,
                    ownedUpgradeIds: gameState.reincarnationState.ownedUpgradeIds,
                    onTap: () {
                      // Navigate to Reincarnation tab (index 3)
                      final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                      homeScreenState?._onDestinationSelected(3);
                    },
                  ),
                if (gameState.reincarnationState.totalReincarnations > 0)
                  const SizedBox(height: 24),

                // Ritual button (click to generate cats)
                _RitualButton(
                  onPressed: () => gameNotifier.performRitual(),
                ),

                const SizedBox(height: 24),

                // Quick stats
                _QuickStats(
                  currentGod: gameState.unlockedGods.last.displayName,
                  totalEarned: gameState.totalCatsEarned,
                  nextGod: _getNextGod(gameState),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keep existing helper widgets: _ResourceDisplay, _RitualButton, _QuickStats, _StatRow
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/phase4_ui_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/screens/home_screen.dart test/widgets/phase4_ui_test.dart
git commit -m "refactor: replace top TabBar with bottom NavigationBar

Converts HomeScreen to StatefulWidget with bottom navigation.
Uses IndexedStack for state preservation across tabs.
Updates PrestigeStatsPanel to navigate to Reincarnation tab (index 3)."
```

---

## Task 5: Fix PrestigeStatsPanel Navigation

**Files:**
- Modify: `lib/widgets/prestige_stats_panel.dart`

**Step 1: Review current implementation**

```bash
cat lib/widgets/prestige_stats_panel.dart
```

**Step 2: Update navigation approach**

The current implementation tries to find `_HomeScreenState` via context, but this approach won't work well. Instead, pass the navigation callback as a parameter.

Modify `lib/widgets/prestige_stats_panel.dart`:

```dart
// Update onTap to be a simple VoidCallback
// The parent (HomeScreen) will handle the navigation
// No changes needed to this file - already receives onTap callback
```

Verify in `lib/screens/home_screen.dart` that the onTap is properly wired:

```dart
PrestigeStatsPanel(
  // ... other params
  onTap: () {
    setState(() {
      _selectedIndex = 3; // Navigate to Reincarnation tab
    });
  },
),
```

**Step 3: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "fix: wire PrestigeStatsPanel navigation to bottom nav

Uses setState to update selectedIndex when tapping prestige stats."
```

---

## Task 6: Update Tests for Bottom Navigation

**Files:**
- Modify: `test/widgets/phase4_ui_test.dart`
- Create: `test/widgets/bottom_navigation_test.dart`

**Step 1: Write comprehensive navigation tests**

Create `test/widgets/bottom_navigation_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';

void main() {
  group('Bottom Navigation', () {
    testWidgets('state preserved when switching tabs', (tester) async {
      final gameState = GameState.initial();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Tap Buildings tab
      await tester.tap(find.text('Buildings'));
      await tester.pumpAndSettle();

      // Go back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify Home tab content still visible
      expect(find.text('Perform Ritual'), findsOneWidget);
    });

    testWidgets('all tabs are accessible', (tester) async {
      final gameState = GameState.initial();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Test each tab
      final tabs = ['Home', 'Buildings', 'Divine Powers', 'Reincarnation', 'Settings'];

      for (final tab in tabs) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        // Verify navigation occurred (no specific assertion, just checking no errors)
      }
    });

    testWidgets('prestige stats panel navigates to reincarnation', (tester) async {
      final gameState = GameState.initial().copyWith(
        reincarnationState: GameState.initial().reincarnationState.copyWith(
          totalReincarnations: 1,
          totalPrimordialEssence: 100,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()..state = gameState),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Should be on Home tab
      expect(find.text('Perform Ritual'), findsOneWidget);

      // Tap prestige stats panel
      await tester.tap(find.text('Primordial Essence'));
      await tester.pumpAndSettle();

      // Should now be on Reincarnation tab
      expect(find.text('Prestige'), findsOneWidget); // Segmented control
    });
  });
}
```

**Step 2: Run tests**

Run: `flutter test test/widgets/bottom_navigation_test.dart`
Expected: PASS

**Step 3: Update existing phase4_ui_test.dart**

Remove or update tests that reference TabBar/TabController:

```dart
// Remove tests that check for TabBar
// Update tests to use bottom navigation instead
```

**Step 4: Run all tests**

Run: `flutter test`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add test/widgets/bottom_navigation_test.dart test/widgets/phase4_ui_test.dart
git commit -m "test: add bottom navigation tests

Tests state preservation, tab accessibility, and prestige panel navigation.
Updates existing tests to work with bottom navigation."
```

---

## Task 7: Final Integration Testing

**Step 1: Run full test suite**

```bash
flutter test
```

Expected: All tests PASS

**Step 2: Manual testing checklist**

Run the app and verify:
- [ ] Bottom navigation shows 5 tabs
- [ ] Tapping each tab switches content
- [ ] Divine Powers shows teaser when locked
- [ ] Divine Powers shows segmented control when Athena unlocked
- [ ] Reincarnation shows teaser when below 1B cats
- [ ] Reincarnation shows Prestige/Achievements tabs when unlocked
- [ ] Tapping prestige stats navigates to Reincarnation tab
- [ ] Tab state is preserved when switching
- [ ] No AppBar with tabs at top (except individual screens)

**Step 3: Final commit**

```bash
git add -A
git commit -m "docs: update implementation plan completion

All tasks completed:
- DivinePowersScreen with teaser and segmented control
- ReincarnationScreen with Prestige/Achievements tabs
- Bottom navigation replacing top tabs
- State preservation with IndexedStack
- Comprehensive test coverage"
```

---

## Completion Checklist

- [x] Task 1: DivinePowersScreen teaser state
- [x] Task 2: DivinePowersScreen segmented control
- [x] Task 3: ReincarnationScreen segmented control and teaser
- [x] Task 4: HomeScreen bottom navigation refactor
- [x] Task 5: PrestigeStatsPanel navigation fix
- [x] Task 6: Update tests for bottom navigation
- [x] Task 7: Final integration testing

**Completed:** 2025-11-13
**Test Results:** 407 passing, 14 expected timer warnings (IndexedStack + game loop interaction)
**Commits:** 9 commits from 447812a to fa05be5

---

## Notes

**Design Document:** See `docs/plans/2025-11-13-bottom-navigation-redesign.md` for full design rationale

**Key Decisions:**
- Used `IndexedStack` for state preservation across tabs
- `SegmentedButton` for iOS-style internal navigation
- Teaser content for locked features to build anticipation
- Fixed 5-tab bottom navigation following iOS guidelines

**Future Enhancements:**
- Consider persisting selected tab index to local storage
- Add animations when switching tabs
- Consider badge notifications on tabs (e.g., new achievements)
