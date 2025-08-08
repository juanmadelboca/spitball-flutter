// domain/repositories/game_repository.dart

// This is where you'd define your entities like Tile, Ball, etc.
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

import '../entities/tile.dart';

abstract class GameRepository {
  // Initializes the game and returns the initial state
  GameState initializeGame();

  // Handles a tap event and returns the new state of the game
  GameState handleTap(int row, int col);

  // A stream that emits new game states when external events occur (AI move, opponent move)
  Stream<GameState> get gameUpdates;

  // Cleans up resources like timers and streams
  void dispose();
}