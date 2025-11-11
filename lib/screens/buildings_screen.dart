import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/models/building_type.dart';
import 'package:mythical_cats/models/building_definition.dart';
import 'package:mythical_cats/models/god.dart';
import 'package:mythical_cats/widgets/building_card.dart';
import 'package:mythical_cats/widgets/workshop_converter.dart';

class BuildingsScreen extends ConsumerWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Check if workshop is owned to show converter
    final hasWorkshop = gameState.getBuildingCount(BuildingType.workshop) > 0;

    // Organize buildings into sections
    final sections = _organizeBuildingSections(gameState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buildings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _calculateItemCount(sections, hasWorkshop),
        itemBuilder: (context, index) {
          // Show workshop converter at the top if workshop is owned
          if (hasWorkshop && index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: WorkshopConverter(),
            );
          }

          // Adjust index for sections
          final adjustedIndex = hasWorkshop ? index - 1 : index;

          // Render sections
          return _renderSectionItem(
            context,
            sections,
            adjustedIndex,
            gameState,
            gameNotifier,
          );
        },
      ),
    );
  }

  int _calculateItemCount(List<BuildingSection> sections, bool hasWorkshop) {
    int count = hasWorkshop ? 1 : 0; // Workshop converter
    for (final section in sections) {
      count++; // Section header
      count += section.buildings.length; // Buildings in section
    }
    return count;
  }

  Widget _renderSectionItem(
    BuildContext context,
    List<BuildingSection> sections,
    int adjustedIndex,
    dynamic gameState,
    dynamic gameNotifier,
  ) {
    int currentIndex = 0;

    for (final section in sections) {
      // Check if this index is the section header
      if (currentIndex == adjustedIndex) {
        return _buildSectionHeader(context, section.title);
      }
      currentIndex++;

      // Check if this index is one of the buildings in this section
      for (final buildingType in section.buildings) {
        if (currentIndex == adjustedIndex) {
          return _buildBuildingCard(
            buildingType,
            gameState,
            gameNotifier,
          );
        }
        currentIndex++;
      }
    }

    // Should never reach here
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildBuildingCard(
    BuildingType buildingType,
    dynamic gameState,
    dynamic gameNotifier,
  ) {
    final definition = BuildingDefinitions.get(buildingType);
    final owned = gameState.getBuildingCount(buildingType);
    final cost = definition.calculateCost(owned);

    // Check if unlocked
    final requiredGod = buildingType.requiredGod;
    final isUnlocked = requiredGod == null ||
                       gameState.hasUnlockedGod(requiredGod);

    // Check if can afford
    bool canAfford = true;
    for (final entry in cost.entries) {
      if (gameState.getResource(entry.key) < entry.value) {
        canAfford = false;
        break;
      }
    }

    return BuildingCard(
      type: buildingType,
      owned: owned,
      cost: cost,
      canAfford: canAfford,
      isUnlocked: isUnlocked,
      onBuy: () => gameNotifier.buyBuilding(buildingType),
    );
  }

  List<BuildingSection> _organizeBuildingSections(dynamic gameState) {
    final sections = <BuildingSection>[];

    // Basic Buildings section
    sections.add(BuildingSection(
      title: 'Basic Buildings',
      buildings: [
        BuildingType.smallShrine,
        BuildingType.temple,
        BuildingType.grandSanctuary,
      ],
    ));

    // God-specific buildings (existing early game gods)
    final earlyGodBuildings = <BuildingType>[];
    if (gameState.hasUnlockedGod(God.hermes)) {
      earlyGodBuildings.add(BuildingType.messengerWaystation);
    }
    if (gameState.hasUnlockedGod(God.hestia)) {
      earlyGodBuildings.add(BuildingType.hearthAltar);
    }
    if (gameState.hasUnlockedGod(God.demeter)) {
      earlyGodBuildings.add(BuildingType.harvestField);
    }
    if (gameState.hasUnlockedGod(God.dionysus)) {
      earlyGodBuildings.add(BuildingType.festivalGrounds);
    }

    if (earlyGodBuildings.isNotEmpty) {
      sections.add(BuildingSection(
        title: 'God Buildings',
        buildings: earlyGodBuildings,
      ));
    }

    // Mid-game buildings
    final midGameBuildings = <BuildingType>[];
    if (gameState.hasUnlockedGod(God.athena)) {
      midGameBuildings.add(BuildingType.academy);
      midGameBuildings.add(BuildingType.essenceRefinery);
    }
    if (gameState.hasUnlockedGod(God.apollo)) {
      midGameBuildings.add(BuildingType.nectarBrewery);
    }
    if (gameState.hasUnlockedGod(God.hephaestus)) {
      midGameBuildings.add(BuildingType.workshop);
    }
    if (gameState.hasUnlockedGod(God.ares)) {
      midGameBuildings.add(BuildingType.warMonument);
    }

    if (midGameBuildings.isNotEmpty) {
      sections.add(BuildingSection(
        title: 'Advanced Buildings',
        buildings: midGameBuildings,
      ));
    }

    // Athena Buildings section (Phase 5)
    if (gameState.hasUnlockedGod(God.athena)) {
      sections.add(BuildingSection(
        title: 'Athena Buildings',
        buildings: [
          BuildingType.hallOfWisdom,
          BuildingType.academyOfAthens,
          BuildingType.strategyChamber,
          BuildingType.oraclesArchive,
        ],
      ));
    }

    // Apollo Buildings section (Phase 5)
    if (gameState.hasUnlockedGod(God.apollo)) {
      sections.add(BuildingSection(
        title: 'Apollo Buildings',
        buildings: [
          BuildingType.templeOfDelphi,
          BuildingType.sunChariotStable,
          BuildingType.musesSanctuary,
          BuildingType.celestialObservatory,
        ],
      ));
    }

    return sections;
  }
}

class BuildingSection {
  final String title;
  final List<BuildingType> buildings;

  BuildingSection({
    required this.title,
    required this.buildings,
  });
}
