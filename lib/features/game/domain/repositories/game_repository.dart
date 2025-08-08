// domain/repositories/game_repository.dart

// This is where you'd define your entities like Tile, Ball, etc.
import 'package:dartz/dartz.dart';
import 'package:spitball/core/error/failure.dart';
import 'package:spitball/features/game/domain/entities/board.dart';


abstract class GameRepository {
  // Initializes the game and returns the initial state
  Future<Either<Failure, BoardEntity>> initializeGame({required int aiLevel});

  // Handles a tap event and returns the new state of the game
  Future<Either<Failure, BoardEntity>> handleTap(int row, int col);

  // A stream that emits new game states when external events occur (AI move, opponent move)
  Stream<BoardEntity> get gameUpdates;

  // Cleans up resources like timers and streams
  void dispose();
}