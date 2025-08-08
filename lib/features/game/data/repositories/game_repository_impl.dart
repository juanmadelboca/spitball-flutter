import 'dart:async';
import 'package:spitball/features/game/domain/entities/ball.dart';
import 'package:spitball/features/game/domain/entities/ball_type.dart';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/tile.dart';

// This class now encapsulates the logic from your old GameController
class GameRepositoryImpl implements GameRepository {
  late List<List<Tile>> _tiles;
  int _clicks = 0;
  int _playerTurn = 0; // 0 for Green, 1 for Pink
  int _initialRow = -1, _initialCol = -1;

  // ... and all other fields from GameController

  // StreamController to push updates from AI or network
  final _gameUpdateController = StreamController<GameState>.broadcast();
  Timer? _pollingTimer;

  @override
  Stream<GameState> get gameUpdates => _gameUpdateController.stream;

  GameRepositoryImpl() {
    // You would inject NetworkingService, AIAlgorithm etc. here
  }

  @override
  GameState initializeGame() {
    // All the logic from your GameController constructor and _initializeBoard
    _tiles = List.generate(5, (_) => List.generate(9, (_) => Tile()));
    //TODO: entities ONLY FOR domain
    _tiles[1][3].setBall(20, BallType.ballGreen);
    _tiles[2][2].setBall(20, BallType.ballGreen);
    _tiles[3][3].setBall(20, BallType.ballGreen);
    _tiles[1][5].setBall(20, BallType.ballPink);
    _tiles[2][6].setBall(20, BallType.ballPink);
    _tiles[3][5].setBall(20, BallType.ballPink);

    _playerTurn = 0;
    _clicks = 0;

    // Start polling for AI/network moves if needed
    // _startPolling();

    return _createState();
  }

  @override
  GameState handleTap(int row, int col) {
    // --- THIS IS THE LOGIC FROM YOUR GameController.handleTap() ---
    // Instead of returning 'bool' and calling setState, it now returns a new GameState
    // based on the result of the tap.
    // ...
    // ... [The entire logic of handleTap, _performMove, _performSplit]
    // ...

    // After a successful move, you might trigger an AI move
    // if (/* move was successful and it's AI's turn */) {
    // _triggerAIMove(); // This method will eventually add a new state to the _gameUpdateController
    // }

    // At the end of every action, create and return the new state
    return _createState();
  }

  GameState _createState() {
    // --- First, count the balls ---
    int greenCount = 0;
    int pinkCount = 0;
    for (var row in _tiles) {
      for (var tile in row) {
        if (tile.ball is BallGreen) {
          greenCount++;
        } else if (tile.ball is BallPink) {
          pinkCount++;
        }
      }
    }

    // --- THE FIX IS HERE ---
    // Only check for a winner if the game has actually started (i.e., there are balls on the board).
    bool hasGameStarted = (greenCount + pinkCount) > 0;
    if (hasGameStarted && (greenCount == 0 || pinkCount == 0)) {
      return GameOver(
        winner: greenCount == 0 ? "Pink" : "Green",
        greenBallCount: greenCount,
        pinkBallCount: pinkCount,
      );
    }

    // --- If not game over, return the InProgress state ---
    return GameInProgress(
      board: _tiles,
      currentPlayer: _playerTurn,
      isMyTurn: true,
      // This should be calculated based on game mode
      selectedRow: _clicks == 1 ? _initialRow : null,
      selectedCol: _clicks == 1 ? _initialCol : null,
    );
  }

  // The polling/AI logic now adds to the stream instead of relying on a UI timer
  void _triggerAIMove() {
    // ... AI logic calculates move ...
    // After AI move is performed and state is updated internally...
    _gameUpdateController.add(_createState());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _gameUpdateController.close();
  }
}
