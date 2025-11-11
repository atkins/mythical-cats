/// Types of resources in the game
enum ResourceType {
  cats,
  offerings,
  prayers,
  divineEssence,
  ambrosia,
  ichor,
  celestialFragments,
  conquestPoints,
  wisdom;

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
      case ResourceType.wisdom:
        return 'Wisdom';
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
      case ResourceType.wisdom:
        return '🦉';
    }
  }

  /// Description of the resource
  String get description {
    switch (this) {
      case ResourceType.cats:
        return 'Your primary currency';
      case ResourceType.offerings:
        return 'Basic offerings to the gods';
      case ResourceType.prayers:
        return 'Spiritual devotion';
      case ResourceType.divineEssence:
        return 'Refined spiritual energy';
      case ResourceType.ambrosia:
        return 'Food of the gods';
      case ResourceType.ichor:
        return 'Blood of the gods';
      case ResourceType.celestialFragments:
        return 'Fragments of celestial power';
      case ResourceType.conquestPoints:
        return 'Points earned through conquest';
      case ResourceType.wisdom:
        return 'Divine knowledge and insight';
    }
  }

  /// Resource tier (1 = basic, 2 = advanced)
  int get tier {
    switch (this) {
      case ResourceType.cats:
      case ResourceType.offerings:
      case ResourceType.prayers:
        return 1;
      case ResourceType.divineEssence:
      case ResourceType.ambrosia:
      case ResourceType.ichor:
      case ResourceType.celestialFragments:
      case ResourceType.conquestPoints:
      case ResourceType.wisdom:
        return 2;
    }
  }
}
