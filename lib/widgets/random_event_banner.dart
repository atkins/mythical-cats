import 'package:flutter/material.dart';
import 'package:mythical_cats/models/random_event.dart';

/// Banner widget to display active random events
class RandomEventBanner extends StatelessWidget {
  final RandomEvent? event;

  const RandomEventBanner({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.amber[100],
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.amber[800],
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event!.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getEventDescription(event!),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventDescription(RandomEvent event) {
    if (event.type == RandomEventType.bonus) {
      // List bonus resources
      final bonuses = event.bonusResources.entries
          .map((e) => '${e.value.toInt()} ${e.key.name}')
          .join(', ');
      return 'Gained $bonuses!';
    } else if (event.type == RandomEventType.multiplier) {
      return '${event.multiplier.toInt()}x production for ${event.duration!.inSeconds} seconds!';
    } else {
      return event.description;
    }
  }
}
