import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/primordial_force_section.dart';
import 'package:mythical_cats/models/primordial_force.dart';
import 'package:mythical_cats/models/primordial_upgrade_definitions.dart';

void main() {
  group('PrimordialForceSection', () {
    testWidgets('displays force header correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimordialForceSection(
                force: PrimordialForce.chaos,
                ownedUpgradeIds: const {'chaos_1', 'chaos_2'},
                availablePE: 50,
                onPurchase: (id) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('⚡ Chaos'), findsOneWidget);
      expect(find.text('Active Play - Click Power'), findsOneWidget);
      expect(find.text('2/5 upgrades owned'), findsOneWidget);
    });

    testWidgets('displays all 5 upgrade cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimordialForceSection(
                force: PrimordialForce.gaia,
                ownedUpgradeIds: const {},
                availablePE: 100,
                onPurchase: (id) {},
              ),
            ),
          ),
        ),
      );

      // Should have 5 upgrade cards
      expect(find.byType(Card), findsNWidgets(5));
      expect(find.text('Tier 1'), findsOneWidget);
      expect(find.text('Tier 2'), findsOneWidget);
      expect(find.text('Tier 3'), findsOneWidget);
      expect(find.text('Tier 4'), findsOneWidget);
      expect(find.text('Tier 5'), findsOneWidget);
    });

    testWidgets('calls onPurchase with correct upgrade ID', (tester) async {
      String? purchasedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimordialForceSection(
                force: PrimordialForce.chaos,
                ownedUpgradeIds: const {},
                availablePE: 100,
                onPurchase: (id) => purchasedId = id,
              ),
            ),
          ),
        ),
      );

      // Find and tap first purchase button
      await tester.tap(find.text('Purchase').first);
      expect(purchasedId, 'chaos_1');
    });
  });
}
