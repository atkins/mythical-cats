import 'package:flutter/material.dart';
import 'package:mythical_cats/utils/number_formatter.dart';

class OfflineProgressDialog extends StatelessWidget {
  final Duration duration;
  final double catsEarned;
  final VoidCallback onDismiss;

  const OfflineProgressDialog({
    super.key,
    required this.duration,
    required this.catsEarned,
    required this.onDismiss,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome Back!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            'You were away for ${_formatDuration(duration)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text('Cats Earned:'),
                const SizedBox(height: 8),
                Text(
                  '+${NumberFormatter.format(catsEarned)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Awesome!'),
        ),
      ],
    );
  }
}
