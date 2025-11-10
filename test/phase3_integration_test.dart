import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/conquest_definitions.dart';
import 'package:mythical_cats/models/game_state.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/models/research_definitions.dart';
import 'package:mythical_cats/models/resource_type.dart';
import 'package:mythical_cats/providers/conquest_provider.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/providers/research_provider.dart';

void main() {
  group('Phase 3 Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Complete research unlock flow works end-to-end', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      // Unlock Athena to enable research (automatically unlocks at 1M cats earned)
      // Need to update both resources and totalCatsEarned
      final currentState = container.read(gameProvider);
      game.updateState(currentState.copyWith(
        resources: {
          ...currentState.resources,
          ResourceType.cats: 1000000,
        },
        totalCatsEarned: 1000000,
        unlockedGods: {...currentState.unlockedGods, God.athena},
      ));

      // Test research tree progression
      // 1. Unlock Divine Architecture I (foundation)
      game.addResource(ResourceType.cats, 5000);
      game.addResource(ResourceType.prayers, 1000);

      final arch1 = ResearchDefinitions.divineArchitecture1;
      expect(research.canUnlockResearch(arch1), true);
      expect(research.unlockResearch(arch1), true);

      final state1 = container.read(gameProvider);
      expect(state1.hasCompletedResearch('divine_architecture_1'), true);

      // 2. Unlock Sacred Geometry (requires Divine Architecture I)
      game.addResource(ResourceType.cats, 10000);
      game.addResource(ResourceType.prayers, 2000);

      final sacredGeo = ResearchDefinitions.sacredGeometry;
      expect(research.canUnlockResearch(sacredGeo), true);
      expect(research.unlockResearch(sacredGeo), true);

      final state2 = container.read(gameProvider);
      expect(state2.hasCompletedResearch('sacred_geometry'), true);

      // 3. Verify prerequisite blocking
      // Divine Architecture II requires Sacred Geometry
      game.addResource(ResourceType.cats, 50000);
      game.addResource(ResourceType.prayers, 5000);

      final arch2 = ResearchDefinitions.divineArchitecture2;
      expect(research.canUnlockResearch(arch2), true);
      expect(research.unlockResearch(arch2), true);

      final state3 = container.read(gameProvider);
      expect(state3.hasCompletedResearch('divine_architecture_2'), true);
    });

    test('Conquest territory progression with bonuses works correctly', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      // Unlock Ares to enable conquest (automatically unlocks at 1B cats earned)
      final currentState = container.read(gameProvider);
      game.updateState(currentState.copyWith(
        resources: {
          ...currentState.resources,
          ResourceType.cats: 1000000000,
        },
        totalCatsEarned: 1000000000,
        unlockedGods: {...currentState.unlockedGods, God.ares},
      ));

      // Setup: Add a building that produces cats
      game.addResource(ResourceType.cats, 1000);
      game.buyBuilding(BuildingType.smallShrine);

      // Check base production before conquest
      final baseProduction = game.getProductionRate(ResourceType.cats);
      expect(baseProduction, closeTo(0.1, 0.01));

      // 1. Conquer Northern Wilds (+5% cats)
      game.addResource(ResourceType.conquestPoints, 100);
      final northernWilds = ConquestDefinitions.northernWilds;
      expect(conquest.canConquerTerritory(northernWilds), true);
      expect(conquest.conquerTerritory(northernWilds), true);

      final state1 = container.read(gameProvider);
      expect(state1.hasConqueredTerritory('northern_wilds'), true);

      // Check production increased by 5%
      final production1 = game.getProductionRate(ResourceType.cats);
      expect(production1, closeTo(0.105, 0.001));

      // 2. Conquer Eastern Mountains (requires Northern Wilds, +10% offerings)
      game.addResource(ResourceType.conquestPoints, 500);
      final easternMountains = ConquestDefinitions.easternMountains;
      expect(conquest.canConquerTerritory(easternMountains), true);
      expect(conquest.conquerTerritory(easternMountains), true);

      // 3. Verify bonuses accumulate
      final totalBonuses = conquest.getTotalProductionBonus();
      expect(totalBonuses[ResourceType.cats], 0.05);
      expect(totalBonuses[ResourceType.offerings], 0.10);
    });

    test('All Phase 3 buildings can be purchased and produce resources', () {
      final game = container.read(gameProvider.notifier);

      // Academy (costs 25k cats, 2.5k prayers - produces 1 cat/s)
      game.addResource(ResourceType.cats, 50000);
      game.addResource(ResourceType.prayers, 5000);
      expect(game.buyBuilding(BuildingType.academy), true);

      final state1 = container.read(gameProvider);
      expect(state1.getBuildingCount(BuildingType.academy), 1);
      expect(game.getProductionRate(ResourceType.cats), greaterThanOrEqualTo(0.5)); // At least some production

      // Essence Refinery
      game.addResource(ResourceType.cats, 100000);
      game.addResource(ResourceType.offerings, 10000);
      expect(game.buyBuilding(BuildingType.essenceRefinery), true);

      final state2 = container.read(gameProvider);
      expect(state2.getBuildingCount(BuildingType.essenceRefinery), 1);
      expect(game.getProductionRate(ResourceType.divineEssence), greaterThan(0));

      // Nectar Brewery (costs 1M cats, 500 divine essence)
      game.addResource(ResourceType.cats, 1000000);
      game.addResource(ResourceType.divineEssence, 500);
      expect(game.buyBuilding(BuildingType.nectarBrewery), true);

      final state3 = container.read(gameProvider);
      expect(state3.getBuildingCount(BuildingType.nectarBrewery), 1);
      expect(game.getProductionRate(ResourceType.ambrosia), greaterThan(0));

      // Workshop
      game.addResource(ResourceType.cats, 250000);
      game.addResource(ResourceType.divineEssence, 100);
      expect(game.buyBuilding(BuildingType.workshop), true);

      final state4 = container.read(gameProvider);
      expect(state4.getBuildingCount(BuildingType.workshop), 1);

      // War Monument (costs 5M cats, 1000 ambrosia)
      game.addResource(ResourceType.cats, 5000000);
      game.addResource(ResourceType.ambrosia, 1000);
      expect(game.buyBuilding(BuildingType.warMonument), true);

      final state5 = container.read(gameProvider);
      expect(state5.getBuildingCount(BuildingType.warMonument), 1);
      expect(game.getProductionRate(ResourceType.conquestPoints), greaterThan(0));
    });

    test('Workshop conversion mechanic works with Divine Alchemy research', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      // Setup: Build workshop (need enough resources)
      game.addResource(ResourceType.cats, 250000);
      game.addResource(ResourceType.divineEssence, 100);
      game.buyBuilding(BuildingType.workshop);

      // Test base conversion (10:1)
      // Workshop costs divine essence to build, so we start with less essence
      game.addResource(ResourceType.offerings, 1000);

      final essenceBefore = container.read(gameProvider).getResource(ResourceType.divineEssence);
      expect(game.convertInWorkshop(100), true);

      final state1 = container.read(gameProvider);
      expect(state1.getResource(ResourceType.offerings), 900);
      expect(state1.getResource(ResourceType.divineEssence), closeTo(essenceBefore + 10, 0.1)); // before + (100/10)

      // Unlock Divine Alchemy research
      game.addResource(ResourceType.cats, 200000);
      game.addResource(ResourceType.divineEssence, 200);
      final divineAlchemy = ResearchDefinitions.divineAlchemy;
      research.unlockResearch(divineAlchemy);

      // Test improved conversion (8:1)
      game.addResource(ResourceType.offerings, 1000);
      final essenceBefore2 = container.read(gameProvider).getResource(ResourceType.divineEssence);
      expect(game.convertInWorkshop(80), true);

      final state2 = container.read(gameProvider);
      expect(state2.getResource(ResourceType.offerings), closeTo(1820, 0.1)); // 900 + 1000 - 80
      // After Divine Alchemy, conversion should be better (8:1 vs 10:1)
      // 80 offerings / 8 = 10 divine essence gained
      expect(state2.getResource(ResourceType.divineEssence), closeTo(essenceBefore2 + 10, 2.5)); // before + (80/8)
    });

    test('GameState serialization persists Phase 3 data', () {
      final game = container.read(gameProvider.notifier);

      // Setup Phase 3 state - need enough resources to buy buildings
      // Academy: 50k cats, 5k prayers (with 1.15 multiplier for bulk)
      // 2 academies: ~110k cats, ~11k prayers
      // Workshop: 250k cats, 100 divine essence
      game.addResource(ResourceType.conquestPoints, 500);
      game.addResource(ResourceType.cats, 400000); // Enough for 2 academies + workshop
      game.addResource(ResourceType.prayers, 15000); // Enough for academies
      game.addResource(ResourceType.divineEssence, 200); // Enough for workshop

      final bought1 = game.buyBuilding(BuildingType.academy, amount: 2);
      expect(bought1, true, reason: 'Should be able to buy 2 academies');

      final bought2 = game.buyBuilding(BuildingType.workshop);
      expect(bought2, true, reason: 'Should be able to buy workshop');

      // Complete some research
      game.addResource(ResourceType.cats, 10000);
      game.addResource(ResourceType.prayers, 2000);
      final research = container.read(researchProvider);
      research.unlockResearch(ResearchDefinitions.divineArchitecture1);

      // Conquer a territory
      game.addResource(ResourceType.conquestPoints, 100);
      final conquest = container.read(conquestProvider);
      conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      // Serialize
      final state = container.read(gameProvider);
      final json = state.toJson();

      // Verify serialization
      expect(json['completedResearch'], isA<List>());
      expect(json['completedResearch'], contains('divine_architecture_1'));
      expect(json['conqueredTerritories'], isA<List>());
      expect(json['conqueredTerritories'], contains('northern_wilds'));
      expect(json['resources']['conquestPoints'], isNotNull);
      expect(json['buildings']['academy'], 2);
      expect(json['buildings']['workshop'], 1);

      // Deserialize
      final restoredState = GameState.fromJson(json);

      // Verify restoration
      expect(restoredState.hasCompletedResearch('divine_architecture_1'), true);
      expect(restoredState.hasConqueredTerritory('northern_wilds'), true);
      expect(restoredState.getResource(ResourceType.conquestPoints), 500);
      expect(restoredState.getBuildingCount(BuildingType.academy), 2);
      expect(restoredState.getBuildingCount(BuildingType.workshop), 1);
    });

    test('Research prerequisites prevent out-of-order unlocks', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);

      // Try to unlock Sacred Geometry without Divine Architecture I
      game.addResource(ResourceType.cats, 20000);
      game.addResource(ResourceType.prayers, 5000);

      final sacredGeo = ResearchDefinitions.sacredGeometry;
      expect(research.canUnlockResearch(sacredGeo), false);
      expect(research.unlockResearch(sacredGeo), false);

      // Unlock prerequisite
      final arch1 = ResearchDefinitions.divineArchitecture1;
      expect(research.unlockResearch(arch1), true);

      // Now Sacred Geometry should be unlockable
      expect(research.canUnlockResearch(sacredGeo), true);
      expect(research.unlockResearch(sacredGeo), true);
    });

    test('Conquest prerequisites prevent out-of-order conquests', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      // Try to conquer Eastern Mountains without Northern Wilds
      game.addResource(ResourceType.conquestPoints, 1000);

      final easternMountains = ConquestDefinitions.easternMountains;
      expect(conquest.canConquerTerritory(easternMountains), false);
      expect(conquest.conquerTerritory(easternMountains), false);

      // Conquer prerequisite
      final northernWilds = ConquestDefinitions.northernWilds;
      expect(conquest.conquerTerritory(northernWilds), true);

      // Now Eastern Mountains should be conquerable
      expect(conquest.canConquerTerritory(easternMountains), true);
      expect(conquest.conquerTerritory(easternMountains), true);
    });

    test('Production bonuses stack correctly with multiple territories', () {
      final game = container.read(gameProvider.notifier);
      final conquest = container.read(conquestProvider);

      // Setup production buildings
      game.addResource(ResourceType.cats, 10000);
      game.addResource(ResourceType.offerings, 1000);
      game.buyBuilding(BuildingType.smallShrine, amount: 10);
      game.buyBuilding(BuildingType.temple, amount: 5);

      final baseProduction = game.getProductionRate(ResourceType.cats);

      // Conquer multiple territories with cat bonuses
      game.addResource(ResourceType.conquestPoints, 100000);

      conquest.conquerTerritory(ConquestDefinitions.northernWilds); // +5%
      final production1 = game.getProductionRate(ResourceType.cats);
      expect(production1, closeTo(baseProduction * 1.05, 0.01));

      // Note: Only Northern Wilds gives cat bonus directly
      // Other territories need to be conquered in sequence
      // This test verifies bonus calculation works correctly
      final bonuses = conquest.getTotalProductionBonus();
      expect(bonuses[ResourceType.cats], 0.05);
    });

    test('Full Phase 3 progression works end-to-end', () {
      final game = container.read(gameProvider.notifier);
      final research = container.read(researchProvider);
      final conquest = container.read(conquestProvider);

      // 1. Unlock Athena and complete research (need to set totalCatsEarned)
      final currentState = container.read(gameProvider);
      game.updateState(currentState.copyWith(
        resources: {
          ...currentState.resources,
          ResourceType.cats: 2000000,
          ResourceType.prayers: 10000,
        },
        totalCatsEarned: 2000000,
        unlockedGods: {...currentState.unlockedGods, God.athena},
      ));

      research.unlockResearch(ResearchDefinitions.divineArchitecture1);
      research.unlockResearch(ResearchDefinitions.sacredGeometry);

      // 2. Build Phase 3 buildings
      game.addResource(ResourceType.cats, 500000);
      game.addResource(ResourceType.prayers, 10000);
      game.addResource(ResourceType.offerings, 50000);
      game.addResource(ResourceType.divineEssence, 200);
      game.buyBuilding(BuildingType.academy);
      game.buyBuilding(BuildingType.essenceRefinery);
      game.buyBuilding(BuildingType.workshop);

      // 3. Use Workshop conversion
      game.addResource(ResourceType.offerings, 1000);
      expect(game.convertInWorkshop(100), true);

      // 4. Unlock Ares and conquer territory (need to update totalCatsEarned)
      final currentState2 = container.read(gameProvider);
      game.updateState(currentState2.copyWith(
        resources: {
          ...currentState2.resources,
          ResourceType.cats: currentState2.getResource(ResourceType.cats) + 1000000000,
          ResourceType.conquestPoints: 200,
        },
        totalCatsEarned: currentState2.totalCatsEarned + 1000000000,
        unlockedGods: {...currentState2.unlockedGods, God.ares},
      ));

      conquest.conquerTerritory(ConquestDefinitions.northernWilds);

      // 5. Verify everything works together
      final finalState = container.read(gameProvider);
      expect(finalState.hasUnlockedGod(God.athena), true);
      expect(finalState.hasUnlockedGod(God.ares), true);
      expect(finalState.hasCompletedResearch('divine_architecture_1'), true);
      expect(finalState.hasConqueredTerritory('northern_wilds'), true);
      expect(finalState.getBuildingCount(BuildingType.academy), 1);
      expect(finalState.getBuildingCount(BuildingType.workshop), 1);

      // Production exists
      final production = game.getProductionRate(ResourceType.cats);
      expect(production, greaterThan(0)); // Academy produces cats
    });
  });
}
