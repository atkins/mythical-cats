import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/reincarnation_state.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('Bottom Navigation', () {
    testWidgets('state preserved when switching tabs', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = GameState.initial();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Tap Buildings tab
      await tester.tap(find.text('Buildings'));
      await tester.pump();

      // Go back to Home
      await tester.tap(find.text('Home'));
      await tester.pump();

      // Verify Home tab content still visible
      expect(find.text('Feed Kibbies'), findsOneWidget);

      container.dispose();
    });

    testWidgets('all tabs are accessible', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = GameState.initial();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Test Home tab
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(find.text('Feed Kibbies'), findsOneWidget);

      // Test Buildings tab
      await tester.tap(find.text('Buildings'));
      await tester.pump();
      expect(find.text('Buildings'), findsAtLeastNWidgets(1)); // AppBar + nav

      // Test Divine Powers tab
      await tester.tap(find.text('Divine Powers'));
      await tester.pump();
      expect(find.text('Divine Powers'), findsAtLeastNWidgets(1)); // AppBar + nav

      // Test Reincarnation tab
      await tester.tap(find.text('Reincarnation'));
      await tester.pump();
      expect(find.text('Reincarnation'), findsAtLeastNWidgets(1)); // AppBar + nav

      // Test Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(find.text('Settings'), findsAtLeastNWidgets(1)); // AppBar + nav

      container.dispose();
    });

    testWidgets('prestige stats panel navigates to reincarnation', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        unlockedGods: {God.hermes, God.athena, God.ares},
        reincarnationState: const ReincarnationState(
          totalReincarnations: 1,
          availablePrimordialEssence: 20,
          totalPrimordialEssence: 100,
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

      // Should be on Home tab
      expect(find.text('Feed Kibbies'), findsOneWidget);

      // Tap the PrestigeStatsPanel
      await tester.tap(find.byType(PrestigeStatsPanel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should now be on Reincarnation tab
      expect(find.byType(ReincarnationScreen), findsOneWidget);
      expect(find.text('Prestige'), findsOneWidget); // Segmented control

      container.dispose();
    });
  });
}
