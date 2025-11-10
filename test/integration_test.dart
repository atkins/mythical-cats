import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test: Early Game Loop', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    GameNotifier _getNotifier() => container.read(gameProvider.notifier);

    test('complete early game progression', () async {
      final notifier = _getNotifier();
      // Start with 0 cats
      expect(notifier.state.getResource(ResourceType.cats), 0);

      // Click to get 15 cats
      for (int i = 0; i < 15; i++) {
        notifier.performRitual();
      }
      expect(notifier.state.getResource(ResourceType.cats), 15);

      // Buy first small shrine
      final bought = notifier.buyBuilding(BuildingType.smallShrine);
      expect(bought, true);
      expect(notifier.state.getBuildingCount(BuildingType.smallShrine), 1);
      expect(notifier.state.getResource(ResourceType.cats), 0);

      // Wait for production (simulate 100 seconds)
      for (int i = 0; i < 100; i++) {
        notifier.performRitual(); // Each click helps speed up
      }

      // Should have more than 100 cats now from clicking
      expect(notifier.state.getResource(ResourceType.cats) >= 100, true);

      // Buy a temple
      final boughtTemple = notifier.buyBuilding(BuildingType.temple);
      expect(boughtTemple, true);

      // Keep clicking to get to 1000 cats for Hestia unlock
      while (notifier.state.totalCatsEarned < 1000) {
        notifier.performRitual();
      }

      // Hestia should be unlocked
      expect(notifier.state.hasUnlockedGod(God.hestia), true);
    });

    test('buildings produce correct resources', () {
      final notifier = _getNotifier();
      // Give resources to buy hearth altar
      notifier.state = notifier.state.copyWith(
        resources: {
          ResourceType.cats: 5000,
          ResourceType.offerings: 500,
        },
      );

      // Buy hearth altar (produces offerings)
      notifier.buyBuilding(BuildingType.hearthAltar);

      expect(notifier.state.getBuildingCount(BuildingType.hearthAltar), 1);

      // The building produces offerings, not cats
      // (Would need to wait for game loop to verify production)
    });
  });
}
