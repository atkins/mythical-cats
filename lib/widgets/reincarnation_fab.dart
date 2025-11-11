import 'package:flutter/material.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class ReincarnationFab extends StatelessWidget {
  final int peEarned;
  final bool isEnabled;
  final double catsRemaining;
  final VoidCallback onPressed;

  const ReincarnationFab({
    super.key,
    required this.peEarned,
    required this.isEnabled,
    required this.catsRemaining,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isEnabled ? onPressed : null,
      backgroundColor:
          isEnabled ? Colors.deepPurple : Colors.grey.shade400,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.autorenew),
      label: Text(
        isEnabled
            ? 'Reincarnate for $peEarned PE'
            : 'Need 1B cats (${NumberFormatter.format(catsRemaining)} more)',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
