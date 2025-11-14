import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/widgets/compact_resource_bar.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  group('CompactResourceBar', () {
    testWidgets('displays core resources (Cats, Prayers, Offerings)', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 1234.0,
          ResourceType.prayers: 567.0,
          ResourceType.offerings: 89.0,
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      // Should find cat, prayer, and offering emojis
      expect(find.textContaining('🐱'), findsOneWidget);
      expect(find.textContaining('🙏'), findsOneWidget);
      expect(find.textContaining('🎁'), findsOneWidget);

      // Should find formatted values
      expect(find.textContaining('1.2K'), findsOneWidget); // Cats
      expect(find.textContaining('567'), findsOneWidget);  // Prayers
      expect(find.textContaining('89'), findsOneWidget);   // Offerings

      container.dispose();
    });

    testWidgets('shows Divine Essence when > 0', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 100.0,
          ResourceType.offerings: 100.0,
          ResourceType.divineEssence: 50.0, // Should show
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      expect(find.textContaining('✨'), findsOneWidget);
      expect(find.textContaining('50'), findsAtLeastNWidgets(1));

      container.dispose();
    });

    testWidgets('hides Divine Essence when 0', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100.0,
          ResourceType.prayers: 100.0,
          ResourceType.offerings: 100.0,
          ResourceType.divineEssence: 0.0, // Should not show
        },
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      expect(find.textContaining('✨'), findsNothing);

      container.dispose();
    });

    testWidgets('displays production rates', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompactResourceBar(),
            ),
          ),
        ),
      );

      // Should find rate indicators like "+10/s" or "+0/s"
      expect(find.textContaining('/s'), findsAtLeastNWidgets(3)); // At least for core 3

      container.dispose();
    });
  });
}
