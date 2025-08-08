// lib/features/game/data/repositories/game_repository_impl.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:spitball/features/game/data/datasources/ai_datasource.dart';

// Core
import '../../../../core/error/failure.dart';
import '../../domain/entities/board.dart';
// Domain

import '../../../../core/exceptions/game_exceptions.dart';
import '../../domain/entities/ball.dart';
import '../../domain/entities/ball_type.dart';
import '../../domain/entities/tile.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  late List<List<Tile>> _tiles;
  int _clicks = 0;
  int _playerTurn = 0; // 0 for Green, 1 for Pink
  int _initialRow = -1;
  int _initialCol = -1;
  bool _limitedMoveActive = false;

  // Game settings
  final bool _isAgainstAI = true; // Hardcoded for this example
  late int _difficulty; // 0:easy, 1:hard, 2:hard+chaser

  // StreamController to push updates from AI moves
  final _gameUpdateController = StreamController<BoardEntity>.broadcast();

  final AiDataSource _aiDataSource;

  // Constructor can now accept the AI data source
  GameRepositoryImpl({required AiDataSource aiDataSource}) : _aiDataSource = aiDataSource;

  @override
  Stream<BoardEntity> get gameUpdates => _gameUpdateController.stream;

  // Updated method signature
  @override
  Future<Either<Failure, BoardEntity>> initializeGame({required int aiLevel}) async {
    _difficulty = aiLevel; // Store the difficulty level
    _loadTiles();
    _initializeBoard();
    _playerTurn = 0;
    _clicks = 0;
    return Right(_createBoardEntity());
  }

  @override
  Future<Either<Failure, BoardEntity>> handleTap(int row, int col) async {
    try {
      // --- This is the logic from your handleTap method ---
      Ball? selectedBall = _tiles[row][col].ball;

      if (_clicks == 0) {
        if (selectedBall != null && selectedBall.size > 0) {
          bool isGreenPlayer = (_playerTurn == 0);
          if ((isGreenPlayer && selectedBall is BallGreen) || (!isGreenPlayer && selectedBall is BallPink)) {
            _initialRow = row;
            _initialCol = col;
            _clicks = 1;
          }
        }
      } else if (_clicks == 1) {
        // Reset clicks immediately for the next action
        _clicks = 0;

        if (_initialRow == row && _initialCol == col) {
          // Deselect
          // Do nothing, just return the updated state with no selection
        } else {
          int dy = (row - _initialRow).abs();
          int dx = (col - _initialCol).abs();

          bool success = false;
          if ((dx == 1 && dy == 0) || (dx == 0 && dy == 1) || (dx == 1 && dy == 1)) {
            _performMove(_initialRow, _initialCol, row, col);
            success = true;
          } else if ((dx == 2 && dy == 0) || (dx == 0 && dy == 2)) {
            _performSplit(_initialRow, _initialCol, row, col);
            success = true;
          }

          if (success) {
            _switchTurn();
            if (_isAgainstAI && _playerTurn == 1) {
              // Trigger AI move asynchronously. It will push its result to the stream.
              _triggerAIMove();
            }
          }
        }
      }
      return Right(_createBoardEntity());
    } on GameException catch (e) {
      // Catch specific game exceptions and return them as Failures
      return Left(GameFailure(e.message));
    } catch (e) {
      // Catch any other unexpected errors
      return Left(GenericFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  void dispose() {
    _gameUpdateController.close();
  }

  // --- Private Helper Methods (The Core Logic) ---

  void _performMove(int rInit, int cInit, int rFinal, int cFinal) {
    Ball? movingBall = _tiles[rInit][cInit].ball;
    if (movingBall == null) throw InvalidMoveException("No ball to move.");

    if (_tiles[rFinal][cFinal].battle(movingBall, _limitedMoveActive)) {
      _tiles[rInit][cInit].removeBall();
      _updateStatus();
    } else {
      throw LimitMoveException("Move prevented by game rules.");
    }
  }

  void _performSplit(int rInit, int cInit, int rFinal, int cFinal) {
    Ball? originalBall = _tiles[rInit][cInit].ball;
    if (originalBall == null || originalBall.size < 10) {
      throw UnderSizedSpitException("Ball is too small to split.");
    }

    int splitBallSize = (originalBall.size / 3).floor();
    int finalSplitBallSize = (splitBallSize * 1.2).toInt();

    Ball newSplitBall = (originalBall is BallGreen) ? BallGreen(finalSplitBallSize) : BallPink(finalSplitBallSize);

    originalBall.size -= splitBallSize;

    if (!_tiles[rFinal][cFinal].battle(newSplitBall, false)) {
      originalBall.size += splitBallSize; // Revert if battle fails
      throw InvalidMoveException("Split part could not be placed.");
    }
    _updateStatus();
  }

  void _switchTurn() {
    _playerTurn = (_playerTurn + 1) % 2;
    _updateStatus();
  }

  void _triggerAIMove() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      List<int> aiMove;
      // Use the stored _difficulty to select the correct AI algorithm

      if (_difficulty == 0) {
        aiMove = _aiDataSource.calculateEasyMove(_tiles);
      } else {
        aiMove = _aiDataSource.calculateHardMove(_tiles, chaser: _difficulty == 2);
      }
      int rInit = aiMove[0], cInit = aiMove[1], rFinal = aiMove[2], cFinal = aiMove[3];

      if (aiMove[4] != -1) {
        // Move
        _performMove(rInit, cInit, rFinal, cFinal);
      } else {
        // Split
        _performSplit(rInit, cInit, rFinal, cFinal);
      }
      _switchTurn();
    } catch (e) {
      print("AI Error: $e. AI forfeits turn.");
      _switchTurn(); // Switch back to player even if AI fails
    } finally {
      // IMPORTANT: Push the new state to the stream for the UI to update
      _gameUpdateController.add(_createBoardEntity());
    }
  }

  void _updateStatus() {
    int greenCount = 0;
    int pinkCount = 0;
    for (var row in _tiles) {
      for (var tile in row) {
        if (tile.ball is BallGreen) greenCount++;
        if (tile.ball is BallPink) pinkCount++;
      }
    }
    _limitedMoveActive = (_playerTurn == 0 && greenCount <= 2) || (_playerTurn == 1 && pinkCount <= 2);
  }

  BoardEntity _createBoardEntity() {
    int greenCount = 0;
    int pinkCount = 0;
    for (var row in _tiles) {
      for (var tile in row) {
        if (tile.ball is BallGreen) greenCount++;
        if (tile.ball is BallPink) pinkCount++;
      }
    }

    bool hasGameStarted = (greenCount + pinkCount) > 0;
    if (hasGameStarted && (greenCount == 0 || pinkCount == 0)) {
      return BoardEntity(tiles: _tiles, currentPlayer: _playerTurn, isGameOver: true, winner: greenCount == 0 ? "Pink" : "Green");
    }

    return BoardEntity(
      tiles: _tiles,
      currentPlayer: _playerTurn,
      selectedRow: _clicks == 1 ? _initialRow : null,
      selectedCol: _clicks == 1 ? _initialCol : null,
    );
  }

  // --- Initial Board Setup ---
  void _loadTiles() => _tiles = List.generate(5, (_) => List.generate(9, (_) => Tile()));

  void _initializeBoard() {
    _tiles[1][3].setBall(20, BallType.ballGreen);
    _tiles[2][2].setBall(20, BallType.ballGreen);
    _tiles[3][3].setBall(20, BallType.ballGreen);
    _tiles[1][5].setBall(20, BallType.ballPink);
    _tiles[2][6].setBall(20, BallType.ballPink);
    _tiles[3][5].setBall(20, BallType.ballPink);
  }
}
