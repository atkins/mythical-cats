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
  });
}
