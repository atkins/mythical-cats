import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/services/reincarnation_calculator.dart';

void main() {
  group('ReincarnationCalculator', () {
    group('calculatePrimordialEssence', () {
      test('returns 0 for 0 cats', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(0);
        expect(pe, 0);
      });

      test('returns 0 for cats below threshold', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(999);
        expect(pe, 0);
      });

      test('returns 1 PE for 1000 cats', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(1000);
        expect(pe, 1);
      });

      test('returns 10 PE for 100,000 cats', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(100000);
        expect(pe, 10);
      });

      test('returns 100 PE for 10,000,000 cats', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(10000000);
        expect(pe, 100);
      });

      test('handles decimal cats correctly', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(2500.5);
        expect(pe, 1); // floor(sqrt(2500.5 / 1000))
      });

      test('handles very large numbers', () {
        final pe = ReincarnationCalculator.calculatePrimordialEssence(1000000000);
        expect(pe, 1000); // floor(sqrt(1,000,000,000 / 1000))
      });
    });

    group('isReincarnationUnlocked', () {
      test('returns false below threshold', () {
        final unlocked = ReincarnationCalculator.isReincarnationUnlocked(999);
        expect(unlocked, false);
      });

      test('returns true at threshold', () {
        final unlocked = ReincarnationCalculator.isReincarnationUnlocked(1000);
        expect(unlocked, true);
      });

      test('returns true above threshold', () {
        final unlocked = ReincarnationCalculator.isReincarnationUnlocked(5000);
        expect(unlocked, true);
      });
    });
  });
}
