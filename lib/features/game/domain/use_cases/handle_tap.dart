import 'package:spitball/features/game/domain/entities/ball.dart';
import 'package:spitball/features/game/domain/entities/ball_type.dart';
import 'package:spitball/features/game/presentation/providers/game_state.dart';

class HandleTap {
  GameState call(GameState state, int row, int col) {
    if (state.gameOver) {
      return state;
    }

    Ball? selectedBall = state.tiles[row][col].ball;

    if (state.clicks == 0) {
      if (selectedBall != null && selectedBall.size > 0) {
        bool isGreenPlayer = (state.playerTurn == 0);
        if ((isGreenPlayer && selectedBall is BallGreen) ||
            (!isGreenPlayer && selectedBall is BallPink)) {
          return state.copyWith(
            initialRow: row,
            initialCol: col,
            clicks: 1,
          );
        }
      }
    } else if (state.clicks == 1) {
      if (state.initialRow == row && state.initialCol == col) {
        return state.copyWith(clicks: 0);
      }

      int dy = (row - state.initialRow).abs();
      int dx = (col - state.initialCol).abs();

      try {
        if ((dx == 1 && dy == 0) || (dx == 0 && dy == 1) || (dx == 1 && dy == 1)) {
          return _performMove(state, state.initialRow, state.initialCol, row, col);
        } else if ((dx == 2 && dy == 0) || (dx == 0 && dy == 2)) {
          return _performSplit(state, state.initialRow, state.initialCol, row, col);
        }
      } catch (e) {
        print("Error during move/split: $e");
      } finally {
        return state.copyWith(clicks: 0);
      }
    }
    return state;
  }

  GameState _performMove(GameState state, int rInit, int cInit, int rFinal, int cFinal) {
    Ball? movingBall = state.tiles[rInit][cInit].ball;
    if (movingBall == null) return state;

    if (state.tiles[rFinal][cFinal].battle(movingBall, false)) {
      state.tiles[rInit][cInit].removeBall();
      return state.copyWith(playerTurn: (state.playerTurn + 1) % 2);
    }
    return state;
  }

  GameState _performSplit(GameState state, int rInit, int cInit, int rFinal, int cFinal) {
    Ball? originalBall = state.tiles[rInit][cInit].ball;
    if (originalBall == null || originalBall.size < 10) return state;

    int splitBallSize = originalBall.size ~/ 3;
    int finalSplitBallSize = (splitBallSize * 1.2).toInt();

    Ball newSplitBall = (originalBall is BallGreen)
        ? BallGreen(finalSplitBallSize)
        : BallPink(finalSplitBallSize);

    originalBall.size -= splitBallSize;

    if (state.tiles[rFinal][cFinal].battle(newSplitBall, false)) {
      return state.copyWith(playerTurn: (state.playerTurn + 1) % 2);
    } else {
      originalBall.size += splitBallSize;
    }
    return state;
  }
}
