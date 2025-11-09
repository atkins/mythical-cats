import 'package:mythical_cats/models/resource_type.dart';

/// Type of random event
enum RandomEventType {
  bonus,
  multiplier,
  discovery;

  String get displayName {
    switch (this) {
      case RandomEventType.bonus:
        return 'Bonus Resources';
      case RandomEventType.multiplier:
        return 'Production Boost';
      case RandomEventType.discovery:
        return 'Discovery';
    }
  }
}

/// Random event that can occur during gameplay
class RandomEvent {
  final String id;
  final String title;
  final String description;
  final RandomEventType type;
  final Map<ResourceType, double> bonusResources;
  final double multiplier; // For production multipliers
  final Duration? duration; // For timed effects

  const RandomEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.bonusResources = const {},
    this.multiplier = 1.0,
    this.duration,
  });
}
