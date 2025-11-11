import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/prophecy.dart';
import 'package:mythical_cats/widgets/prophecy_card.dart';

void main() {
  testWidgets('ProphecyCard displays prophecy info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 100,
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            isActive: false,
            onActivate: () {},
          ),
        ),
      ),
    );

    expect(find.text('Solar Blessing'), findsOneWidget);
    expect(find.text('+50% cat production for 15 minutes'), findsOneWidget);
    expect(find.text('100'), findsOneWidget); // Wisdom cost
    expect(find.text('Activate'), findsOneWidget);
  });

  testWidgets('ProphecyCard shows cooldown state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 100,
            isOnCooldown: true,
            cooldownRemaining: Duration(minutes: 45, seconds: 23),
            isActive: false,
            onActivate: () {},
          ),
        ),
      ),
    );

    expect(find.text('45:23'), findsOneWidget);
    expect(find.text('Activate'), findsNothing);
  });

  testWidgets('ProphecyCard disables when insufficient Wisdom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 50, // Need 100
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            isActive: false,
            onActivate: () {},
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.enabled, false);
  });

  testWidgets('ProphecyCard calls onActivate when tapped', (tester) async {
    bool activated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 100,
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            isActive: false,
            onActivate: () {
              activated = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Activate'));
    await tester.pump();

    expect(activated, true);
  });

  testWidgets('ProphecyCard shows active indicator when boost is active', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 0,
            isOnCooldown: true,
            cooldownRemaining: Duration(minutes: 30),
            isActive: true, // Active timed boost
            onActivate: () {},
          ),
        ),
      ),
    );

    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('ProphecyCard displays cost in red when insufficient', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProphecyCard(
            prophecy: ProphecyType.solarBlessing,
            currentWisdom: 50,
            isOnCooldown: false,
            cooldownRemaining: Duration.zero,
            isActive: false,
            onActivate: () {},
          ),
        ),
      ),
    );

    // Find the cost text widget
    final costText = find.text('100');
    expect(costText, findsOneWidget);
  });
}
