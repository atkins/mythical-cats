import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/settings_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsScreen Developer Tools', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('SettingsScreen renders without crashing', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = GameState.initial();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Wait for async initialization
      await tester.pump(const Duration(milliseconds: 100));

      // Should find the settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Should find statistics section
      expect(find.text('Statistics'), findsOneWidget);

      container.dispose();
    });

    testWidgets('developer mode persists when set in SharedPreferences', (tester) async {
      // Set dev mode in SharedPreferences
      SharedPreferences.setMockInitialValues({'developer_mode_enabled': true});

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = GameState.initial();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Wait for async initialization
      await tester.pump(const Duration(milliseconds: 100));

      // Should show Developer Tools section (persisted from SharedPreferences)
      expect(find.text('Developer Tools'), findsOneWidget);

      container.dispose();
    });
  });
}
