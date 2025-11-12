import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/prophecy.dart';

void main() {
  group('AchievementDefinitions - Phase 5 Achievements', () {
    group('First Wisdom Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.firstWisdom;
        expect(achievement.id, 'first_wisdom');
        expect(achievement.name, 'First Wisdom');
        expect(achievement.description, 'Accumulate your first Wisdom point');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when wisdom >= 1', () {
        final state = GameState.initial().copyWith(
          resources: {ResourceType.wisdom: 1.0},
        );
        expect(AchievementDefinitions.firstWisdom.canUnlock(state), true);
      });

      test('does not unlock when wisdom < 1', () {
        final state = GameState.initial().copyWith(
          resources: {ResourceType.wisdom: 0.5},
        );
        expect(AchievementDefinitions.firstWisdom.canUnlock(state), false);
      });
    });

    group('Scholar Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.scholar;
        expect(achievement.id, 'scholar');
        expect(achievement.name, 'Scholar');
        expect(achievement.description, 'Reach 100 Wisdom');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when wisdom >= 100', () {
        final state = GameState.initial().copyWith(
          resources: {ResourceType.wisdom: 100.0},
        );
        expect(AchievementDefinitions.scholar.canUnlock(state), true);
      });

      test('does not unlock when wisdom < 100', () {
        final state = GameState.initial().copyWith(
          resources: {ResourceType.wisdom: 99.0},
        );
        expect(AchievementDefinitions.scholar.canUnlock(state), false);
      });
    });

    group('Philosopher King Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.philosopherKing;
        expect(achievement.id, 'philosopher_king');
        expect(achievement.name, 'Philosopher King');
        expect(achievement.description, 'Reach 1000 Wisdom');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when wisdom >= 1000', () {
        final state = GameState.initial().copyWith(
          resources: {ResourceType.wisdom: 1000.0},
        );
        expect(AchievementDefinitions.philosopherKing.canUnlock(state), true);
      });
    });

    group('Goddess of Wisdom Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.goddessOfWisdom;
        expect(achievement.id, 'goddess_of_wisdom');
        expect(achievement.name, 'Goddess of Wisdom');
        expect(achievement.description, 'Unlock Athena');
        expect(achievement.category, AchievementCategory.gods);
      });

      test('unlocks when Athena is unlocked', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.athena},
        );
        expect(AchievementDefinitions.goddessOfWisdom.canUnlock(state), true);
      });

      test('does not unlock when Athena is not unlocked', () {
        final state = GameState.initial();
        expect(AchievementDefinitions.goddessOfWisdom.canUnlock(state), false);
      });
    });

    group('God of Prophecy Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.godOfProphecy;
        expect(achievement.id, 'god_of_prophecy');
        expect(achievement.name, 'God of Prophecy');
        expect(achievement.description, 'Unlock Apollo');
        expect(achievement.category, AchievementCategory.gods);
      });

      test('unlocks when Apollo is unlocked', () {
        final state = GameState.initial().copyWith(
          unlockedGods: {God.hermes, God.apollo},
        );
        expect(AchievementDefinitions.godOfProphecy.canUnlock(state), true);
      });
    });

    group('First Prophecy Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.firstProphecy;
        expect(achievement.id, 'first_prophecy');
        expect(achievement.name, 'First Prophecy');
        expect(achievement.description, 'Activate your first prophecy');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when any prophecy has been activated', () {
        final now = DateTime.now();
        final state = GameState.initial().copyWith(
          prophecyState: ProphecyState(
            cooldowns: {
              ProphecyType.visionOfProsperity: now.add(const Duration(minutes: 30)),
            },
          ),
        );
        expect(AchievementDefinitions.firstProphecy.canUnlock(state), true);
      });

      test('does not unlock when no prophecies activated', () {
        final state = GameState.initial();
        expect(AchievementDefinitions.firstProphecy.canUnlock(state), false);
      });
    });

    group('Seer Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.seer;
        expect(achievement.id, 'seer');
        expect(achievement.name, 'Seer');
        expect(achievement.description, 'Activate 10 different prophecies');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when 10 different prophecies have been activated', () {
        final now = DateTime.now();
        final state = GameState.initial().copyWith(
          prophecyState: ProphecyState(
            cooldowns: {
              ProphecyType.visionOfProsperity: now,
              ProphecyType.solarBlessing: now,
              ProphecyType.glimpseOfResearch: now,
              ProphecyType.prophecyOfAbundance: now,
              ProphecyType.divineCalculation: now,
              ProphecyType.musesInspiration: now,
              ProphecyType.oraclesRevelation: now,
              ProphecyType.celestialSurge: now,
              ProphecyType.prophecyOfFortune: now,
              ProphecyType.apollosGrandVision: now,
            },
          ),
        );
        expect(AchievementDefinitions.seer.canUnlock(state), true);
      });

      test('does not unlock when fewer than 10 prophecies activated', () {
        final now = DateTime.now();
        final state = GameState.initial().copyWith(
          prophecyState: ProphecyState(
            cooldowns: {
              ProphecyType.visionOfProsperity: now,
              ProphecyType.solarBlessing: now,
            },
          ),
        );
        expect(AchievementDefinitions.seer.canUnlock(state), false);
      });
    });

    group('Master of Knowledge Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.masterOfKnowledge;
        expect(achievement.id, 'master_of_knowledge');
        expect(achievement.name, 'Master of Knowledge');
        expect(achievement.description, 'Complete all Knowledge branch research');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when all Knowledge branch research is completed', () {
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
        expect(AchievementDefinitions.masterOfKnowledge.canUnlock(state), true);
      });

      test('does not unlock when Knowledge branch is incomplete', () {
        final state = GameState.initial().copyWith(
          completedResearch: {
            'foundations_of_wisdom',
            'scholarly_pursuit_i',
          },
        );
        expect(AchievementDefinitions.masterOfKnowledge.canUnlock(state), false);
      });
    });

    group('Divine Library Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.divineLibrary;
        expect(achievement.id, 'divine_library');
        expect(achievement.name, 'Divine Library');
        expect(achievement.description, 'Conquer Library of Alexandria');
        expect(achievement.category, AchievementCategory.general);
      });

      test('unlocks when Library of Alexandria is conquered', () {
        final state = GameState.initial().copyWith(
          conqueredTerritories: {'library_of_alexandria'},
        );
        expect(AchievementDefinitions.divineLibrary.canUnlock(state), true);
      });

      test('does not unlock when Library of Alexandria is not conquered', () {
        final state = GameState.initial();
        expect(AchievementDefinitions.divineLibrary.canUnlock(state), false);
      });
    });

    group('Academic Excellence Achievement', () {
      test('has correct properties', () {
        final achievement = AchievementDefinitions.academicExcellence;
        expect(achievement.id, 'academic_excellence');
        expect(achievement.name, 'Academic Excellence');
        expect(achievement.description, 'Purchase all Athena buildings (at least 1 of each)');
        expect(achievement.category, AchievementCategory.buildings);
      });

      test('unlocks when all Athena buildings are owned', () {
        final state = GameState.initial().copyWith(
          buildings: {
            BuildingType.hallOfWisdom: 1,
            BuildingType.academyOfAthens: 1,
            BuildingType.strategyChamber: 1,
            BuildingType.oraclesArchive: 1,
          },
        );
        expect(AchievementDefinitions.academicExcellence.canUnlock(state), true);
      });

      test('unlocks when all Athena buildings are owned with multiple of each', () {
        final state = GameState.initial().copyWith(
          buildings: {
            BuildingType.hallOfWisdom: 5,
            BuildingType.academyOfAthens: 3,
            BuildingType.strategyChamber: 2,
            BuildingType.oraclesArchive: 10,
          },
        );
        expect(AchievementDefinitions.academicExcellence.canUnlock(state), true);
      });

      test('does not unlock when Athena buildings are incomplete', () {
        final state = GameState.initial().copyWith(
          buildings: {
            BuildingType.hallOfWisdom: 1,
            BuildingType.academyOfAthens: 1,
            // Missing strategyChamber and oraclesArchive
          },
        );
        expect(AchievementDefinitions.academicExcellence.canUnlock(state), false);
      });

      test('does not unlock when any Athena building count is 0', () {
        final state = GameState.initial().copyWith(
          buildings: {
            BuildingType.hallOfWisdom: 1,
            BuildingType.academyOfAthens: 1,
            BuildingType.strategyChamber: 0, // Count is 0
            BuildingType.oraclesArchive: 1,
          },
        );
        expect(AchievementDefinitions.academicExcellence.canUnlock(state), false);
      });
    });

    group('All Phase 5 Achievements', () {
      test('all 10 Phase 5 achievements exist in the all list', () {
        final phase5Achievements = [
          AchievementDefinitions.firstWisdom,
          AchievementDefinitions.scholar,
          AchievementDefinitions.philosopherKing,
          AchievementDefinitions.goddessOfWisdom,
          AchievementDefinitions.godOfProphecy,
          AchievementDefinitions.firstProphecy,
          AchievementDefinitions.seer,
          AchievementDefinitions.masterOfKnowledge,
          AchievementDefinitions.divineLibrary,
          AchievementDefinitions.academicExcellence,
        ];

        for (final achievement in phase5Achievements) {
          expect(AchievementDefinitions.all.contains(achievement), true,
              reason: '${achievement.name} should be in all list');
        }
      });

      test('all achievement IDs are unique', () {
        final ids = AchievementDefinitions.all.map((a) => a.id).toSet();
        expect(ids.length, AchievementDefinitions.all.length);
      });

      test('getById returns each Phase 5 achievement', () {
        expect(AchievementDefinitions.getById('first_wisdom'), isNotNull);
        expect(AchievementDefinitions.getById('scholar'), isNotNull);
        expect(AchievementDefinitions.getById('philosopher_king'), isNotNull);
        expect(AchievementDefinitions.getById('goddess_of_wisdom'), isNotNull);
        expect(AchievementDefinitions.getById('god_of_prophecy'), isNotNull);
        expect(AchievementDefinitions.getById('first_prophecy'), isNotNull);
        expect(AchievementDefinitions.getById('seer'), isNotNull);
        expect(AchievementDefinitions.getById('master_of_knowledge'), isNotNull);
        expect(AchievementDefinitions.getById('divine_library'), isNotNull);
        expect(AchievementDefinitions.getById('academic_excellence'), isNotNull);
      });
    });
  });
}
