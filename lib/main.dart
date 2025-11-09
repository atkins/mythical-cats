import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mythical_cats/screens/home_screen.dart';
import 'package:mythical_cats/providers/game_provider.dart';

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

class GameLoader extends ConsumerWidget {
  const GameLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialState = ref.watch(initialGameStateProvider);

    return initialState.when(
      data: (state) {
        // Initialize game with loaded state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(gameProvider.notifier).loadState(state);
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
}
