import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/prophecy.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/screens/prophecy_screen.dart';

void main() {
  testWidgets('ProphecyScreen displays all 10 prophecies', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    await tester.pump();

    // Should show all prophecy names (visible in viewport)
    expect(find.text('Vision of Prosperity'), findsOneWidget);
    expect(find.text('Solar Blessing'), findsOneWidget);
    expect(find.text('Glimpse of Research'), findsOneWidget);
  });

  testWidgets('ProphecyScreen shows Wisdom balance', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.textContaining('Wisdom:'), findsOneWidget);
  });

  testWidgets('ProphecyScreen grouped by tier', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Tier 1: Minor Prophecies'), findsOneWidget);
    expect(find.text('Tier 2: Standard Prophecies'), findsOneWidget);
    expect(find.text('Tier 3: Major Prophecies'), findsOneWidget);
  });

  testWidgets('ProphecyScreen displays wisdom production rate', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    await tester.pump();

    // Should show production rate even if 0
    expect(find.textContaining('/sec'), findsOneWidget);
  });

  testWidgets('ProphecyCard shows activate buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    await tester.pump();

    // Should show activate buttons for all prophecies
    expect(find.text('Activate'), findsWidgets);
  });

  testWidgets('ProphecyScreen displays all prophecy cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProphecyScreen(),
        ),
      ),
    );

    await tester.pump();

    // Should display all 10 prophecies by type
    for (final prophecy in ProphecyType.values) {
      expect(find.text(prophecy.displayName), findsOneWidget);
    }
  });
}
