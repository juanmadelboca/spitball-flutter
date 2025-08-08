import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:spitball/core/error/failure.dart';
import 'package:spitball/core/exceptions/game_exceptions.dart';

import 'package:spitball/features/game/domain/datasources/ai_datasource.dart';
import 'package:spitball/features/game/domain/entities/ball.dart';
import 'package:spitball/features/game/domain/entities/ball_type.dart';
import 'package:spitball/features/game/domain/entities/board.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';
import 'package:spitball/features/game/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  late List<List<TileEntity>> _tiles;
  int _clicks = 0;
  int _playerTurn = 0;
  int _initialRow = -1;
  int _initialCol = -1;
  bool _limitedMoveActive = false;

  // Game settings
  final bool _isAgainstAI = true;
  late int _difficulty;

  final _gameUpdateController = StreamController<BoardEntity>.broadcast();

  final AiDataSource _aiDataSource;

  GameRepositoryImpl({required AiDataSource aiDataSource}) : _aiDataSource = aiDataSource;

  @override
  Stream<BoardEntity> get gameUpdates => _gameUpdateController.stream;

  @override
  Future<Either<Failure, BoardEntity>> initializeGame({required int aiLevel}) async {
    _difficulty = aiLevel;
    _loadTiles();
    _initializeBoard();
    _playerTurn = 0;
    _clicks = 0;
    return Right(_createBoardEntity());
  }

  @override
  Future<Either<Failure, BoardEntity>> handleTap(int row, int col) async {
    try {
      BallEntity? selectedBall = _tiles[row][col].ball;

      if (_clicks == 0) {
        if (selectedBall != null && selectedBall.size > 0) {
          bool isGreenPlayer = (_playerTurn == 0);
          if ((isGreenPlayer && selectedBall is BallGreenEntity) || (!isGreenPlayer && selectedBall is BallPinkEntity)) {
            _initialRow = row;
            _initialCol = col;
            _clicks = 1;
          }
        }
      } else if (_clicks == 1) {
        _clicks = 0;

        if (_initialRow == row && _initialCol == col) {
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
              _triggerAIMove();
            }
          }
        }
      }
      return Right(_createBoardEntity());
    } on GameException catch (e) {
      return Left(GameFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  void dispose() {
    _gameUpdateController.close();
  }

  void _performMove(int rInit, int cInit, int rFinal, int cFinal) {
    BallEntity? movingBall = _tiles[rInit][cInit].ball;
    if (movingBall == null) throw const InvalidMoveException("No ball to move.");

    if (_tiles[rFinal][cFinal].battle(movingBall, _limitedMoveActive)) {
      _tiles[rInit][cInit].removeBall();
      _updateStatus();
    } else {
      throw const LimitMoveException("Move prevented by game rules.");
    }
  }

  void _performSplit(int rInit, int cInit, int rFinal, int cFinal) {
    BallEntity? originalBall = _tiles[rInit][cInit].ball;
    if (originalBall == null || originalBall.size < 10) {
      throw const UnderSizedSpitException("Ball is too small to split.");
    }

    int splitBallSize = (originalBall.size / 3).floor();
    int finalSplitBallSize = (splitBallSize * 1.2).toInt();

    BallEntity newSplitBall = (originalBall is BallGreenEntity) ? BallGreenEntity(finalSplitBallSize) : BallPinkEntity(finalSplitBallSize);

    originalBall.size -= splitBallSize;

    if (!_tiles[rFinal][cFinal].battle(newSplitBall, false)) {
      originalBall.size += splitBallSize; // Revert if battle fails
      throw const InvalidMoveException("Split part could not be placed.");
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

      if (_difficulty == 0) {
        aiMove = _aiDataSource.calculateEasyMove(_tiles);
      } else {
        aiMove = _aiDataSource.calculateHardMove(_tiles, chaser: _difficulty == 2);
      }
      int rInit = aiMove[0], cInit = aiMove[1], rFinal = aiMove[2], cFinal = aiMove[3];

      if (aiMove[4] != -1) {
        _performMove(rInit, cInit, rFinal, cFinal);
      } else {
        _performSplit(rInit, cInit, rFinal, cFinal);
      }
      _switchTurn();
    } catch (e) {
      _switchTurn();
    } finally {
      _gameUpdateController.add(_createBoardEntity());
    }
  }

  void _updateStatus() {
    int greenCount = 0;
    int pinkCount = 0;
    for (var row in _tiles) {
      for (var tile in row) {
        if (tile.ball is BallGreenEntity) greenCount++;
        if (tile.ball is BallPinkEntity) pinkCount++;
      }
    }
    _limitedMoveActive = (_playerTurn == 0 && greenCount <= 2) || (_playerTurn == 1 && pinkCount <= 2);
  }

  BoardEntity _createBoardEntity() {
    int greenCount = 0;
    int pinkCount = 0;
    for (var row in _tiles) {
      for (var tile in row) {
        if (tile.ball is BallGreenEntity) greenCount++;
        if (tile.ball is BallPinkEntity) pinkCount++;
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

  void _loadTiles() => _tiles = List.generate(5, (_) => List.generate(9, (_) => TileEntity()));

  void _initializeBoard() {
    _tiles[1][3].setBall(20, BallTypeEntity.ballGreen);
    _tiles[2][2].setBall(20, BallTypeEntity.ballGreen);
    _tiles[3][3].setBall(20, BallTypeEntity.ballGreen);
    _tiles[1][5].setBall(20, BallTypeEntity.ballPink);
    _tiles[2][6].setBall(20, BallTypeEntity.ballPink);
    _tiles[3][5].setBall(20, BallTypeEntity.ballPink);
  }
}
