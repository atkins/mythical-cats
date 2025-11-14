import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resource_type.dart';
import '../providers/game_provider.dart';
import '../utils/number_formatter.dart';

class CompactResourceBar extends ConsumerWidget {
  const CompactResourceBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Build list of resources to display
    final resourcesToShow = <_ResourceInfo>[];

    // Core resources (always show)
    resourcesToShow.add(_ResourceInfo(
      emoji: ResourceType.cats.icon,
      value: gameState.getResource(ResourceType.cats),
      rate: gameNotifier.getCatsPerSecond(),
    ));
    resourcesToShow.add(_ResourceInfo(
      emoji: ResourceType.prayers.icon,
      value: gameState.getResource(ResourceType.prayers),
      rate: gameNotifier.getPrayersPerSecond(),
    ));
    resourcesToShow.add(_ResourceInfo(
      emoji: ResourceType.offerings.icon,
      value: gameState.getResource(ResourceType.offerings),
      rate: gameNotifier.getOfferingsPerSecond(),
    ));

    // Advanced resources (show only if > 0)
    final divineEssence = gameState.getResource(ResourceType.divineEssence);
    if (divineEssence > 0) {
      resourcesToShow.add(_ResourceInfo(
        emoji: ResourceType.divineEssence.icon,
        value: divineEssence,
        rate: gameNotifier.getDivineEssencePerSecond(),
      ));
    }

    final ambrosia = gameState.getResource(ResourceType.ambrosia);
    if (ambrosia > 0) {
      resourcesToShow.add(_ResourceInfo(
        emoji: ResourceType.ambrosia.icon,
        value: ambrosia,
        rate: gameNotifier.getAmbrosiaPerSecond(),
      ));
    }

    final wisdom = gameState.getResource(ResourceType.wisdom);
    if (wisdom > 0) {
      resourcesToShow.add(_ResourceInfo(
        emoji: ResourceType.wisdom.icon,
        value: wisdom,
        rate: gameNotifier.getWisdomPerSecond(),
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: resourcesToShow.map((info) {
          return _buildResourceItem(context, info);
        }).toList(),
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, _ResourceInfo info) {
    final formattedValue = NumberFormatter.format(info.value);
    final formattedRate = NumberFormatter.formatRate(info.rate);

    return Text(
      '${info.emoji} $formattedValue ($formattedRate)',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.87),
          ),
    );
  }
}

class _ResourceInfo {
  final String emoji;
  final double value;
  final double rate;

  _ResourceInfo({
    required this.emoji,
    required this.value,
    required this.rate,
  });
}
