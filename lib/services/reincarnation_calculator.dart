import 'dart:math';

/// Helper class for Primordial Essence calculations.
///
/// This class provides static methods for calculating Primordial Essence (PE)
/// rewards and determining if reincarnation is unlocked.
class ReincarnationCalculator {
  // Minimum cats required to unlock reincarnation
  static const double _reincarnationThreshold = 1000.0;

  /// Calculates the amount of Primordial Essence earned from a reincarnation.
  ///
  /// Formula: PE = floor(sqrt(totalCats / 1000))
  ///
  /// Returns 0 if totalCats is below the reincarnation threshold (1000 cats).
  ///
  /// [totalCats] - The total number of cats earned in the current run
  static int calculatePrimordialEssence(double totalCats) {
    // Return 0 if below threshold or negative
    if (totalCats < _reincarnationThreshold) {
      return 0;
    }

    // Calculate PE using the formula: floor(sqrt(totalCats / 1000))
    final double peValue = sqrt(totalCats / 1000.0);
    return peValue.floor();
  }

  /// Determines if reincarnation is unlocked based on total cats earned.
  ///
  /// Reincarnation unlocks at 1000 total cats.
  ///
  /// [totalCats] - The total number of cats earned in the current run
  static bool isReincarnationUnlocked(double totalCats) {
    return totalCats >= _reincarnationThreshold;
  }
}
