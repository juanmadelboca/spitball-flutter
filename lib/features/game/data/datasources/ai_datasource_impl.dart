import 'dart:math';
import 'package:spitball/features/game/data/datasources/ai_datasource.dart';

import '../../domain/entities/ball.dart';
import '../../domain/entities/tile.dart';

// Renamed and implemented as a concrete data source
class AiDataSourceImpl implements AiDataSource {
  static const int height = 5;
  static const int width = 9;

  @override
  List<int> calculateEasyMove(List<List<Tile>> tiles) {
    List<List<int>> possibleVectors = _getAIBalls(tiles);
    List<int> coordinates = [-1, -1, -1, -1, 0]; // Default to invalid move

    for (List<int> temp in possibleVectors) {
      int y = temp[0];
      int x = temp[1];
      Ball? aiBall = tiles[y][x].ball;
      if (aiBall == null) continue;

      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i == 0 && j == 0) continue; // Skip self

          int newY = y + i;
          int newX = x + j;

          if ((newY < height && newY >= 0) && (newX < width && newX >= 0)) {
            Ball? targetBall = tiles[newY][newX].ball;
            if (targetBall is BallGreen && targetBall.size <= aiBall.size) {
              // Found a valid target
              coordinates = [y, x, newY, newX, 0];
              // Easy move seems to take the first valid attack it finds (or last, depending on outer loop)
              // The Java code would overwrite, effectively taking the last one.
            }
          }
        }
      }
    }

    if (coordinates[0] == -1) {
      // If no valid attacking move was found
      // print("AI (Easy): No direct attack, performing random move.");
      return _randomMove(tiles);
    } else {
      // print("AI (Easy): Performing easy attack move.");
      return coordinates;
    }
  }

  @override
  List<int> calculateHardMove(List<List<Tile>> tiles, {required bool chaser}) {
    List<List<int>> aiBallPositions = _getAIBalls(tiles);

    for (List<int> pos in aiBallPositions) {
      int y = pos[0];
      int x = pos[1];
      Ball? aiBall = tiles[y][x].ball;
      if (aiBall == null) continue;

      // Try to move (attack adjacent)
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dy == 0 && dx == 0) continue; // Skip self

          int newY = y + dy;
          int newX = x + dx;

          if ((newY < height && newY >= 0) && (newX < width && newX >= 0)) {
            Ball? targetBall = tiles[newY][newX].ball;
            if (targetBall is BallGreen && targetBall.size <= aiBall.size) {
              // print("AI (Hard): Performing attack move.");
              return [y, x, newY, newX, 0]; // 0 for move
            }
          }
        }
      }

      // Try to split (attack 2 steps away, straight lines)
      // Deltas for 2 steps away: (0, +/-2) and (+/-2, 0)
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
          Ball? targetBall = tiles[targetY][targetX].ball;
          // In Java, split was (size / 3). Integer division in Dart is ~/
          if (targetBall is BallGreen && targetBall.size <= (aiBall.size ~/ 3) && aiBall.size >= 10) {
            // Min size for split? GameManager had >=10
            // print("AI (Hard): Performing split attack.");
            // Original Java returned y, x, deltaY, deltaX, -1.
            // Let's ensure the GameManger understands this delta format for splits.
            // Or, more consistently, return y, x, targetY, targetX, -1
            return [y, x, targetY, targetX, -1]; // -1 for split
          }
        }
      }
    }

    // If no attack/split found
    if (chaser) {
      // print("AI (Hard): No direct attack/split, performing chaser move.");
      return _chaserMove(tiles);
    } else {
      // print("AI (Hard): No direct attack/split, performing random move.");
      return _randomMove(tiles);
    }
  }

  // Returns a list: [yInitial, xInitial, yFinal, xFinal, moveType]
  // moveType: 0 for move, -1 for split (in hardMove), 1 for chaserMove's specific move.
  static List<int> _randomMove(List<List<Tile>> tiles) {
    List<int> coordinates;
    List<int> aiBallPos = _getAIRandomBall(tiles); // Using a helper that ensures AI ball
    Random random = Random();

    // Determine random direction (-1, 0, or 1 for y; -1, 0, or 1 for x, but not (0,0))
    int dy, dx;
    do {
      dx = random.nextInt(3) - 1; // -1, 0, or 1
      dy = random.nextInt(3) - 1; // -1, 0, or 1
    } while (dx == 0 && dy == 0); // Ensure it's not a move to the same spot

    int newY = aiBallPos[0] + dy;
    int newX = aiBallPos[1] + dx;

    if ((newY < height && newY >= 0) && (newX < width && newX >= 0)) {
      coordinates = [aiBallPos[0], aiBallPos[1], newY, newX, 0];
    } else {
      // Recursive call if out of bounds. Consider a max depth or alternative strategy.
      coordinates = _randomMove(tiles);
    }
    return coordinates;
  }

  // Helper to get a single random AI ball's position
  static List<int> _getAIRandomBall(List<List<Tile>> tiles) {
    List<List<int>> aiBalls = _getAIBalls(tiles);
    if (aiBalls.isEmpty) {
      // This should ideally not happen in a live game if AI has balls.
      // Return a dummy/error indicator or throw an exception.
      // For now, let's return a potentially invalid coordinate to avoid crash,
      // but this needs robust handling in GameManager.
      print("Error: AI has no balls to select for a random move.");
      return [-1, -1];
    }
    Random random = Random();
    int index = random.nextInt(aiBalls.length);
    return aiBalls[index];
  }

  static List<int> _getBiggestAIBall(List<List<Tile>> tiles) {
    List<List<int>> aiBalls = _getAIBalls(tiles);
    if (aiBalls.isEmpty) {
      print("Error: AI has no balls to select the biggest one.");
      return [-1, -1]; // Should be handled by caller
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

  static List<List<int>> _getAIBalls(List<List<Tile>> tiles) {
    List<List<int>> positions = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (tiles[i][j].ball is BallPink) {
          positions.add([i, j]);
        }
      }
    }
    return positions;
  }

  static List<List<int>> _getPlayerBalls(List<List<Tile>> tiles) {
    List<List<int>> positions = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (tiles[i][j].ball is BallGreen) {
          positions.add([i, j]);
        }
      }
    }
    return positions;
  }

  static List<int> _chaserMove(List<List<Tile>> tiles) {
    List<int> aiBiggestBallPos = _getBiggestAIBall(tiles);
    if (aiBiggestBallPos[0] == -1) return _randomMove(tiles); // No AI balls

    Ball? aiBall = tiles[aiBiggestBallPos[0]][aiBiggestBallPos[1]].ball;
    if (aiBall == null) return _randomMove(tiles);

    List<List<int>> playerBallPositions = _getPlayerBalls(tiles);
    if (playerBallPositions.isEmpty) {
      return _randomMove(tiles); // No player balls to chase
    }

    List<int>? targetPlayerBallPos;
    int minDistance = 1000; // Effectively infinity

    for (List<int> playerPos in playerBallPositions) {
      Ball? playerBall = tiles[playerPos[0]][playerPos[1]].ball;
      if (playerBall == null) continue;

      if (aiBall.size > playerBall.size) {
        // Only chase if AI ball is bigger
        int currentDistance = ((aiBiggestBallPos[0] - playerPos[0]).abs() + (aiBiggestBallPos[1] - playerPos[1]).abs());
        if (currentDistance < minDistance) {
          minDistance = currentDistance;
          targetPlayerBallPos = playerPos;
        }
      }
    }

    if (targetPlayerBallPos == null) {
      // No suitable player ball to chase (e.g., all are bigger or same size)
      return _randomMove(tiles);
    }

    // Move one step towards the targetPlayerBallPos
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
      // Same row, try to move horizontally
      finalX = currentX - 1;
    } else if (targetX > currentX) {
      finalX = currentX + 1;
    } else {
      // Already at the target (should not happen if distance > 0) or no clear single step
      return _randomMove(tiles);
    }

    // Ensure the single step is valid
    if ((finalY < height && finalY >= 0) && (finalX < width && finalX >= 0)) {
      return [currentY, currentX, finalY, finalX, 1]; // 1 for chaser move type
    } else {
      // Calculated step is out of bounds, fallback.
      return _randomMove(tiles);
    }
  }
}
