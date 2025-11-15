import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/random_event_definitions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Random Events Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('full event lifecycle: spawn → activate → expire', () async {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set up state to allow spawning
      gameNotifier.state = gameNotifier.state.copyWith(
        lastRandomEventSpawnTime: DateTime.now().subtract(Duration(minutes: 6)),
        resources: {ResourceType.cats: 100},
      );

      // Spawn event manually (testing the full flow)
      gameNotifier.activateRandomEvent(RandomEventDefinitions.divineCatAppears);

      // Verify event is active
      expect(gameNotifier.state.activeRandomEvent?.id, 'divine_cat');
      expect(gameNotifier.state.getResource(ResourceType.cats), 150); // +50 cats

      // Wait for auto-clear (3 seconds for bonus events)
      await Future.delayed(Duration(seconds: 4));

      // Verify event cleared
      expect(gameNotifier.state.activeRandomEvent, isNull);
    });

    test('multiplier event boosts production during duration', () async {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set up base production
      gameNotifier.state = gameNotifier.state.copyWith(
        buildings: {BuildingType.smallShrine: 10}, // 1.0 cats/sec
        resources: {ResourceType.cats: 1000},
      );

      final baseProduction = gameNotifier.getProductionRate(ResourceType.cats);
      expect(baseProduction, closeTo(1.0, 0.01));

      // Activate multiplier event
      gameNotifier.activateRandomEvent(RandomEventDefinitions.divineFavor);

      final boostedProduction = gameNotifier.getProductionRate(ResourceType.cats);
      expect(boostedProduction, closeTo(2.0, 0.01)); // 2x multiplier

      // Verify event is active
      expect(gameNotifier.state.hasActiveRandomEventMultiplier, true);
    });

    test('event cooldown prevents rapid spawning', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // Spawn first event
      gameNotifier.activateRandomEvent(RandomEventDefinitions.divineCatAppears);
      final firstSpawnTime = gameNotifier.state.lastRandomEventSpawnTime;

      // Clear active event (simulating it disappearing after 3 seconds)
      gameNotifier.state = gameNotifier.state.copyWith(activeRandomEvent: null);

      // Try to spawn immediately (should fail due to cooldown)
      for (int i = 0; i < 1000; i++) {
        gameNotifier.trySpawnRandomEvent();
      }

      // Should not have spawned (still on cooldown)
      expect(gameNotifier.state.lastRandomEventSpawnTime, firstSpawnTime);
      expect(gameNotifier.state.activeRandomEvent, isNull);
    });

    test('event multipliers stack with conquest and research bonuses', () {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set up base production with multiple bonuses
      gameNotifier.state = gameNotifier.state.copyWith(
        buildings: {BuildingType.smallShrine: 10},
        conqueredTerritories: {'northern_wilds'}, // +5% cats
        resources: {ResourceType.cats: 1000},
      );

      final withConquest = gameNotifier.getProductionRate(ResourceType.cats);
      expect(withConquest, closeTo(1.05, 0.01));

      // Activate event (2x multiplier)
      gameNotifier.activateRandomEvent(RandomEventDefinitions.divineFavor);

      final withEvent = gameNotifier.getProductionRate(ResourceType.cats);
      expect(withEvent, closeTo(1.05 * 2.0, 0.01)); // Multiplicative stacking
    });

    test('multiple event cycles work correctly', () async {
      final gameNotifier = container.read(gameProvider.notifier);

      // Set initial state
      gameNotifier.state = gameNotifier.state.copyWith(
        resources: {ResourceType.cats: 100},
        lastRandomEventSpawnTime: DateTime.now().subtract(Duration(minutes: 6)),
      );

      // First event
      gameNotifier.activateRandomEvent(RandomEventDefinitions.divineCatAppears);
      expect(gameNotifier.state.getResource(ResourceType.cats), 150);

      await Future.delayed(Duration(seconds: 4));
      expect(gameNotifier.state.activeRandomEvent, isNull);

      // Update spawn time to allow second event
      gameNotifier.state = gameNotifier.state.copyWith(
        lastRandomEventSpawnTime: DateTime.now().subtract(Duration(minutes: 6)),
      );

      // Second event
      gameNotifier.activateRandomEvent(RandomEventDefinitions.prayerCircle);
      expect(gameNotifier.state.activeRandomEvent?.id, 'prayer_circle');
      expect(gameNotifier.state.getResource(ResourceType.prayers), 50);

      await Future.delayed(Duration(seconds: 4));
      expect(gameNotifier.state.activeRandomEvent, isNull);
    });
  });
}
