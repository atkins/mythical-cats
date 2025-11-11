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
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
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

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      expect(find.text('Active Patron'), findsOneWidget);
      expect(find.text('⚡ Chaos'), findsAtLeastNWidgets(1));
      expect(find.text('🌿 Gaia'), findsAtLeastNWidgets(1));
      expect(find.text('🌙 Nyx'), findsAtLeastNWidgets(1));
      expect(find.text('💎 Erebus'), findsAtLeastNWidgets(1));
      expect(find.byType(FloatingActionButton), findsOneWidget);

      container.dispose();
    });

    testWidgets('FAB shows correct PE calculation', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 10000000000, // 10B cats = 30 PE
        reincarnationState: const ReincarnationState(),
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
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000,
        reincarnationState: ReincarnationState(
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

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // Build the dialog
      await tester.pump(const Duration(milliseconds: 100)); // Animation frame

      expect(find.text('Reincarnate?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reincarnate'), findsOneWidget);

      container.dispose();
    });
  });
}
