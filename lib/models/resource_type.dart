/// Types of resources in the game
enum ResourceType {
  cats,
  offerings,
  prayers,
  divineEssence,
  ambrosia,
  ichor,
  celestialFragments,
  conquestPoints;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ResourceType.cats:
        return 'Cats';
      case ResourceType.offerings:
        return 'Offerings';
      case ResourceType.prayers:
        return 'Prayers';
      case ResourceType.divineEssence:
        return 'Divine Essence';
      case ResourceType.ambrosia:
        return 'Ambrosia';
      case ResourceType.ichor:
        return 'Ichor';
      case ResourceType.celestialFragments:
        return 'Celestial Fragments';
      case ResourceType.conquestPoints:
        return 'Conquest Points';
    }
  }

  /// Icon for UI (placeholder, will be replaced with actual icons later)
  String get icon {
    switch (this) {
      case ResourceType.cats:
        return '🐱';
      case ResourceType.offerings:
        return '🎁';
      case ResourceType.prayers:
        return '🙏';
      case ResourceType.divineEssence:
        return '✨';
      case ResourceType.ambrosia:
        return '🍯';
      case ResourceType.ichor:
        return '💉';
      case ResourceType.celestialFragments:
        return '💎';
      case ResourceType.conquestPoints:
        return '⚔️';
    }
  }
}
