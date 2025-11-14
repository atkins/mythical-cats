import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/reincarnation_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';

void main() {
  group('ReincarnationScreen', () {
    testWidgets('shows teaser content when below 1B cats', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 500000000, // 500M - below threshold
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      // "Reincarnation" appears in both AppBar and body content
      expect(find.text('Reincarnation'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Primordial Essence'), findsOneWidget);
      expect(find.textContaining('1.00B'), findsAtLeastNWidgets(1)); // Shows requirement

      container.dispose();
    });

    testWidgets('shows segmented control when unlocked', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 2000000000, // 2B - above threshold
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ReincarnationScreen(),
          ),
        ),
      );

      expect(find.text('Reincarnation'), findsAtLeastNWidgets(1));
      expect(find.text('Prestige'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);

      container.dispose();
    });
  });
}
