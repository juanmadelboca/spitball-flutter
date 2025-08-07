import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spitball/features/game/presentation/providers/game_notifier.dart';
import 'package:spitball/features/menu/presentation/pages/menu.dart';
import '../widgets/board.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: BoardWidget(
            tiles: gameState.tiles,
            onTileTap: (row, col) {
              gameNotifier.handleTap(row, col);
            },
            selectedRow: gameState.initialRow,
            selectedCol: gameState.initialCol,
          ),
        ),
      ),
    );
  }
}
