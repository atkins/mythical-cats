import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/primordial_force.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConquestNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('canConquerTerritory returns true when affordable and prerequisites met', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.conquestPoints, 150);

      final conquest = container.read(conquestProvider);
      final canConquer = conquest.canConquerTerritory(ConquestDefinitions.northernWilds);

      expect(canConquer, true);
    });

    test('canConquerTerritory returns false when not affordable', () {
      final conquest = container.read(conquestProvider);
      final canConquer = conquest.canConquerTerritory(ConquestDefinitions.northernWilds);

      expect(canConquer, false);
    });

    test('canConquerTerritory returns false when prerequisite not met', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.conquestPoints, 1000);

      final conquest = container.read(conquestProvider);
      final canConquer = conquest.canConquerTerritory(ConquestDefinitions.easternMountains);

      expect(canConquer, false); // Requires northern_wilds
    });

    test('conquerTerritory succeeds and deducts cost', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.conquestPoints, 150);

      final conquest = container.read(conquestProvider);
      final success = conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      expect(success, true);

      final gameState = container.read(gameProvider);
      expect(gameState.hasConqueredTerritory('northern_wilds'), true);
      expect(gameState.getResource(ResourceType.conquestPoints), 50);
    });

    test('conquerTerritory fails when not affordable', () {
      final conquest = container.read(conquestProvider);
      final success = conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      expect(success, false);
    });

    test('getAvailableTerritories returns only conquerable territories', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.conquestPoints, 1000);

      final conquest = container.read(conquestProvider);
      final available = conquest.getAvailableTerritories();

      // Only northernWilds should be available initially
      expect(available.length, 1);
      expect(available[0].id, 'northern_wilds');
    });

    test('getTotalProductionBonus calculates correctly', () {
      final game = container.read(gameProvider.notifier);
      game.addResource(ResourceType.conquestPoints, 10000);

      final conquest = container.read(conquestProvider);
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);

      final bonuses = conquest.getTotalProductionBonus();
      expect(bonuses[ResourceType.cats], 0.05);
      expect(bonuses[ResourceType.offerings], 0.10);
    });
  });

  group('Complex Conquest Chains', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('three-level territorial prerequisite chain works', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 10000);

      // Level 1: Northern Wilds (no prerequisites)
      expect(conquest.canConquerTerritory(ConquestDefinitions.northernWilds), true);
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      // Level 2: Eastern Mountains (requires Northern Wilds)
      expect(conquest.canConquerTerritory(ConquestDefinitions.easternMountains), true);
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);

      // Level 3: Southern Forests (requires Eastern Mountains)
      expect(conquest.canConquerTerritory(ConquestDefinitions.southernSeas), true);
      conquest.conquerTerritory(ConquestDefinitions.southernSeas);

      final gameState = container.read(gameProvider);
      expect(gameState.hasConqueredTerritory('northern_wilds'), true);
      expect(gameState.hasConqueredTerritory('eastern_mountains'), true);
      expect(gameState.hasConqueredTerritory('southern_seas'), true);
    });

    test('cannot skip prerequisite territories', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 10000);

      // Try to conquer Eastern Mountains without Northern Wilds
      expect(conquest.canConquerTerritory(ConquestDefinitions.easternMountains), false);

      // Try to conquer Southern Forests without prerequisites
      expect(conquest.canConquerTerritory(ConquestDefinitions.southernSeas), false);
    });

    test('Phase 5 territories require correct prerequisites', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 20000000);

      // Academy of Athens should not be available without prerequisites
      expect(conquest.canConquerTerritory(ConquestDefinitions.academyOfAthens), false);

      // Conquer prerequisite chain
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);
      conquest.conquerTerritory(ConquestDefinitions.southernSeas);
      conquest.conquerTerritory(ConquestDefinitions.westernDeserts);
      conquest.conquerTerritory(ConquestDefinitions.centralCitadel);
      conquest.conquerTerritory(ConquestDefinitions.underworldGates);
      conquest.conquerTerritory(ConquestDefinitions.olympusFoothills);
      conquest.conquerTerritory(ConquestDefinitions.titansRealm);

      // Now Academy of Athens should be available
      expect(conquest.canConquerTerritory(ConquestDefinitions.academyOfAthens), true);
    });

    test('conquering all Phase 5 territories works', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 30000000);

      // Conquer all territories in order
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);
      conquest.conquerTerritory(ConquestDefinitions.southernSeas);
      conquest.conquerTerritory(ConquestDefinitions.westernDeserts);
      conquest.conquerTerritory(ConquestDefinitions.centralCitadel);
      conquest.conquerTerritory(ConquestDefinitions.underworldGates);
      conquest.conquerTerritory(ConquestDefinitions.olympusFoothills);
      conquest.conquerTerritory(ConquestDefinitions.titansRealm);
      conquest.conquerTerritory(ConquestDefinitions.academyOfAthens);
      conquest.conquerTerritory(ConquestDefinitions.oracleOfDelphi);
      conquest.conquerTerritory(ConquestDefinitions.libraryOfAlexandria);

      final gameState = container.read(gameProvider);
      expect(gameState.conqueredTerritories.length, 11);

      // All Phase 5 territories conquered
      expect(gameState.hasConqueredTerritory('academy_of_athens'), true);
      expect(gameState.hasConqueredTerritory('oracle_of_delphi'), true);
      expect(gameState.hasConqueredTerritory('library_of_alexandria'), true);
    });
  });

  group('Conquest Bonus Stacking', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('multiple territory bonuses for same resource stack additively', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 100000);

      // Northern Wilds: +5% cats
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      var bonuses = conquest.getTotalProductionBonus();
      expect(bonuses[ResourceType.cats], 0.05);

      // Southern Seas: +25% cats (should stack)
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);
      conquest.conquerTerritory(ConquestDefinitions.southernSeas);
      bonuses = conquest.getTotalProductionBonus();
      expect(bonuses[ResourceType.cats], 0.30); // 5% + 25% = 30%
    });

    test('bonuses affect production rates correctly', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      // Set up buildings first
      game.state = game.state.copyWith(
        buildings: {BuildingType.smallShrine: 10}, // 1.0 cats/sec base
        resources: {ResourceType.conquestPoints: 100000},
      );

      final baseProduction = game.getProductionRate(ResourceType.cats);
      expect(baseProduction, closeTo(1.0, 0.01));

      // Conquer Northern Wilds (+5% cats)
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      final boostedProduction = game.getProductionRate(ResourceType.cats);
      expect(boostedProduction, closeTo(1.05, 0.01));
    });

    test('different resource bonuses accumulate independently', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 100000);

      // Northern Wilds: +5% cats
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      // Eastern Mountains: +10% offerings
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);

      // Southern Seas: +25% cats, +25% offerings
      conquest.conquerTerritory(ConquestDefinitions.southernSeas);

      final bonuses = conquest.getTotalProductionBonus();
      expect(bonuses[ResourceType.cats], 0.30); // 5% + 25%
      expect(bonuses[ResourceType.offerings], 0.35); // 10% + 25%
    });
  });

  // Note: Conquest cost reductions and achievement integration not yet implemented

  group('Conquest State Persistence', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('conquered territories reset on reincarnation', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 10000);

      // Conquer some territories
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      conquest.conquerTerritory(ConquestDefinitions.easternMountains);

      expect(container.read(gameProvider).conqueredTerritories.length, 2);

      // Prepare for reincarnation
      game.state = game.state.copyWith(totalCatsEarned: 1000000000);

      // Reincarnate
      game.reincarnate(PrimordialForce.chaos);

      // Territories should be reset
      final gameState = container.read(gameProvider);
      expect(gameState.conqueredTerritories.isEmpty, true);
    });

    test('cannot conquer same territory twice', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      game.addResource(ResourceType.conquestPoints, 10000);

      // Conquer once
      final firstConquest = conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      expect(firstConquest, true);

      final cpAfterFirst = container.read(gameProvider).getResource(ResourceType.conquestPoints);

      // Try to conquer again
      final secondConquest = conquest.conquerTerritory(ConquestDefinitions.northernWilds);
      expect(secondConquest, false);

      final cpAfterSecond = container.read(gameProvider).getResource(ResourceType.conquestPoints);

      // Resources should not be deducted second time
      expect(cpAfterSecond, cpAfterFirst);
    });
  });
}
