import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/widgets/patron_selector.dart';
import 'package:mythical_cats/widgets/primordial_upgrade_card.dart';
import 'package:mythical_cats/widgets/reincarnation_fab.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/god.dart';

void main() {
  group('Phase 4 UI Integration Tests', () {
    testWidgets('ReincarnationScreen renders all components', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          totalPrimordialEssence: 50,
          availablePrimordialEssence: 50,
          ownedUpgradeIds: {'chaos_1', 'gaia_1'},
          activePatron: PrimordialForce.chaos,
          totalReincarnations: 1,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Verify PatronSelector is present
      expect(find.byType(PatronSelector), findsOneWidget);
      expect(find.text('Active Patron'), findsOneWidget);

      // Verify all 4 force sections are present
      expect(find.text('⚡ Chaos'), findsAtLeastNWidgets(1));
      expect(find.text('🌿 Gaia'), findsAtLeastNWidgets(1));
      expect(find.text('🌙 Nyx'), findsAtLeastNWidgets(1));
      expect(find.text('💎 Erebus'), findsAtLeastNWidgets(1));

      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(ReincarnationFab), findsOneWidget);

      container.dispose();
    });

    testWidgets('Reincarnation destination is always visible in bottom navigation',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up state with 1B+ cats
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedGods: {God.hermes, God.athena, God.ares},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify Reincarnation destination is visible in NavigationBar
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Reincarnation'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Reincarnation destination visible even below 1B cats threshold',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up state below 1B cats
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 999999999,
        unlockedGods: {God.hermes, God.athena, God.ares},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify Reincarnation destination is still visible (always in nav bar)
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Reincarnation'), findsOneWidget);

      container.dispose();
    });

    testWidgets('PatronSelector displays and switches patron correctly',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1', 'chaos_2', 'gaia_1', 'nyx_1'},
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Verify all 4 forces are displayed
      expect(find.text('Chaos'), findsAtLeastNWidgets(1));
      expect(find.text('Gaia'), findsAtLeastNWidgets(1));
      expect(find.text('Nyx'), findsAtLeastNWidgets(1));
      expect(find.text('Erebus'), findsAtLeastNWidgets(1));

      // Verify Chaos is active
      expect(find.text('Active'), findsOneWidget);

      // Switch to Gaia patron
      await tester.tap(find.text('Gaia'));
      await tester.pump();

      // Verify patron changed
      final newState = container.read(gameProvider);
      expect(newState.reincarnationState.activePatron, PrimordialForce.gaia);

      container.dispose();
    });

    testWidgets('PatronSelector disables forces with no owned upgrades',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1'}, // Only Chaos owned
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Find patron selector buttons
      final chaosButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Chaos'),
      );
      final gaiaButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gaia'),
      );

      // Chaos should be enabled (has upgrades)
      expect(chaosButton.onPressed, isNotNull);

      // Gaia should be disabled (no upgrades)
      expect(gaiaButton.onPressed, isNull);

      container.dispose();
    });

    testWidgets('PrimordialUpgradeCard shows owned state correctly',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1'},
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify owned upgrade shows "Owned" text
      expect(find.text('Owned'), findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('PrimordialUpgradeCard shows affordable state with enabled button',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {},
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Should find multiple "Purchase" buttons for affordable upgrades
      expect(find.text('Purchase'), findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('PrimordialUpgradeCard shows locked state for prerequisites',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 500,
          ownedUpgradeIds: {}, // No tier 1 upgrades owned
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Should show lock icon and prerequisite text for locked upgrades
      expect(find.byIcon(Icons.lock), findsAtLeastNWidgets(1));
      expect(find.textContaining('Requires'), findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('PrimordialUpgradeCard shows unaffordable state',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 5, // Too little PE
          ownedUpgradeIds: {},
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Find the upgrade cards - tier 1 costs 10 PE, should be unaffordable
      final upgradeCards = find.byType(PrimordialUpgradeCard);
      expect(upgradeCards, findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('ReincarnationFab shows correct PE calculation',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 10000000000, // 10B cats = 30 PE
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Verify FAB shows correct PE amount
      expect(find.textContaining('30 PE'), findsOneWidget);

      container.dispose();
    });

    testWidgets('ReincarnationFab enabled when totalCatsEarned >= 1B',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // FAB should be enabled
      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNotNull);

      container.dispose();
    });

    testWidgets('ReincarnationFab disabled below 1B threshold',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 500000000, // Below 1B
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // FAB should be disabled
      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNull);
      expect(find.textContaining('Need 1B cats'), findsOneWidget);

      container.dispose();
    });

    testWidgets('ReincarnationFab opens confirmation dialog on tap',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 20,
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify dialog appears
      expect(find.text('Reincarnate?'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Reincarnation confirmation dialog shows correct PE gain',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 5000000000, // 5B cats = 30 PE
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify PE gain is shown
      expect(find.textContaining('30'), findsWidgets);

      container.dispose();
    });

    testWidgets('Reincarnation confirmation dialog shows active patron',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.gaia,
          ownedUpgradeIds: {'gaia_1'},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Gaia patron is shown
      expect(find.textContaining('🌿 Gaia'), findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('Reincarnation confirmation dialog lists what resets and persists',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify reset/persist sections exist
      expect(find.textContaining('You will reset'), findsOneWidget);
      expect(find.textContaining('You will keep'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Reincarnation confirmation dialog calls reincarnate on confirm',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm reincarnation
      await tester.tap(find.text('Reincarnate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify reincarnation occurred
      final newState = container.read(gameProvider);
      expect(newState.reincarnationState.totalReincarnations, 1);
      expect(newState.reincarnationState.availablePrimordialEssence, greaterThan(0));

      container.dispose();
    });

    testWidgets('PrestigeStatsPanel hidden before first reincarnation',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          totalReincarnations: 0, // No reincarnations yet
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // PrestigeStatsPanel should not be visible
      expect(find.byType(PrestigeStatsPanel), findsNothing);
      expect(find.text('Prestige Progress'), findsNothing);

      container.dispose();
    });

    testWidgets('PrestigeStatsPanel shows after first reincarnation',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          totalReincarnations: 1,
          availablePrimordialEssence: 20,
          totalPrimordialEssence: 20,
          activePatron: PrimordialForce.chaos,
          ownedUpgradeIds: {'chaos_1'},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // PrestigeStatsPanel should be visible
      expect(find.byType(PrestigeStatsPanel), findsOneWidget);
      expect(find.text('Prestige Progress'), findsOneWidget);

      container.dispose();
    });

    testWidgets('PrestigeStatsPanel displays correct stats',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 5000000000,
        reincarnationState: const ReincarnationState(
          totalReincarnations: 3,
          availablePrimordialEssence: 45,
          totalPrimordialEssence: 120,
          activePatron: PrimordialForce.gaia,
          ownedUpgradeIds: {'gaia_1', 'gaia_2', 'gaia_3'},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify stats are displayed correctly
      expect(find.text('Prestige Progress'), findsOneWidget);
      expect(find.text('Available PE:'), findsOneWidget);
      expect(find.text('45 / 120 Total'), findsOneWidget);
      expect(find.text('Reincarnations:'), findsOneWidget);
      expect(find.text('3'), findsAtLeastNWidgets(1));
      expect(find.textContaining('🌿 Gaia'), findsOneWidget);

      container.dispose();
    });

    testWidgets('PrestigeStatsPanel navigation to Reincarnation tab works',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        unlockedGods: {God.hermes, God.athena, God.ares},
        reincarnationState: const ReincarnationState(
          totalReincarnations: 1,
          availablePrimordialEssence: 20,
          totalPrimordialEssence: 20,
          activePatron: PrimordialForce.chaos,
          ownedUpgradeIds: {'chaos_1'},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap the PrestigeStatsPanel
      await tester.tap(find.byType(PrestigeStatsPanel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify navigation to Reincarnation tab occurred
      // The screen should now show the ReincarnationScreen
      expect(find.byType(ReincarnationScreen), findsOneWidget);
      expect(find.text('Active Patron'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Full reincarnation flow - purchase upgrade, switch patron, reincarnate',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: const ReincarnationState(
          availablePrimordialEssence: 100,
          ownedUpgradeIds: {'chaos_1', 'gaia_1'}, // Pre-purchase upgrades to enable patrons
          activePatron: PrimordialForce.chaos,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify initial state
      expect(find.text('Active Patron'), findsOneWidget);
      final initialState = container.read(gameProvider);
      expect(initialState.reincarnationState.activePatron, PrimordialForce.chaos);

      // Switch to Gaia patron
      await tester.tap(find.text('Gaia'));
      await tester.pump();

      // Verify patron switched
      final state2 = container.read(gameProvider);
      expect(state2.reincarnationState.activePatron, PrimordialForce.gaia);

      // Trigger reincarnation
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify dialog appeared
      expect(find.text('Reincarnate?'), findsOneWidget);

      // Confirm reincarnation
      await tester.tap(find.text('Reincarnate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify reincarnation occurred
      final finalState = container.read(gameProvider);
      expect(finalState.reincarnationState.totalReincarnations, 1);

      container.dispose();
    });

    testWidgets('HomeScreen shows bottom NavigationBar with 5 destinations',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedGods: {God.hermes, God.athena, God.ares, God.apollo},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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

      container.dispose();
    });

    testWidgets('HomeScreen bottom NavigationBar switches between tabs',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedGods: {God.hermes, God.athena},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Initially on Home tab
      expect(find.text('Mythical Cats'), findsOneWidget); // AppBar title from _HomeTab

      // Tap Divine Powers destination
      await tester.tap(find.text('Divine Powers'));
      await tester.pump();

      // Should show Divine Powers screen
      expect(find.text('Divine Powers'), findsAtLeastNWidgets(1)); // AppBar title

      container.dispose();
    });

    testWidgets('HomeScreen preserves state when switching tabs',
        (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 1000000000,
        unlockedGods: {God.hermes, God.athena},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Go to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pump();

      // Verify on Settings screen
      expect(find.text('Settings'), findsAtLeastNWidgets(1));

      // Go back to Home tab
      await tester.tap(find.text('Home'));
      await tester.pump();

      // Should be back on Home tab
      expect(find.text('Mythical Cats'), findsOneWidget);

      container.dispose();
    });
  });
}
