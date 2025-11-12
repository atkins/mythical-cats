/// Achievement categories
enum AchievementCategory {
  cats,
  buildings,
  gods,
  general,
  research,
  conquest;

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
      case AchievementCategory.research:
        return 'Research';
      case AchievementCategory.conquest:
        return 'Conquest';
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
  final String reward; // Descriptive text of reward (e.g., "+0.5 Wisdom/sec permanent bonus")
  final bool isHidden; // Hidden achievements show "???" until unlocked

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.bonusPercent = 0.5,
    this.reward = '',
    this.isHidden = false,
  });
}
