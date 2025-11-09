import 'package:flutter/material.dart';
import 'package:mythical_cats/models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
      elevation: isUnlocked ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock,
              size: 40,
              color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUnlocked ? Colors.grey.shade700 : Colors.grey.shade500,
                    ),
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${achievement.bonusPercent}% production',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
