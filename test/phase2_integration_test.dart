import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    GameNotifier getNotifier() => container.read(gameProvider.notifier);

    test('Demeter unlocks and harvest field becomes available', () {
      final notifier = getNotifier();
      // Set up state to unlock Demeter
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 10000,
        resources: {
          ResourceType.cats: 10000,
          ResourceType.offerings: 1000,
        },
      );

      // Trigger god unlock
      notifier.performRitual();

      expect(notifier.state.hasUnlockedGod(God.demeter), true);

      // Should be able to buy harvest field
      final success = notifier.buyBuilding(BuildingType.harvestField);
      expect(success, true);
      expect(notifier.state.getBuildingCount(BuildingType.harvestField), 1);
    });

    test('Dionysus unlocks at 100K cats', () {
      final notifier = getNotifier();
      notifier.state = notifier.state.copyWith(
        totalCatsEarned: 100000,
        resources: {ResourceType.cats: 100000},
      );

      notifier.performRitual();

      expect(notifier.state.hasUnlockedGod(God.dionysus), true);
      expect(notifier.state.hasUnlockedAchievement('god_dionysus'), true);
    });

    test('achievements unlock at correct milestones', () {
      final notifier = getNotifier();
      // Click to 100 cats
      for (int i = 0; i < 100; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.hasUnlockedAchievement('cats_100'), true);

      // Click to 1000 total
      for (int i = 0; i < 900; i++) {
        notifier.performRitual();
      }

      expect(notifier.state.hasUnlockedAchievement('cats_1k'), true);
      expect(notifier.state.hasUnlockedAchievement('god_hestia'), true);
    });

    test('building achievements unlock correctly', () {
      final notifier = getNotifier();
      notifier.state = notifier.state.copyWith(
        resources: {ResourceType.cats: 100000},
      );

      // Buy 10 buildings
      for (int i = 0; i < 10; i++) {
        notifier.buyBuilding(BuildingType.smallShrine);
      }

      expect(notifier.state.hasUnlockedAchievement('buildings_10'), true);
    });

    test('all Tier 1 resources can be produced', () {
      final notifier = getNotifier();
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 100000,
          ResourceType.offerings: 10000,
          ResourceType.prayers: 1000,
        },
        unlockedGods: {God.hermes, God.hestia, God.demeter},
      );

      // Buy one of each building type
      notifier.buyBuilding(BuildingType.smallShrine); // Produces cats
      notifier.buyBuilding(BuildingType.hearthAltar); // Produces offerings
      notifier.buyBuilding(BuildingType.harvestField); // Produces prayers

      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 1);
      expect(notifier.state.getBuildingCount(BuildingType.hearthAltar), 1);
      expect(notifier.state.getBuildingCount(BuildingType.harvestField), 1);
    });
  });
}
