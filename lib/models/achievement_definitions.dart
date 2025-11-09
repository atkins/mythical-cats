import 'package:mythical_cats/models/achievement.dart';

/// All achievements in the game
class AchievementDefinitions {
  /// Cat collection achievements
  static const first100Cats = Achievement(
    id: 'cats_100',
    name: 'Feline Friend',
    description: 'Collect 100 cats',
    category: AchievementCategory.cats,
  );

  static const first1kCats = Achievement(
    id: 'cats_1k',
    name: 'Cat Collector',
    description: 'Collect 1,000 cats',
    category: AchievementCategory.cats,
  );

  static const first10kCats = Achievement(
    id: 'cats_10k',
    name: 'Cat Hoarder',
    description: 'Collect 10,000 cats',
    category: AchievementCategory.cats,
  );

  /// Building achievements
  static const first10Buildings = Achievement(
    id: 'buildings_10',
    name: 'Master Builder',
    description: 'Own 10 total buildings',
    category: AchievementCategory.buildings,
  );

  static const first50Buildings = Achievement(
    id: 'buildings_50',
    name: 'Architect',
    description: 'Own 50 total buildings',
    category: AchievementCategory.buildings,
  );

  /// God achievements
  static const unlockHestia = Achievement(
    id: 'god_hestia',
    name: 'Hearth Keeper',
    description: 'Unlock Hestia',
    category: AchievementCategory.gods,
  );

  static const unlockDemeter = Achievement(
    id: 'god_demeter',
    name: 'Harvest Master',
    description: 'Unlock Demeter',
    category: AchievementCategory.gods,
  );

  static const unlockDionysus = Achievement(
    id: 'god_dionysus',
    name: 'Party Starter',
    description: 'Unlock Dionysus',
    category: AchievementCategory.gods,
  );

  /// All achievements list
  static List<Achievement> get all => [
    first100Cats,
    first1kCats,
    first10kCats,
    first10Buildings,
    first50Buildings,
    unlockHestia,
    unlockDemeter,
    unlockDionysus,
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
