import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/divine_powers_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/god.dart';

// Import DivinePowerTab enum
// ignore: implementation_imports
import 'package:mythical_cats/screens/divine_powers_screen.dart' show DivinePowerTab;

void main() {
  group('DivinePowersScreen', () {
    testWidgets('shows teaser content when no gods unlocked', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up game state with only Hermes (doesn't count as divine god)
      notifier.state = notifier.state.copyWith(
        unlockedGods: {God.hermes},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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

      container.dispose();
    });

    testWidgets('shows segmented control when gods unlocked', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up game state with Athena and Ares unlocked
      notifier.state = notifier.state.copyWith(
        unlockedGods: {God.hermes, God.athena, God.ares},
        totalCatsEarned: 1000000000, // 1B
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DivinePowersScreen(),
          ),
        ),
      );

      expect(find.text('Divine Powers'), findsOneWidget);
      // Verify SegmentedButton exists
      expect(find.byType(SegmentedButton<DivinePowerTab>), findsOneWidget);

      // Verify the labels are present (will find multiple since SegmentedButton renders text multiple times)
      expect(find.text('Research'), findsWidgets);
      expect(find.text('Conquest'), findsWidgets);
      expect(find.text('Prophecy'), findsNothing); // Apollo not unlocked

      container.dispose();
    });
  });
}
