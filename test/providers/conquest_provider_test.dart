import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';

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
}
