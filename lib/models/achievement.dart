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
  final bool Function(dynamic gameState)? _canUnlock;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.bonusPercent = 0.5,
    bool Function(dynamic gameState)? canUnlock,
  }) : _canUnlock = canUnlock;

  /// Check if this achievement can be unlocked based on game state
  bool canUnlock(dynamic gameState) {
    if (_canUnlock == null) {
      return false; // Simple achievements without unlock logic default to false
    }
    return _canUnlock(gameState);
  }
}
