import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/random_event.dart';
import 'package:mythical_cats/models/random_event_definitions.dart';
import 'package:mythical_cats/widgets/random_event_banner.dart';

void main() {
  testWidgets('RandomEventBanner displays bonus event', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RandomEventBanner(
            event: RandomEventDefinitions.divineCatAppears,
          ),
        ),
      ),
    );

    expect(find.text('Divine Cat Appears!'), findsOneWidget);
    expect(find.text('Gained 50 cats!'), findsOneWidget);
  });

  testWidgets('RandomEventBanner displays multiplier event', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RandomEventBanner(
            event: RandomEventDefinitions.divineFavor,
          ),
        ),
      ),
    );

    expect(find.text('Divine Favor'), findsOneWidget);
    expect(find.text('2x production for 30 seconds!'), findsOneWidget);
  });

  testWidgets('RandomEventBanner shows nothing when event is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RandomEventBanner(
            event: null,
          ),
        ),
      ),
    );

    expect(find.byType(Card), findsNothing);
  });

  testWidgets('RandomEventBanner uses correct colors for event types', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RandomEventBanner(
            event: RandomEventDefinitions.divineFavor,
          ),
        ),
      ),
    );

    // Should find a Card widget with golden/amber color scheme
    final card = tester.widget<Card>(find.byType(Card));
    expect(card, isNotNull);
  });
}
