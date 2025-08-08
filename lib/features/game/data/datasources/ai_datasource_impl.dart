import 'dart:math';
import 'package:spitball/features/game/domain/datasources/ai_datasource.dart';
import 'package:spitball/features/game/domain/entities/ball.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';

class AiDataSourceImpl implements AiDataSource {
  static const int height = 5;
  static const int width = 9;

  /// Calculates an "easy" difficulty move for the AI.
  ///
  /// This function implements a simple aggressive strategy. It iterates through all
  /// available AI balls and searches for any adjacent opponent ball that is weaker
  /// or of equal size. It will select the last valid attack it finds.
  ///
  /// If no direct attack is possible, it will fall back to making a completely
  /// random move by calling [_randomMove].
  ///
  /// ## Parameters:
  /// - `tiles`: The current 2D list of [TileEntity] objects representing the game board.
  ///
  /// ## Returns:
  /// A `List<int>` containing 5 elements that describe the move:
  /// `[yInitial, xInitial, yFinal, xFinal, moveType]`
  ///
  /// The `moveType` for a move is always `0`.
  @override
  List<int> calculateEasyMove(List<List<TileEntity>> tiles) {
    List<List<int>> possibleVectors = _getAIBalls(tiles);
    List<int> coordinates = [-1, -1, -1, -1, 0];

    for (List<int> temp in possibleVectors) {
      int y = temp[0];
      int x = temp[1];
      BallEntity? aiBall = tiles[y][x].ball;
      if (aiBall == null) continue;

      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i == 0 && j == 0) continue;

          int newY = y + i;
          int newX = x + j;

          if ((newY < height && newY >= 0) && (newX < width && newX >= 0)) {
            BallEntity? targetBall = tiles[newY][newX].ball;
            if (targetBall is BallGreenEntity && targetBall.size <= aiBall.size) {
              coordinates = [y, x, newY, newX, 0];
            }
          }
        }
      }
    }

    if (coordinates[0] == -1) {
      return _randomMove(tiles);
    } else {
      return coordinates;
    }
  }

  /// Calculates a "hard" difficulty move for the AI.
  ///
  /// This function implements a strategic search for the best possible move. It
  /// prioritizes direct attacks on weaker opponent balls. If no direct attack is
  /// found, it will attempt a "split" attack.
  ///
  /// If no aggressive moves are possible, its behavior depends on the [chaser]
  /// flag. If `true`, it will move its biggest ball towards the nearest weaker
  /// opponent ball. Otherwise, it will fall back to making a random move.
  ///
  /// ## Parameters:
  /// - `tiles`: The current 2D list of [Tile] objects representing the game board.
  /// - `chaser`: If `true`, the AI will perform a "chaser" move as a fallback.
  ///
  /// ## Returns:
  /// A `List<int>` containing 5 elements that describe the move:
  /// `[yInitial, xInitial, yFinal, xFinal, moveType]`
  ///
  /// The `moveType` can be:
  /// - `0`: A standard move.
  /// - `-1`: A split move.
  /// - `1`: A chaser move
  @override
  List<int> calculateHardMove(List<List<TileEntity>> tiles, {required bool chaser}) {
    List<List<int>> aiBallPositions = _getAIBalls(tiles);

    for (List<int> pos in aiBallPositions) {
      int y = pos[0];
      int x = pos[1];
      BallEntity? aiBall = tiles[y][x].ball;
      if (aiBall == null) continue;

      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dy == 0 && dx == 0) continue;

          int newY = y + dy;
          int newX = x + dx;

          if ((newY < height && newY >= 0) && (newX < width && newX >= 0)) {
            BallEntity? targetBall = tiles[newY][newX].ball;
            if (targetBall is BallGreenEntity && targetBall.size <= aiBall.size) {
              return [y, x, newY, newX, 0];
            }
          }
        }
      }
      List<List<int>> splitDeltas = [
        [0, 2],
        [0, -2],
        [2, 0],
        [-2, 0]
      ];
      for (List<int> deltaPair in splitDeltas) {
        int deltaY = deltaPair[0];
        int deltaX = deltaPair[1];

        int targetY = y + deltaY;
        int targetX = x + deltaX;

        if ((targetY < height && targetY >= 0) && (targetX < width && targetX >= 0)) {
          BallEntity? targetBall = tiles[targetY][targetX].ball;
          if (targetBall is BallGreenEntity && targetBall.size <= (aiBall.size ~/ 3) && aiBall.size >= 10) {
            return [y, x, targetY, targetX, -1];
          }
        }
      }
    }

    if (chaser) {
      return _chaserMove(tiles);
    } else {
      return _randomMove(tiles);
    }
  }

  /// Calculates a completely random move for a single AI ball.
  static List<int> _randomMove(List<List<TileEntity>> tiles) {
    List<int> coordinates;
    List<int> aiBallPos = _getAIRandomBall(tiles);
    Random random = Random();

    int dy, dx;
    do {
      dx = random.nextInt(3) - 1;
      dy = random.nextInt(3) - 1;
    } while (dx == 0 && dy == 0);

    int newY = aiBallPos[0] + dy;
    int newX = aiBallPos[1] + dx;

    if ((newY < height && newY >= 0) && (newX < width && newX >= 0)) {
      coordinates = [aiBallPos[0], aiBallPos[1], newY, newX, 0];
    } else {
      coordinates = _randomMove(tiles);
    }
    return coordinates;
  }

  /// Pick a random AI Ball
  static List<int> _getAIRandomBall(List<List<TileEntity>> tiles) {
    List<List<int>> aiBalls = _getAIBalls(tiles);
    if (aiBalls.isEmpty) {
      return [-1, -1];
    }
    Random random = Random();
    int index = random.nextInt(aiBalls.length);
    return aiBalls[index];
  }

  /// Pick the biggest AI Ball
  static List<int> _getBiggestAIBall(List<List<TileEntity>> tiles) {
    List<List<int>> aiBalls = _getAIBalls(tiles);
    if (aiBalls.isEmpty) {
      return [-1, -1];
    }

    List<int> biggestBallPos = aiBalls[0];
    int maxSize = tiles[aiBalls[0][0]][aiBalls[0][1]].ball?.size ?? 0;

    for (int i = 1; i < aiBalls.length; i++) {
      int currentSize = tiles[aiBalls[i][0]][aiBalls[i][1]].ball?.size ?? 0;
      if (currentSize > maxSize) {
        maxSize = currentSize;
        biggestBallPos = aiBalls[i];
      }
    }
    return biggestBallPos;
  }

  /// Return a List of all AI Balls positions
  static List<List<int>> _getAIBalls(List<List<TileEntity>> tiles) {
    List<List<int>> positions = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (tiles[i][j].ball is BallPinkEntity) {
          positions.add([i, j]);
        }
      }
    }
    return positions;
  }

  /// Return a List of all player Balls positions
  static List<List<int>> _getPlayerBalls(List<List<TileEntity>> tiles) {
    List<List<int>> positions = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (tiles[i][j].ball is BallGreenEntity) {
          positions.add([i, j]);
        }
      }
    }
    return positions;
  }

  /// Calculates a "chaser" move, where the AI's biggest ball moves toward the
  /// nearest weaker player ball.
  ///
  /// If no suitable target is found , this function will fall back to
  /// making a random move via [_randomMove].
  static List<int> _chaserMove(List<List<TileEntity>> tiles) {
    List<int> aiBiggestBallPos = _getBiggestAIBall(tiles);
    if (aiBiggestBallPos[0] == -1) return _randomMove(tiles);

    BallEntity? aiBall = tiles[aiBiggestBallPos[0]][aiBiggestBallPos[1]].ball;
    if (aiBall == null) return _randomMove(tiles);

    List<List<int>> playerBallPositions = _getPlayerBalls(tiles);
    if (playerBallPositions.isEmpty) {
      return _randomMove(tiles);
    }

    List<int>? targetPlayerBallPos;
    int minDistance = 1000;

    for (List<int> playerPos in playerBallPositions) {
      BallEntity? playerBall = tiles[playerPos[0]][playerPos[1]].ball;
      if (playerBall == null) continue;

      if (aiBall.size > playerBall.size) {
        int currentDistance = ((aiBiggestBallPos[0] - playerPos[0]).abs() + (aiBiggestBallPos[1] - playerPos[1]).abs());
        if (currentDistance < minDistance) {
          minDistance = currentDistance;
          targetPlayerBallPos = playerPos;
        }
      }
    }

    if (targetPlayerBallPos == null) {
      return _randomMove(tiles);
    }

    int currentY = aiBiggestBallPos[0];
    int currentX = aiBiggestBallPos[1];
    int targetY = targetPlayerBallPos[0];
    int targetX = targetPlayerBallPos[1];

    int finalY = currentY;
    int finalX = currentX;

    if (targetY < currentY) {
      finalY = currentY - 1;
    } else if (targetY > currentY) {
      finalY = currentY + 1;
    } else if (targetX < currentX) {
      finalX = currentX - 1;
    } else if (targetX > currentX) {
      finalX = currentX + 1;
    } else {
      return _randomMove(tiles);
    }

    if ((finalY < height && finalY >= 0) && (finalX < width && finalX >= 0)) {
      return [currentY, currentX, finalY, finalX, 1];
    } else {
      return _randomMove(tiles);
    }
  }
}
