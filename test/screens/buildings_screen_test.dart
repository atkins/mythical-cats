import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/buildings_screen.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/widgets/building_card.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  group('BuildingsScreen Athena/Apollo Sections', () {
    testWidgets('BuildingsScreen renders without crashing',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BuildingsScreen(),
          ),
        ),
      );

      // Should find the buildings screen
      expect(find.byType(BuildingsScreen), findsOneWidget);

      // Should find at least one section header
      expect(find.text('Basic Buildings', skipOffstage: false), findsOneWidget);

      container.dispose();
    });

    testWidgets('BuildingsScreen shows building cards',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BuildingsScreen(),
          ),
        ),
      );

      // Should find building cards
      expect(find.byType(BuildingCard, skipOffstage: false), findsWidgets);

      container.dispose();
    });

    testWidgets('BuildingsScreen has organized sections',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BuildingsScreen(),
          ),
        ),
      );

      // Should find section headers (Basic Buildings should always be present)
      expect(find.text('Basic Buildings', skipOffstage: false), findsOneWidget);

      // Should find basic shrine buildings
      expect(find.text('Small Shrine', skipOffstage: false), findsOneWidget);
      expect(find.text('Temple', skipOffstage: false), findsOneWidget);
      expect(find.text('Grand Sanctuary', skipOffstage: false), findsOneWidget);

      container.dispose();
    });

    testWidgets('Athena and Apollo buildings are defined in enum',
        (WidgetTester tester) async {
      // Verify that the building types exist in the enum
      expect(BuildingType.values, contains(BuildingType.hallOfWisdom));
      expect(BuildingType.values, contains(BuildingType.academyOfAthens));
      expect(BuildingType.values, contains(BuildingType.strategyChamber));
      expect(BuildingType.values, contains(BuildingType.oraclesArchive));
      expect(BuildingType.values, contains(BuildingType.templeOfDelphi));
      expect(BuildingType.values, contains(BuildingType.sunChariotStable));
      expect(BuildingType.values, contains(BuildingType.musesSanctuary));
      expect(BuildingType.values, contains(BuildingType.celestialObservatory));
    });

    testWidgets('Building cards display required information',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BuildingsScreen(),
          ),
        ),
      );

      // Should show owned count for buildings
      expect(find.textContaining('Owned:', skipOffstage: false), findsWidgets);

      // Should show production info
      expect(find.textContaining('Production:', skipOffstage: false), findsWidgets);

      // Should show cost info
      expect(find.textContaining('Cost:', skipOffstage: false), findsWidgets);

      container.dispose();
    });
  });
}
