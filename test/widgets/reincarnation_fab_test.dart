import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/widgets/reincarnation_fab.dart';

void main() {
  group('ReincarnationFab', () {
    testWidgets('displays PE preview when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 25,
              isEnabled: true,
              catsRemaining: 0,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Reincarnate for 25 PE'), findsOneWidget);
      expect(find.byIcon(Icons.autorenew), findsOneWidget);
    });

    testWidgets('shows remaining cats when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 0,
              isEnabled: false,
              catsRemaining: 500000000,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Need 1B cats'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped and enabled', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 30,
              isEnabled: true,
              catsRemaining: 0,
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      expect(wasTapped, true);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
            floatingActionButton: ReincarnationFab(
              peEarned: 0,
              isEnabled: false,
              catsRemaining: 999999999,
              onPressed: () => wasTapped = true,
            ),
          ),
        ),
      );

      // FAB should not be tappable when disabled
      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNull);
      expect(wasTapped, false);
    });
  });
}
