import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';

void main() {
  group('Phase 5 Achievements - Properties', () {
    test('Seeker of Wisdom has correct properties', () {
      const achievement = AchievementDefinitions.seekerOfWisdom;
      expect(achievement.id, 'seeker_of_wisdom');
      expect(achievement.name, 'Seeker of Wisdom');
      expect(achievement.description, 'Begin your journey into divine knowledge');
      expect(achievement.category, AchievementCategory.gods);
      expect(achievement.reward, '+0.5 Wisdom/sec permanent bonus');
      expect(achievement.isHidden, false);
    });

    test('Scholarly Devotion has correct properties', () {
      const achievement = AchievementDefinitions.scholarlyDevotion;
      expect(achievement.id, 'scholarly_devotion');
      expect(achievement.name, 'Scholarly Devotion');
      expect(achievement.description, 'Dedicate yourself to the pursuit of wisdom');
      expect(achievement.category, AchievementCategory.buildings);
      expect(achievement.reward, 'Athena buildings produce +5% more Wisdom');
      expect(achievement.isHidden, false);
    });

    test('Wisdom Hoarder has correct properties', () {
      const achievement = AchievementDefinitions.wisdomHoarder;
      expect(achievement.id, 'wisdom_hoarder');
      expect(achievement.name, 'Wisdom Hoarder');
      expect(achievement.description, 'Amass a vast treasury of knowledge');
      expect(achievement.category, AchievementCategory.general);
      expect(achievement.reward, '+2% all resource production');
      expect(achievement.isHidden, false);
    });

    test('God of Light has correct properties', () {
      const achievement = AchievementDefinitions.godOfLight;
      expect(achievement.id, 'god_of_light');
      expect(achievement.name, 'God of Light');
      expect(achievement.description, 'Bask in Apollo\'s radiant enlightenment');
      expect(achievement.category, AchievementCategory.gods);
      expect(achievement.reward, '+1 Wisdom/sec permanent bonus');
      expect(achievement.isHidden, false);
    });

    test('Prophetic Devotee has correct properties', () {
      const achievement = AchievementDefinitions.propheticDevotee;
      expect(achievement.id, 'prophetic_devotee');
      expect(achievement.name, 'Prophetic Devotee');
      expect(achievement.description, 'Seek Apollo\'s visions with fervor');
      expect(achievement.category, AchievementCategory.general);
      expect(achievement.reward, 'All prophecy cooldowns reduced by 5%');
      expect(achievement.isHidden, false);
    });

    test('Oracle\'s Favorite has correct properties', () {
      const achievement = AchievementDefinitions.oraclesFavorite;
      expect(achievement.id, 'oracles_favorite');
      expect(achievement.name, 'Oracle\'s Favorite');
      expect(achievement.description, 'Master the art of divine foresight');
      expect(achievement.category, AchievementCategory.general);
      expect(achievement.reward, 'Apollo\'s Grand Vision cooldown reduced by 30 minutes');
      expect(achievement.isHidden, true);
    });

    test('Philosopher King has correct properties', () {
      const achievement = AchievementDefinitions.philosopherKing;
      expect(achievement.id, 'philosopher_king');
      expect(achievement.name, 'Philosopher King');
      expect(achievement.description, 'Achieve the pinnacle of intellectual pursuit');
      expect(achievement.category, AchievementCategory.research);
      expect(achievement.reward, 'All research costs reduced by 5%');
      expect(achievement.isHidden, false);
    });

    test('Renaissance Deity has correct properties', () {
      const achievement = AchievementDefinitions.renaissanceDeity;
      expect(achievement.id, 'renaissance_deity');
      expect(achievement.name, 'Renaissance Deity');
      expect(achievement.description, 'Balance wisdom and prophecy in perfect harmony');
      expect(achievement.category, AchievementCategory.buildings);
      expect(achievement.reward, '+10% Wisdom production from all sources');
      expect(achievement.isHidden, false);
    });

    test('Master of Knowledge has correct properties', () {
      const achievement = AchievementDefinitions.masterOfKnowledge;
      expect(achievement.id, 'master_of_knowledge');
      expect(achievement.name, 'Master of Knowledge');
      expect(achievement.description, 'Claim dominion over the centers of learning');
      expect(achievement.category, AchievementCategory.conquest);
      expect(achievement.reward, 'All conquest costs reduced by 10%');
      expect(achievement.isHidden, false);
    });

    test('Prescient Strategist has correct properties', () {
      const achievement = AchievementDefinitions.prescientStrategist;
      expect(achievement.id, 'prescient_strategist');
      expect(achievement.name, 'Prescient Strategist');
      expect(achievement.description, 'Progress through pure wisdom, untainted by material conversion');
      expect(achievement.category, AchievementCategory.general);
      expect(achievement.reward, '+25% offline cat production');
      expect(achievement.isHidden, true);
    });
  });

  group('All Phase 5 Achievements - Validation', () {
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

    test('all have unique IDs', () {
      final ids = phase5Achievements.map((a) => a.id).toSet();
      expect(ids.length, 10);
    });

    test('exactly 2 achievements are hidden', () {
      final hiddenCount = phase5Achievements.where((a) => a.isHidden).length;
      expect(hiddenCount, 2);
    });

    test('all have non-empty rewards', () {
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
}
