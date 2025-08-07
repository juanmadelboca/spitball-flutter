import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spitball/features/game/domain/use_cases/handle_tap.dart';
import 'package:spitball/features/game/domain/use_cases/start_game.dart';
import 'package:spitball/features/game/presentation/providers/game_state.dart';

final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    startGame: StartGame(),
    handleTapUseCase: HandleTap(),
  );
});

class GameNotifier extends StateNotifier<GameState> {
  final StartGame startGame;
  final HandleTap handleTapUseCase;

  GameNotifier({
    required this.startGame,
    required this.handleTapUseCase,
  }) : super(GameState(tiles: [])) {
    state = startGame();
  }

  void handleTap(int row, int col) {
    state = handleTapUseCase(state, row, col);
  }
}
