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

  /// Phase 5 Achievements - Athena Achievements (3)

  static const seekerOfWisdom = Achievement(
    id: 'seeker_of_wisdom',
    name: 'Seeker of Wisdom',
    description: 'Begin your journey into divine knowledge',
    category: AchievementCategory.gods,
    reward: '+0.5 Wisdom/sec permanent bonus',
  );

  static const scholarlyDevotion = Achievement(
    id: 'scholarly_devotion',
    name: 'Scholarly Devotion',
    description: 'Dedicate yourself to the pursuit of wisdom',
    category: AchievementCategory.buildings,
    reward: 'Athena buildings produce +5% more Wisdom',
  );

  static const wisdomHoarder = Achievement(
    id: 'wisdom_hoarder',
    name: 'Wisdom Hoarder',
    description: 'Amass a vast treasury of knowledge',
    category: AchievementCategory.general,
    reward: '+2% all resource production',
  );

  /// Phase 5 Achievements - Apollo Achievements (3)

  static const godOfLight = Achievement(
    id: 'god_of_light',
    name: 'God of Light',
    description: 'Bask in Apollo\'s radiant enlightenment',
    category: AchievementCategory.gods,
    reward: '+1 Wisdom/sec permanent bonus',
  );

  static const propheticDevotee = Achievement(
    id: 'prophetic_devotee',
    name: 'Prophetic Devotee',
    description: 'Seek Apollo\'s visions with fervor',
    category: AchievementCategory.general,
    reward: 'All prophecy cooldowns reduced by 5%',
  );

  static const oraclesFavorite = Achievement(
    id: 'oracles_favorite',
    name: 'Oracle\'s Favorite',
    description: 'Master the art of divine foresight',
    category: AchievementCategory.general,
    reward: 'Apollo\'s Grand Vision cooldown reduced by 30 minutes',
    isHidden: true,
  );

  /// Phase 5 Achievements - Research & Knowledge Achievements (2)

  static const philosopherKing = Achievement(
    id: 'philosopher_king',
    name: 'Philosopher King',
    description: 'Achieve the pinnacle of intellectual pursuit',
    category: AchievementCategory.research,
    reward: 'All research costs reduced by 5%',
  );

  static const renaissanceDeity = Achievement(
    id: 'renaissance_deity',
    name: 'Renaissance Deity',
    description: 'Balance wisdom and prophecy in perfect harmony',
    category: AchievementCategory.buildings,
    reward: '+10% Wisdom production from all sources',
  );

  /// Phase 5 Achievements - Conquest Achievement (1)

  static const masterOfKnowledge = Achievement(
    id: 'master_of_knowledge',
    name: 'Master of Knowledge',
    description: 'Claim dominion over the centers of learning',
    category: AchievementCategory.conquest,
    reward: 'All conquest costs reduced by 10%',
  );

  /// Phase 5 Achievements - Challenge Achievement (1)

  static const prescientStrategist = Achievement(
    id: 'prescient_strategist',
    name: 'Prescient Strategist',
    description: 'Progress through pure wisdom, untainted by material conversion',
    category: AchievementCategory.general,
    reward: '+25% offline cat production',
    isHidden: true,
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
    seekerOfWisdom,
    scholarlyDevotion,
    wisdomHoarder,
    godOfLight,
    propheticDevotee,
    oraclesFavorite,
    philosopherKing,
    renaissanceDeity,
    masterOfKnowledge,
    prescientStrategist,
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
