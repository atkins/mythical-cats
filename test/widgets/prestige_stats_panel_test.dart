import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/prestige_stats_panel.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  group('PrestigeStatsPanel', () {
    testWidgets('is hidden when no reincarnations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 0,
              totalPE: 0,
              reincarnations: 0,
              activePatron: null,
              ownedUpgradeIds: const {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Prestige Progress'), findsNothing);
    });

    testWidgets('displays stats after first reincarnation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 45,
              totalPE: 120,
              reincarnations: 3,
              activePatron: PrimordialForce.chaos,
              ownedUpgradeIds: const {'chaos_1', 'chaos_2'},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Prestige Progress'), findsOneWidget);
      expect(find.text('Available PE:'), findsOneWidget);
      expect(find.text('45 / 120 Total'), findsOneWidget);
      expect(find.text('Reincarnations:'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays active patron bonus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 50,
              totalPE: 100,
              reincarnations: 2,
              activePatron: PrimordialForce.gaia,
              ownedUpgradeIds: const {'gaia_1', 'gaia_2', 'gaia_3'},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('🌿 Gaia'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 30,
              totalPE: 50,
              reincarnations: 1,
              activePatron: PrimordialForce.nyx,
              ownedUpgradeIds: const {'nyx_1'},
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(wasTapped, true);
    });

    testWidgets('shows "No patron" when patron is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrestigeStatsPanel(
              availablePE: 20,
              totalPE: 20,
              reincarnations: 1,
              activePatron: null,
              ownedUpgradeIds: const {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('No patron selected'), findsOneWidget);
    });
  });
}
