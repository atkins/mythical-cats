import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';
import 'package:mythical_cats/widgets/offline_progress_dialog.dart';
import 'package:mythical_cats/models/resource_type.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mythical Cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GameLoader(),
    );
  }
}

class GameLoader extends ConsumerStatefulWidget {
  const GameLoader({super.key});

  @override
  ConsumerState<GameLoader> createState() => _GameLoaderState();
}

class _GameLoaderState extends ConsumerState<GameLoader> {
  bool _hasShownOfflineDialog = false;

  @override
  Widget build(BuildContext context) {
    final initialState = ref.watch(initialGameStateProvider);

    return initialState.when(
      data: (state) {
        // Initialize game with loaded state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final notifier = ref.read(gameProvider.notifier);
          notifier.loadState(state);

          // Show offline progress if applicable
          if (!_hasShownOfflineDialog) {
            _hasShownOfflineDialog = true;
            _showOfflineProgressIfNeeded(state);
          }
        });
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error loading game: $err'),
        ),
      ),
    );
  }

  void _showOfflineProgressIfNeeded(state) {
    final now = DateTime.now();
    final lastUpdate = state.lastUpdate;
    final elapsed = now.difference(lastUpdate);

    // Only show if offline for more than 1 minute
    if (elapsed.inSeconds < 60) return;

    // Calculate cats that would have been earned
    final notifier = ref.read(gameProvider.notifier);
    final catsBefore = state.getResource(ResourceType.cats);

    // Apply offline progress
    notifier.applyOfflineProgress();

    final catsAfter = ref.read(gameProvider).getResource(ResourceType.cats);
    final catsEarned = catsAfter - catsBefore;

    if (catsEarned > 0) {
      showDialog(
        context: context,
        builder: (context) => OfflineProgressDialog(
          duration: elapsed,
          catsEarned: catsEarned,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }
}
