import 'package:flutter_test/flutter_test.dart';
import 'package:mythical_cats/models/achievement.dart';
import 'package:mythical_cats/models/achievement_definitions.dart';

void main() {
  group('Achievement', () {
    test('has all required properties', () {
      final achievement = AchievementDefinitions.first100Cats;

      expect(achievement.id, 'cats_100');
      expect(achievement.name, 'Feline Friend');
      expect(achievement.description, 'Collect 100 cats');
      expect(achievement.category, AchievementCategory.cats);
      expect(achievement.bonusPercent, 0.5);
    });

    test('all achievements have unique IDs', () {
      final ids = AchievementDefinitions.all.map((a) => a.id).toSet();
      expect(ids.length, AchievementDefinitions.all.length);
    });

    test('can retrieve achievement by ID', () {
      final achievement = AchievementDefinitions.getById('cats_100');
      expect(achievement, isNotNull);
      expect(achievement!.name, 'Feline Friend');
    });

    test('returns null for invalid ID', () {
      final achievement = AchievementDefinitions.getById('invalid');
      expect(achievement, isNull);
    });
  });

  group('AchievementCategory', () {
    test('has display names for all categories', () {
      expect(AchievementCategory.cats.displayName, 'Cat Collection');
      expect(AchievementCategory.buildings.displayName, 'Buildings');
      expect(AchievementCategory.gods.displayName, 'Divine Favor');
      expect(AchievementCategory.general.displayName, 'General');
    });
  });
}
