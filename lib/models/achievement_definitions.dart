import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/building_type.dart';

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

  /// Phase 5 achievements (Wisdom & Prophecy)
  static final firstWisdom = Achievement(
    id: 'first_wisdom',
    name: 'First Wisdom',
    description: 'Accumulate your first Wisdom point',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.getResource(ResourceType.wisdom) >= 1;
    },
  );

  static final scholar = Achievement(
    id: 'scholar',
    name: 'Scholar',
    description: 'Reach 100 Wisdom',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.getResource(ResourceType.wisdom) >= 100;
    },
  );

  static final philosopherKing = Achievement(
    id: 'philosopher_king',
    name: 'Philosopher King',
    description: 'Reach 1000 Wisdom',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.getResource(ResourceType.wisdom) >= 1000;
    },
  );

  static final goddessOfWisdom = Achievement(
    id: 'goddess_of_wisdom',
    name: 'Goddess of Wisdom',
    description: 'Unlock Athena',
    category: AchievementCategory.gods,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.hasUnlockedGod(God.athena);
    },
  );

  static final godOfProphecy = Achievement(
    id: 'god_of_prophecy',
    name: 'God of Prophecy',
    description: 'Unlock Apollo',
    category: AchievementCategory.gods,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.hasUnlockedGod(God.apollo);
    },
  );

  static final firstProphecy = Achievement(
    id: 'first_prophecy',
    name: 'First Prophecy',
    description: 'Activate your first prophecy',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.prophecyState.cooldowns.isNotEmpty;
    },
  );

  static final seer = Achievement(
    id: 'seer',
    name: 'Seer',
    description: 'Activate 10 different prophecies',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.prophecyState.cooldowns.length >= 10;
    },
  );

  static final masterOfKnowledge = Achievement(
    id: 'master_of_knowledge',
    name: 'Master of Knowledge',
    description: 'Complete all Knowledge branch research',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      // All Knowledge branch research IDs
      const knowledgeBranch = {
        'foundations_of_wisdom',
        'scholarly_pursuit_i',
        'scholarly_pursuit_ii',
        'scholarly_pursuit_iii',
        'divine_insight',
        'philosophical_method',
        'prophetic_connection',
      };
      return knowledgeBranch.every((researchId) =>
        gameState.hasCompletedResearch(researchId));
    },
  );

  static final divineLibrary = Achievement(
    id: 'divine_library',
    name: 'Divine Library',
    description: 'Conquer Library of Alexandria',
    category: AchievementCategory.general,
    canUnlock: (state) {
      final gameState = state as GameState;
      return gameState.hasConqueredTerritory('library_of_alexandria');
    },
  );

  static final academicExcellence = Achievement(
    id: 'academic_excellence',
    name: 'Academic Excellence',
    description: 'Purchase all Athena buildings (at least 1 of each)',
    category: AchievementCategory.buildings,
    canUnlock: (state) {
      final gameState = state as GameState;
      // All Athena buildings
      const athenaBuildings = [
        BuildingType.hallOfWisdom,
        BuildingType.academyOfAthens,
        BuildingType.strategyChamber,
        BuildingType.oraclesArchive,
      ];
      return athenaBuildings.every((building) =>
        gameState.getBuildingCount(building) >= 1);
    },
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
    firstWisdom,
    scholar,
    philosopherKing,
    goddessOfWisdom,
    godOfProphecy,
    firstProphecy,
    seer,
    masterOfKnowledge,
    divineLibrary,
    academicExcellence,
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
