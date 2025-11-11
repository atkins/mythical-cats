import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/patron_selector.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PatronSelector', () {
    testWidgets('displays all 4 force buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'gaia_1'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      expect(find.text('Chaos'), findsOneWidget);
      expect(find.text('Gaia'), findsOneWidget);
      expect(find.text('Nyx'), findsOneWidget);
      expect(find.text('Erebus'), findsOneWidget);
      expect(find.text('Active Patron'), findsOneWidget);
    });

    testWidgets('highlights active patron', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.gaia,
              ownedUpgradeIds: const {'gaia_1'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('🌿 Gaia'), findsOneWidget);
    });

    testWidgets('calls onPatronSelected when button tapped', (tester) async {
      PrimordialForce? selectedForce;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'gaia_1', 'nyx_1'},
              onPatronSelected: (force) => selectedForce = force,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Gaia'));
      expect(selectedForce, PrimordialForce.gaia);
    });

    testWidgets('disables forces with no upgrades', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      // Chaos should be enabled, others disabled
      final chaosButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Chaos'),
      );
      expect(chaosButton.onPressed, isNotNull);

      final gaiaButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gaia'),
      );
      expect(gaiaButton.onPressed, isNull);
    });

    testWidgets('displays active patron bonus text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatronSelector(
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'chaos_2'},
              onPatronSelected: (force) {},
            ),
          ),
        ),
      );

      // Should show chaos icon and bonus (0.5 + 2*0.1 = 0.7 = 70%)
      expect(find.textContaining('⚡ Chaos'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });
  });
}
