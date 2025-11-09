/// Achievement categories
enum AchievementCategory {
  cats,
  buildings,
  gods,
  general;

  String get displayName {
    switch (this) {
      case AchievementCategory.cats:
        return 'Cat Collection';
      case AchievementCategory.buildings:
        return 'Buildings';
      case AchievementCategory.gods:
        return 'Divine Favor';
      case AchievementCategory.general:
        return 'General';
    }
  }
}

/// Individual achievement
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final double bonusPercent; // Permanent bonus (0.5 = 0.5% increase)

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.bonusPercent = 0.5,
  });

  /// Check if achievement is unlocked based on game state
  bool isUnlocked(
    double totalCats,
    Map<String, int> buildingCounts,
    Set<String> unlockedGods,
  ) {
    // Override in subclasses or use achievement definitions
    return false;
  }
}
