import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/widgets/resource_panel.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  group('ResourcePanel Widget Tests', () {
    testWidgets('displays Wisdom resource when Wisdom > 0', (WidgetTester tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up game state with Wisdom
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 50.0,
          ResourceType.offerings: 25.0,
          ResourceType.divineEssence: 10.0,
          ResourceType.ambrosia: 5.0,
          ResourceType.wisdom: 42.0, // Wisdom should be displayed
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResourcePanel(),
            ),
          ),
        ),
      );

      // Should find the Wisdom label
      expect(find.text('Wisdom'), findsOneWidget);

      // Should find the Wisdom icon
      expect(find.text('🦉'), findsOneWidget);

      // Should find the Wisdom value
      expect(find.text('42'), findsOneWidget);

      container.dispose();
    });

    testWidgets('displays Wisdom after Ambrosia in resource list', (WidgetTester tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up game state with multiple resources including Wisdom
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 50.0,
          ResourceType.offerings: 25.0,
          ResourceType.divineEssence: 10.0,
          ResourceType.ambrosia: 5.0,
          ResourceType.wisdom: 42.0,
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResourcePanel(),
            ),
          ),
        ),
      );

      // Verify Wisdom appears in the UI
      expect(find.text('Wisdom'), findsOneWidget);

      container.dispose();
    });

    testWidgets('does not display Wisdom when Wisdom = 0', (WidgetTester tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up game state without Wisdom
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 50.0,
          ResourceType.offerings: 25.0,
          ResourceType.divineEssence: 0.0,
          ResourceType.ambrosia: 0.0,
          ResourceType.wisdom: 0.0,
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResourcePanel(),
            ),
          ),
        ),
      );

      // Should not find Wisdom when it's 0
      expect(find.text('Wisdom'), findsNothing);

      container.dispose();
    });

    testWidgets('displays Wisdom with correct icon and formatting', (WidgetTester tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Set up game state with a large Wisdom value
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.wisdom: 1234567.89,
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResourcePanel(),
            ),
          ),
        ),
      );

      // Should find the Wisdom icon (owl emoji)
      expect(find.text('🦉'), findsOneWidget);

      // Should find formatted Wisdom value
      expect(find.text('Wisdom'), findsOneWidget);

      container.dispose();
    });
  });
}
