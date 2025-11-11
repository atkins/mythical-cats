import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/primordial_upgrade_card.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrimordialUpgradeCard', () {
    testWidgets('displays owned state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'chaos_1',
              force: PrimordialForce.chaos,
              tier: 1,
              name: 'Chaos I',
              effect: '+10% click power',
              cost: 10,
              isOwned: true,
              canAfford: false,
              isLocked: false,
              onPurchase: () {},
            ),
          ),
        ),
      );

      expect(find.text('Chaos I'), findsOneWidget);
      expect(find.text('+10% click power'), findsOneWidget);
      expect(find.text('Owned'), findsOneWidget);
      expect(find.text('Tier 1'), findsOneWidget);
    });

    testWidgets('displays affordable state with purchase button', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'chaos_2',
              force: PrimordialForce.chaos,
              tier: 2,
              name: 'Chaos II',
              effect: '+25% click power',
              cost: 25,
              isOwned: false,
              canAfford: true,
              isLocked: false,
              onPurchase: () => wasTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Purchase'), findsOneWidget);
      expect(find.text('25 PE'), findsOneWidget);

      await tester.tap(find.text('Purchase'));
      expect(wasTapped, true);
    });

    testWidgets('displays locked state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'chaos_3',
              force: PrimordialForce.chaos,
              tier: 3,
              name: 'Chaos III',
              effect: '+50% click power',
              cost: 50,
              isOwned: false,
              canAfford: false,
              isLocked: true,
              onPurchase: () {},
            ),
          ),
        ),
      );

      expect(find.text('Requires Tier 2'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays unaffordable state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimordialUpgradeCard(
              upgradeId: 'gaia_1',
              force: PrimordialForce.gaia,
              tier: 1,
              name: 'Gaia I',
              effect: '+15% production',
              cost: 10,
              isOwned: false,
              canAfford: false,
              isLocked: false,
              onPurchase: () {},
            ),
          ),
        ),
      );

      expect(find.text('10 PE'), findsOneWidget);
      // Button should be disabled when not affordable
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Purchase'),
      );
      expect(button.onPressed, null);
    });
  });
}
