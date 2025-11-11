import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/prophecy.dart';

void main() {
  group('ProphecyType', () {
    test('Vision of Prosperity has correct properties', () {
      final prophecy = ProphecyType.visionOfProsperity;
      expect(prophecy.displayName, 'Vision of Prosperity');
      expect(prophecy.wisdomCost, 50);
      expect(prophecy.cooldownMinutes, 30);
      expect(prophecy.tier, 1);
      expect(prophecy.effectType, ProphecyEffectType.informational);
    });

    test('Solar Blessing has correct properties', () {
      final prophecy = ProphecyType.solarBlessing;
      expect(prophecy.displayName, 'Solar Blessing');
      expect(prophecy.wisdomCost, 100);
      expect(prophecy.cooldownMinutes, 60);
      expect(prophecy.tier, 1);
      expect(prophecy.effectType, ProphecyEffectType.timedBoost);
      expect(prophecy.durationMinutes, 15);
      expect(prophecy.productionMultiplier, 1.5); // +50%
    });
  });

  group('ProphecyState', () {
    test('Prophecy starts in ready state', () {
      final state = ProphecyState.initial();
      expect(state.isOnCooldown(ProphecyType.visionOfProsperity), false);
    });

    test('Activating prophecy starts cooldown', () {
      final now = DateTime.now();
      final state = ProphecyState.initial().activate(
        ProphecyType.visionOfProsperity,
        now,
      );

      expect(state.isOnCooldown(ProphecyType.visionOfProsperity), true);
      expect(state.getCooldownRemaining(ProphecyType.visionOfProsperity, now),
          Duration(minutes: 30));
    });

    test('Cooldown expires after duration', () {
      final now = DateTime.now();
      var state = ProphecyState.initial().activate(
        ProphecyType.visionOfProsperity,
        now,
      );

      expect(state.isOnCooldown(ProphecyType.visionOfProsperity), true);

      final later = now.add(Duration(minutes: 31));
      expect(state.isOnCooldown(ProphecyType.visionOfProsperity, later), false);
    });
  });
}
