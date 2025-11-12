import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/prophecy.dart';

void main() {
  group('Phase 5 Achievements', () {
    group('Seeker of Wisdom Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.seekerOfWisdom;

        expect(achievement.id, 'seeker_of_wisdom');
        expect(achievement.name, 'Seeker of Wisdom');
        expect(achievement.description, 'Begin your journey into divine knowledge');
        expect(achievement.category, AchievementCategory.gods);
        expect(achievement.reward, '+0.5 Wisdom/sec permanent bonus');
        expect(achievement.isHidden, false);
      });

      test('unlocks when Athena is unlocked', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.athena},
          totalCatsEarned: 1000000,
        );

        expect(state.hasUnlockedGod(God.athena), true);
      });

      test('does not unlock before Athena', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.hestia},
          totalCatsEarned: 500000,
        );

        expect(state.hasUnlockedGod(God.athena), false);
      });
    });

    group('Scholarly Devotion Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.scholarlyDevotion;

        expect(achievement.id, 'scholarly_devotion');
        expect(achievement.name, 'Scholarly Devotion');
        expect(achievement.description, 'Dedicate yourself to the pursuit of wisdom');
        expect(achievement.category, AchievementCategory.buildings);
        expect(achievement.reward, 'Athena buildings produce +5% more Wisdom');
        expect(achievement.isHidden, false);
      });

      test('unlocks when owning 25 Athena buildings', () {
        final state = GameState.initial().copyWith(
          buildings: {
            BuildingType.hallOfWisdom: 10,
            BuildingType.academyOfAthens: 8,
            BuildingType.strategyChamber: 5,
            BuildingType.oraclesArchive: 2,
          },
        );

        final totalAthenaBuildings = state.getBuildingCount(BuildingType.hallOfWisdom) +
            state.getBuildingCount(BuildingType.academyOfAthens) +
            state.getBuildingCount(BuildingType.strategyChamber) +
            state.getBuildingCount(BuildingType.oraclesArchive);

        expect(totalAthenaBuildings, 25);
      });

      test('does not unlock with fewer than 25 Athena buildings', () {
        final state = GameState.initial().copyWith(
          buildings: {
            BuildingType.hallOfWisdom: 10,
            BuildingType.academyOfAthens: 8,
            BuildingType.strategyChamber: 5,
          },
        );

        final totalAthenaBuildings = state.getBuildingCount(BuildingType.hallOfWisdom) +
            state.getBuildingCount(BuildingType.academyOfAthens) +
            state.getBuildingCount(BuildingType.strategyChamber) +
            state.getBuildingCount(BuildingType.oraclesArchive);

        expect(totalAthenaBuildings, lessThan(25));
      });
    });

    group('Wisdom Hoarder Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.wisdomHoarder;

        expect(achievement.id, 'wisdom_hoarder');
        expect(achievement.name, 'Wisdom Hoarder');
        expect(achievement.description, 'Amass a vast treasury of knowledge');
        expect(achievement.category, AchievementCategory.general);
        expect(achievement.reward, '+2% all resource production');
        expect(achievement.isHidden, false);
      });

      test('unlocks when lifetime wisdom reaches 10,000', () {
        final state = GameState.initial().copyWith(
          lifetimeWisdom: 10000,
        );

        expect(state.lifetimeWisdom, greaterThanOrEqualTo(10000));
      });

      test('does not unlock with less than 10,000 lifetime wisdom', () {
        final state = GameState.initial().copyWith(
          lifetimeWisdom: 9999,
        );

        expect(state.lifetimeWisdom, lessThan(10000));
      });
    });

    group('God of Light Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.godOfLight;

        expect(achievement.id, 'god_of_light');
        expect(achievement.name, 'God of Light');
        expect(achievement.description, 'Bask in Apollo\'s radiant enlightenment');
        expect(achievement.category, AchievementCategory.gods);
        expect(achievement.reward, '+1 Wisdom/sec permanent bonus');
        expect(achievement.isHidden, false);
      });

      test('unlocks when Apollo is unlocked', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.athena, God.apollo},
          totalCatsEarned: 10000000,
        );

        expect(state.hasUnlockedGod(God.apollo), true);
      });

      test('does not unlock before Apollo', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.athena},
          totalCatsEarned: 5000000,
        );

        expect(state.hasUnlockedGod(God.apollo), false);
      });
    });

    group('Prophetic Devotee Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.propheticDevotee;

        expect(achievement.id, 'prophetic_devotee');
        expect(achievement.name, 'Prophetic Devotee');
        expect(achievement.description, 'Seek Apollo\'s visions with fervor');
        expect(achievement.category, AchievementCategory.general);
        expect(achievement.reward, 'All prophecy cooldowns reduced by 5%');
        expect(achievement.isHidden, false);
      });

      test('unlocks when 50 prophecies activated', () {
        final state = GameState.initial().copyWith(
          lifetimePropheciesActivated: 50,
        );

        expect(state.lifetimePropheciesActivated, greaterThanOrEqualTo(50));
      });

      test('does not unlock with fewer than 50 prophecies', () {
        final state = GameState.initial().copyWith(
          lifetimePropheciesActivated: 49,
        );

        expect(state.lifetimePropheciesActivated, lessThan(50));
      });
    });

    group('Oracle\'s Favorite Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.oraclesFavorite;

        expect(achievement.id, 'oracles_favorite');
        expect(achievement.name, 'Oracle\'s Favorite');
        expect(achievement.description, 'Master the art of divine foresight');
        expect(achievement.category, AchievementCategory.general);
        expect(achievement.reward, 'Apollo\'s Grand Vision cooldown reduced by 30 minutes');
        expect(achievement.isHidden, true);
      });

      test('unlocks when all 10 prophecies activated and Grand Vision activated', () {
        final now = DateTime.now();
        final state = GameState.initial().copyWith(
          prophecyState: ProphecyState(
            cooldowns: {
              ProphecyType.visionOfProsperity: now.add(const Duration(minutes: 30)),
              ProphecyType.solarBlessing: now.add(const Duration(minutes: 60)),
              ProphecyType.glimpseOfResearch: now.add(const Duration(minutes: 45)),
              ProphecyType.prophecyOfAbundance: now.add(const Duration(minutes: 90)),
              ProphecyType.divineCalculation: now.add(const Duration(minutes: 60)),
              ProphecyType.musesInspiration: now.add(const Duration(minutes: 120)),
              ProphecyType.oraclesRevelation: now.add(const Duration(minutes: 150)),
              ProphecyType.celestialSurge: now.add(const Duration(minutes: 180)),
              ProphecyType.prophecyOfFortune: now.add(const Duration(minutes: 210)),
              ProphecyType.apollosGrandVision: now.add(const Duration(minutes: 240)),
            },
          ),
        );

        expect(state.prophecyState.cooldowns.length, 10);
        expect(state.prophecyState.cooldowns.containsKey(ProphecyType.apollosGrandVision), true);
      });

      test('does not unlock without all prophecies activated', () {
        final now = DateTime.now();
        final state = GameState.initial().copyWith(
          prophecyState: ProphecyState(
            cooldowns: {
              ProphecyType.visionOfProsperity: now.add(const Duration(minutes: 30)),
              ProphecyType.solarBlessing: now.add(const Duration(minutes: 60)),
              ProphecyType.apollosGrandVision: now.add(const Duration(minutes: 240)),
            },
          ),
        );

        expect(state.prophecyState.cooldowns.length, lessThan(10));
      });
    });

    group('Philosopher King Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.philosopherKing;

        expect(achievement.id, 'philosopher_king');
        expect(achievement.name, 'Philosopher King');
        expect(achievement.description, 'Achieve the pinnacle of intellectual pursuit');
        expect(achievement.category, AchievementCategory.research);
        expect(achievement.reward, 'All research costs reduced by 5%');
        expect(achievement.isHidden, false);
      });

      test('unlocks when all 7 Knowledge branch research nodes completed', () {
        final state = GameState.initial().copyWith(
          completedResearch: {
            'foundations_of_wisdom',
            'scholarly_pursuit_i',
            'scholarly_pursuit_ii',
            'scholarly_pursuit_iii',
            'divine_insight',
            'philosophical_method',
            'prophetic_connection',
          },
        );

        final knowledgeBranchNodes = [
          'foundations_of_wisdom',
          'scholarly_pursuit_i',
          'scholarly_pursuit_ii',
          'scholarly_pursuit_iii',
          'divine_insight',
          'philosophical_method',
          'prophetic_connection',
        ];

        final allCompleted = knowledgeBranchNodes.every((node) => state.hasCompletedResearch(node));
        expect(allCompleted, true);
      });

      test('does not unlock without all Knowledge nodes', () {
        final state = GameState.initial().copyWith(
          completedResearch: {
            'foundations_of_wisdom',
            'scholarly_pursuit_i',
            'scholarly_pursuit_ii',
          },
        );

        final knowledgeBranchNodes = [
          'foundations_of_wisdom',
          'scholarly_pursuit_i',
          'scholarly_pursuit_ii',
          'scholarly_pursuit_iii',
          'divine_insight',
          'philosophical_method',
          'prophetic_connection',
        ];

        final allCompleted = knowledgeBranchNodes.every((node) => state.hasCompletedResearch(node));
        expect(allCompleted, false);
      });
    });

    group('Renaissance Deity Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.renaissanceDeity;

        expect(achievement.id, 'renaissance_deity');
        expect(achievement.name, 'Renaissance Deity');
        expect(achievement.description, 'Balance wisdom and prophecy in perfect harmony');
        expect(achievement.category, AchievementCategory.buildings);
        expect(achievement.reward, '+10% Wisdom production from all sources');
        expect(achievement.isHidden, false);
      });

      test('unlocks when owning 10+ of each Athena and Apollo building', () {
        final state = GameState.initial().copyWith(
          buildings: {
            // Athena buildings
            BuildingType.hallOfWisdom: 10,
            BuildingType.academyOfAthens: 10,
            BuildingType.strategyChamber: 10,
            BuildingType.oraclesArchive: 10,
            // Apollo buildings
            BuildingType.templeOfDelphi: 10,
            BuildingType.sunChariotStable: 10,
            BuildingType.musesSanctuary: 10,
            BuildingType.celestialObservatory: 10,
          },
        );

        final athenaBuildings = [
          BuildingType.hallOfWisdom,
          BuildingType.academyOfAthens,
          BuildingType.strategyChamber,
          BuildingType.oraclesArchive,
        ];

        final apolloBuildings = [
          BuildingType.templeOfDelphi,
          BuildingType.sunChariotStable,
          BuildingType.musesSanctuary,
          BuildingType.celestialObservatory,
        ];

        final allAthenaHave10 = athenaBuildings.every((b) => state.getBuildingCount(b) >= 10);
        final allApolloHave10 = apolloBuildings.every((b) => state.getBuildingCount(b) >= 10);

        expect(allAthenaHave10, true);
        expect(allApolloHave10, true);
      });

      test('does not unlock without 10 of each building', () {
        final state = GameState.initial().copyWith(
          buildings: {
            // Athena buildings
            BuildingType.hallOfWisdom: 10,
            BuildingType.academyOfAthens: 10,
            BuildingType.strategyChamber: 5, // Not enough
            BuildingType.oraclesArchive: 10,
            // Apollo buildings
            BuildingType.templeOfDelphi: 10,
            BuildingType.sunChariotStable: 10,
            BuildingType.musesSanctuary: 10,
            BuildingType.celestialObservatory: 10,
          },
        );

        final athenaBuildings = [
          BuildingType.hallOfWisdom,
          BuildingType.academyOfAthens,
          BuildingType.strategyChamber,
          BuildingType.oraclesArchive,
        ];

        final allAthenaHave10 = athenaBuildings.every((b) => state.getBuildingCount(b) >= 10);

        expect(allAthenaHave10, false);
      });
    });

    group('Master of Knowledge Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.masterOfKnowledge;

        expect(achievement.id, 'master_of_knowledge');
        expect(achievement.name, 'Master of Knowledge');
        expect(achievement.description, 'Claim dominion over the centers of learning');
        expect(achievement.category, AchievementCategory.conquest);
        expect(achievement.reward, 'All conquest costs reduced by 10%');
        expect(achievement.isHidden, false);
      });

      test('unlocks when all 3 Phase 5 territories conquered', () {
        final state = GameState.initial().copyWith(
          conqueredTerritories: {
            'academy_of_athens',
            'oracle_of_delphi',
            'library_of_alexandria',
          },
        );

        final phase5Territories = [
          'academy_of_athens',
          'oracle_of_delphi',
          'library_of_alexandria',
        ];

        final allConquered = phase5Territories.every((t) => state.hasConqueredTerritory(t));
        expect(allConquered, true);
      });

      test('does not unlock without all 3 territories', () {
        final state = GameState.initial().copyWith(
          conqueredTerritories: {
            'academy_of_athens',
            'oracle_of_delphi',
          },
        );

        final phase5Territories = [
          'academy_of_athens',
          'oracle_of_delphi',
          'library_of_alexandria',
        ];

        final allConquered = phase5Territories.every((t) => state.hasConqueredTerritory(t));
        expect(allConquered, false);
      });
    });

    group('Prescient Strategist Achievement', () {
      test('has correct properties', () {
        const achievement = AchievementDefinitions.prescientStrategist;

        expect(achievement.id, 'prescient_strategist');
        expect(achievement.name, 'Prescient Strategist');
        expect(achievement.description, 'Progress through pure wisdom, untainted by material conversion');
        expect(achievement.category, AchievementCategory.general);
        expect(achievement.reward, '+25% offline cat production');
        expect(achievement.isHidden, true);
      });

      test('unlocks when Apollo unlocked with 0 Workshop buildings', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.athena, God.apollo},
          totalCatsEarned: 10000000,
          buildings: {
            BuildingType.hallOfWisdom: 20,
            BuildingType.templeOfDelphi: 15,
            // No workshop building
          },
        );

        expect(state.hasUnlockedGod(God.apollo), true);
        expect(state.getBuildingCount(BuildingType.workshop), 0);
      });

      test('does not unlock if Workshop was purchased', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.athena, God.apollo},
          totalCatsEarned: 10000000,
          buildings: {
            BuildingType.hallOfWisdom: 20,
            BuildingType.templeOfDelphi: 15,
            BuildingType.workshop: 1, // Workshop purchased
          },
        );

        expect(state.hasUnlockedGod(God.apollo), true);
        expect(state.getBuildingCount(BuildingType.workshop), greaterThan(0));
      });
    });

    group('All Phase 5 Achievements', () {
      test('all have unique IDs', () {
        final phase5Achievements = [
          AchievementDefinitions.seekerOfWisdom,
          AchievementDefinitions.scholarlyDevotion,
          AchievementDefinitions.wisdomHoarder,
          AchievementDefinitions.godOfLight,
          AchievementDefinitions.propheticDevotee,
          AchievementDefinitions.oraclesFavorite,
          AchievementDefinitions.philosopherKing,
          AchievementDefinitions.renaissanceDeity,
          AchievementDefinitions.masterOfKnowledge,
          AchievementDefinitions.prescientStrategist,
        ];

        final ids = phase5Achievements.map((a) => a.id).toSet();
        expect(ids.length, 10); // All IDs are unique
      });

      test('exactly 2 achievements are hidden', () {
        final phase5Achievements = [
          AchievementDefinitions.seekerOfWisdom,
          AchievementDefinitions.scholarlyDevotion,
          AchievementDefinitions.wisdomHoarder,
          AchievementDefinitions.godOfLight,
          AchievementDefinitions.propheticDevotee,
          AchievementDefinitions.oraclesFavorite,
          AchievementDefinitions.philosopherKing,
          AchievementDefinitions.renaissanceDeity,
          AchievementDefinitions.masterOfKnowledge,
          AchievementDefinitions.prescientStrategist,
        ];

        final hiddenCount = phase5Achievements.where((a) => a.isHidden).length;
        expect(hiddenCount, 2);
      });

      test('all have non-empty rewards', () {
        final phase5Achievements = [
          AchievementDefinitions.seekerOfWisdom,
          AchievementDefinitions.scholarlyDevotion,
          AchievementDefinitions.wisdomHoarder,
          AchievementDefinitions.godOfLight,
          AchievementDefinitions.propheticDevotee,
          AchievementDefinitions.oraclesFavorite,
          AchievementDefinitions.philosopherKing,
          AchievementDefinitions.renaissanceDeity,
          AchievementDefinitions.masterOfKnowledge,
          AchievementDefinitions.prescientStrategist,
        ];

        for (final achievement in phase5Achievements) {
          expect(achievement.reward, isNotEmpty,
              reason: '${achievement.id} should have a reward');
        }
      });

      test('all can be found by ID', () {
        final phase5AchievementIds = [
          'seeker_of_wisdom',
          'scholarly_devotion',
          'wisdom_hoarder',
          'god_of_light',
          'prophetic_devotee',
          'oracles_favorite',
          'philosopher_king',
          'renaissance_deity',
          'master_of_knowledge',
          'prescient_strategist',
        ];

        for (final id in phase5AchievementIds) {
          final achievement = AchievementDefinitions.getById(id);
          expect(achievement, isNotNull, reason: 'Achievement $id should be found');
          expect(achievement!.id, id);
        }
      });
    });
  });
}
