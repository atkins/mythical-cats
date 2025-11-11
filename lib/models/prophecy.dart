/// Prophecy effect types
enum ProphecyEffectType {
  informational,
  timedBoost,
  instantBenefit,
  hybrid,
}

/// The 10 prophecies
enum ProphecyType {
  // Tier 1
  visionOfProsperity,
  solarBlessing,
  glimpseOfResearch,

  // Tier 2
  prophecyOfAbundance,
  divineCalculation,
  musesInspiration,

  // Tier 3
  oraclesRevelation,
  celestialSurge,
  prophecyOfFortune,
  apollosGrandVision,
}

extension ProphecyTypeExtension on ProphecyType {
  String get displayName {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 'Vision of Prosperity';
      case ProphecyType.solarBlessing:
        return 'Solar Blessing';
      case ProphecyType.glimpseOfResearch:
        return 'Glimpse of Research';
      case ProphecyType.prophecyOfAbundance:
        return 'Prophecy of Abundance';
      case ProphecyType.divineCalculation:
        return 'Divine Calculation';
      case ProphecyType.musesInspiration:
        return 'Muse\'s Inspiration';
      case ProphecyType.oraclesRevelation:
        return 'Oracle\'s Revelation';
      case ProphecyType.celestialSurge:
        return 'Celestial Surge';
      case ProphecyType.prophecyOfFortune:
        return 'Prophecy of Fortune';
      case ProphecyType.apollosGrandVision:
        return 'Apollo\'s Grand Vision';
    }
  }

  String get description {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 'Shows next 3 building unlock thresholds and their production rates';
      case ProphecyType.solarBlessing:
        return '+50% cat production for 15 minutes';
      case ProphecyType.glimpseOfResearch:
        return 'Reveals all available research nodes and their prerequisites';
      case ProphecyType.prophecyOfAbundance:
        return '+100% all resource production for 30 minutes';
      case ProphecyType.divineCalculation:
        return 'Shows exact time to reach next god unlock at current production rate';
      case ProphecyType.musesInspiration:
        return 'Next 5 buildings purchased cost 20% less';
      case ProphecyType.oraclesRevelation:
        return 'Reveals optimal building purchase order for next 10 minutes of progression';
      case ProphecyType.celestialSurge:
        return '+200% cat production for 45 minutes';
      case ProphecyType.prophecyOfFortune:
        return 'Gain instant cats equal to 30 minutes of current production';
      case ProphecyType.apollosGrandVision:
        return 'Shows complete path to next reincarnation threshold + grants +150% all production for 1 hour';
    }
  }

  double get wisdomCost {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 50;
      case ProphecyType.solarBlessing:
        return 100;
      case ProphecyType.glimpseOfResearch:
        return 75;
      case ProphecyType.prophecyOfAbundance:
        return 250;
      case ProphecyType.divineCalculation:
        return 200;
      case ProphecyType.musesInspiration:
        return 300;
      case ProphecyType.oraclesRevelation:
        return 500;
      case ProphecyType.celestialSurge:
        return 750;
      case ProphecyType.prophecyOfFortune:
        return 1000;
      case ProphecyType.apollosGrandVision:
        return 2000;
    }
  }

  int get cooldownMinutes {
    switch (this) {
      case ProphecyType.visionOfProsperity:
        return 30;
      case ProphecyType.solarBlessing:
        return 60;
      case ProphecyType.glimpseOfResearch:
        return 45;
      case ProphecyType.prophecyOfAbundance:
        return 90;
      case ProphecyType.divineCalculation:
        return 60;
      case ProphecyType.musesInspiration:
        return 120;
      case ProphecyType.oraclesRevelation:
        return 150;
      case ProphecyType.celestialSurge:
        return 180;
      case ProphecyType.prophecyOfFortune:
        return 210;
      case ProphecyType.apollosGrandVision:
        return 240;
    }
  }

  int get tier {
    switch (this) {
      case ProphecyType.visionOfProsperity:
      case ProphecyType.solarBlessing:
      case ProphecyType.glimpseOfResearch:
        return 1;
      case ProphecyType.prophecyOfAbundance:
      case ProphecyType.divineCalculation:
      case ProphecyType.musesInspiration:
        return 2;
      case ProphecyType.oraclesRevelation:
      case ProphecyType.celestialSurge:
      case ProphecyType.prophecyOfFortune:
      case ProphecyType.apollosGrandVision:
        return 3;
    }
  }

  ProphecyEffectType get effectType {
    switch (this) {
      case ProphecyType.visionOfProsperity:
      case ProphecyType.glimpseOfResearch:
      case ProphecyType.divineCalculation:
      case ProphecyType.oraclesRevelation:
        return ProphecyEffectType.informational;
      case ProphecyType.solarBlessing:
      case ProphecyType.prophecyOfAbundance:
      case ProphecyType.celestialSurge:
        return ProphecyEffectType.timedBoost;
      case ProphecyType.prophecyOfFortune:
        return ProphecyEffectType.instantBenefit;
      case ProphecyType.musesInspiration:
      case ProphecyType.apollosGrandVision:
        return ProphecyEffectType.hybrid;
    }
  }

  int? get durationMinutes {
    switch (this) {
      case ProphecyType.solarBlessing:
        return 15;
      case ProphecyType.prophecyOfAbundance:
        return 30;
      case ProphecyType.celestialSurge:
        return 45;
      case ProphecyType.musesInspiration:
        return 60; // or 5 purchases
      case ProphecyType.apollosGrandVision:
        return 60;
      default:
        return null; // No duration for informational/instant
    }
  }

  double? get productionMultiplier {
    switch (this) {
      case ProphecyType.solarBlessing:
        return 1.5; // +50%
      case ProphecyType.prophecyOfAbundance:
        return 2.0; // +100%
      case ProphecyType.celestialSurge:
        return 3.0; // +200%
      case ProphecyType.apollosGrandVision:
        return 2.5; // +150%
      default:
        return null;
    }
  }
}

/// Prophecy activation state
class ProphecyState {
  final Map<ProphecyType, DateTime> cooldowns;
  final ProphecyType? activeTimedBoost;
  final DateTime? activeTimedBoostExpiry;

  const ProphecyState({
    required this.cooldowns,
    this.activeTimedBoost,
    this.activeTimedBoostExpiry,
  });

  factory ProphecyState.initial() {
    return const ProphecyState(cooldowns: {});
  }

  bool isOnCooldown(ProphecyType prophecy, [DateTime? now]) {
    final checkTime = now ?? DateTime.now();
    final cooldownEnd = cooldowns[prophecy];
    if (cooldownEnd == null) return false;
    return checkTime.isBefore(cooldownEnd);
  }

  Duration getCooldownRemaining(ProphecyType prophecy, [DateTime? now]) {
    final checkTime = now ?? DateTime.now();
    final cooldownEnd = cooldowns[prophecy];
    if (cooldownEnd == null) return Duration.zero;
    final remaining = cooldownEnd.difference(checkTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  ProphecyState activate(ProphecyType prophecy, DateTime now) {
    final cooldownEnd = now.add(Duration(minutes: prophecy.cooldownMinutes));
    final updatedCooldowns = Map<ProphecyType, DateTime>.from(cooldowns);
    updatedCooldowns[prophecy] = cooldownEnd;

    // If it's a timed boost, set as active
    if (prophecy.effectType == ProphecyEffectType.timedBoost ||
        prophecy.effectType == ProphecyEffectType.hybrid) {
      final duration = prophecy.durationMinutes;
      if (duration != null) {
        return ProphecyState(
          cooldowns: updatedCooldowns,
          activeTimedBoost: prophecy,
          activeTimedBoostExpiry: now.add(Duration(minutes: duration)),
        );
      }
    }

    return ProphecyState(
      cooldowns: updatedCooldowns,
      activeTimedBoost: activeTimedBoost,
      activeTimedBoostExpiry: activeTimedBoostExpiry,
    );
  }

  ProphecyState copyWith({
    Map<ProphecyType, DateTime>? cooldowns,
    ProphecyType? activeTimedBoost,
    DateTime? activeTimedBoostExpiry,
  }) {
    return ProphecyState(
      cooldowns: cooldowns ?? this.cooldowns,
      activeTimedBoost: activeTimedBoost ?? this.activeTimedBoost,
      activeTimedBoostExpiry: activeTimedBoostExpiry ?? this.activeTimedBoostExpiry,
    );
  }
}
