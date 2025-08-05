import 'dart:async';
import 'dart:convert'; // For jsonEncode/jsonDecode

import '../../../models/tile.dart';
import '../../../models/ball.dart';
import '../../../models/ball_type.dart';
import '../ai/artificial_intelligence_algorithm.dart';
import '../../../common/exceptions/game_exceptions.dart';
import '../services/networking_service.dart'; // Will be created later

// Manages all game logic, state, and interactions.
// Equivalent to GameManager.java
class GameController {
  late List<List<Tile>> tiles;
  static const int boardWidth = 9;
  static const int boardHeight = 5;

  bool gameOver = false;
  int clicks = 0; // For tracking swipe/move selection steps
  int _playerTurn = 0; // 0 for Green, 1 for Pink

  // Online game related fields
  int gameId;
  int onlinePlayerColor; // 0 for Green, 1 for Pink (player's color in this online session)
  late bool isOnlineGame;

  // AI related fields
  int difficulty;
  bool isAgainstAI;

  // Click tracking for moves
  int initialRow = -1, initialCol = -1;

  // Flags
  bool _onlineMoveInProgress = false; // To prevent sending moves while processing an online move
  bool _isMyTurn = true;
  bool playerHasMadeMoveThisTurn = false;
  bool _anyMoveFlag = false; // To signal UI that a move happened (used by anyMove() getter)
  bool limitedMoveActive = false; // True if player has few balls, restricting some moves

  int greenBallCount = 0;
  int pinkBallCount = 0;

  bool _finishOnlineGameSignal = false; // When local player wants to end online game

  Timer? _onlinePollingTimer;
  NetworkingService _networkingService; // To be injected or instantiated

  // Constructor
  GameController({
    this.gameId = 0, // 0 means local game
    this.difficulty = 0, // Default easy
    this.onlinePlayerColor = 0, // Default to Green if online
    this.isAgainstAI = true, // Default to playing against AI
    required NetworkingService networkingService, // Make it required
  }) : _networkingService = networkingService {
    isOnlineGame = (gameId != 0);
    _loadTiles();
    _initializeBoard();

    if (isOnlineGame) {
      _playerTurn = 0; // Game always starts with player 0 (Green)
      _isMyTurn = (onlinePlayerColor == _playerTurn);
      _startOnlineGameSetup();
      _startOnlinePolling();
    } else {
      _isMyTurn = true; // Always player's turn in local/AI game initially
    }
  }

  void _loadTiles() {
    tiles = List.generate(
        boardHeight,
        (_) => List.generate(boardWidth, (_) => Tile()),
    );
  }

  void _initializeBoard() {
    // Standard starting positions (y, x) or (row, col)
    // Green balls
    tiles[1][3].setBall(20, BallType.ballGreen);
    tiles[2][2].setBall(20, BallType.ballGreen);
    tiles[3][3].setBall(20, BallType.ballGreen);
    // Pink balls
    tiles[1][5].setBall(20, BallType.ballPink);
    tiles[2][6].setBall(20, BallType.ballPink);
    tiles[3][5].setBall(20, BallType.ballPink);
    updateStatus(); // Initial count
  }

  Future<void> _startOnlineGameSetup() async {
    if (!isOnlineGame) return;
    try {
      // Send a dummy move to ensure game log exists on server for player 2 joining.
      // Turn is 1 for this dummy move as per original Java code, seems like a specific server handshake.
      await _networkingService.sendMove(gameId, 0, 0, 0, 0, 0, 1);
    } catch (e) {
      print("Error during online game setup send: $e");
    }
    // Original Java code adjusted playerTurn and isMyTurn based on onlineTurn.
    // Here, onlinePlayerColor defines this client's color.
    // Player 0 (Green) always starts.
    _playerTurn = 0;
    _isMyTurn = (onlinePlayerColor == _playerTurn);
  }

  void _startOnlinePolling() {
    if (!isOnlineGame) return;
    _onlinePollingTimer?.cancel(); // Cancel existing timer if any
    _onlinePollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (gameOver || _finishOnlineGameSignal) {
        timer.cancel();
        return;
      }

      if (!_isMyTurn && !_onlineMoveInProgress) {
        try {
          Map<String, dynamic>? moveData = await _networkingService.getOnlineMove(gameId);
          if (moveData != null) {
            // Check if it's actually opponent's move and not our own echo
            int moveTurn = moveData['TURN'] as int;
            if (moveTurn != onlinePlayerColor && moveTurn != -1) { // -1 signals game end by opponent
              _processOpponentMove(moveData);
            } else if (moveTurn == -1) {
              print("Opponent signaled game end.");
              gameOver = true;
              _finishOnlineGameSignal = true; // Ensure local state reflects this
              // Potentially notify UI here
            }
          }
        } catch (e) {
          print("Error polling for online move: $e");
        }
      }
      // Turn timeout logic (Java GameManager had this)
      // Simplified: If it's player's turn and no move for X seconds, auto-pass or warn.
      // For now, this is handled by playerHasMadeMoveThisTurn flag for turn switching.
    });
  }

  void _processOpponentMove(Map<String, dynamic> moveData) {
    _onlineMoveInProgress = true;
    try {
      int rInit = moveData['YINIT'] as int; // Java YINIT is row
      int cInit = moveData['XINIT'] as int; // Java XINIT is col
      int rFinal = moveData['YLAST'] as int;
      int cFinal = moveData['XLAST'] as int;
      int splitType = moveData['SPLIT'] as int; // 0 for move, 1 for split

      if (splitType == 0) { // Move
        _performMove(rInit, cInit, rFinal, cFinal, isOpponentMove: true);
      } else { // Split
        _performSplit(rInit, cInit, rFinal, cFinal, isOpponentMove: true);
      }
      playerHasMadeMoveThisTurn = true; // Opponent made their move
      _switchTurn();
    } catch (e) {
      print("Error processing opponent's move: $e");
      if (e is InvalidMoveException || e is LimitMoveException || e is UnderSizedSpitException) {
        // Log and continue, opponent made an invalid move based on our current state.
        // This might indicate a desync or a bug.
      }
    } finally {
      _onlineMoveInProgress = false;
    }
  }


  // Public method for UI to call when a tile is tapped
  // (y, x) are row and column indices
  bool handleTap(int row, int col) {
    if (gameOver || (isOnlineGame && !_isMyTurn)) {
      return false; // Game over or not player's turn
    }

    Ball? selectedBall = tiles[row][col].ball;

    if (clicks == 0) {
      if (selectedBall != null && selectedBall.size > 0) {
        // Check if the ball belongs to the current player
        bool isGreenPlayer = (_playerTurn == 0);
        if ((isGreenPlayer && selectedBall is BallGreen) || (!isGreenPlayer && selectedBall is BallPink)) {
          initialRow = row;
          initialCol = col;
          clicks = 1;
          _anyMoveFlag = true; // Indicate selection happened, for UI feedback
          print("Selected ball at ($row, $col)");
          return true; // Ball selected
        }
      }
      return false; // No valid ball for current player or empty tile
    } else if (clicks == 1) {
      if (initialRow == row && initialCol == col) { // Tap same ball to deselect
        clicks = 0;
        _anyMoveFlag = true;
        print("Deselected ball at ($row, $col)");
        return false;
      }

      // Calculate distance for move/split
      int dy = (row - initialRow).abs();
      int dx = (col - initialCol).abs();

      bool success = false;
      try {
        if ((dx == 1 && dy == 0) || (dx == 0 && dy == 1) || (dx == 1 && dy == 1)) { // Adjacent or diagonal by 1
          print("Attempting move from ($initialRow, $initialCol) to ($row, $col)");
          _performMove(initialRow, initialCol, row, col);
          success = true;
        } else if ((dx == 2 && dy == 0) || (dx == 0 && dy == 2)) { // Straight line 2 steps away
          print("Attempting split from ($initialRow, $initialCol) to ($row, $col)");
          _performSplit(initialRow, initialCol, row, col);
          success = true;
        } else {
           print("Invalid move/split distance from ($initialRow, $initialCol) to ($row, $col). dx: $dx, dy: $dy");
          _anyMoveFlag = true; // To reset UI if it was highlighting something
        }
      } catch (e) {
        print("Error during move/split: $e");
        // UI should show error based on exception type
        _anyMoveFlag = true; // Reset selection
        success = false; // Explicitly false on error
      } finally {
        clicks = 0; // Reset clicks after an attempt
      }

      if (success) {
        playerHasMadeMoveThisTurn = true;
        if (!isOnlineGame) { // Local game (vs AI or another local player)
          _switchTurn();
          if (isAgainstAI && _playerTurn == 1 && !gameOver) { // AI is Pink (player 1)
             _triggerAIMove();
          }
        } else { // Online game: after sending move, wait for server/opponent
            _isMyTurn = false; // Set to false immediately, server will confirm via polling
            // _startOnlinePolling(); // Ensure polling is active
        }
      }
      return success;
    }
    return false; // Should not reach here
  }

  void _performMove(int rInit, int cInit, int rFinal, int cFinal, {bool isOpponentMove = false}) {
    if (!isOpponentMove && isOnlineGame && !_isMyTurn) {
      throw InvalidMoveException("Not your turn (online game).");
    }

    Ball? movingBall = tiles[rInit][cInit].ball;
    if (movingBall == null || movingBall.size == 0) {
      throw InvalidMoveException("No ball to move from ($rInit, $cInit).");
    }

    // Check current player's turn for local moves
    if (!isOpponentMove && !isOnlineGame) {
        bool isGreenPlayer = (_playerTurn == 0);
        if (!((isGreenPlayer && movingBall is BallGreen) || (!isGreenPlayer && movingBall is BallPink))) {
            throw InvalidMoveException("Not your ball to move.");
        }
    }


    if (tiles[rFinal][cFinal].battle(movingBall, limitedMoveActive)) {
      tiles[rInit][cInit].removeBall();
      _anyMoveFlag = true;
      updateStatus();
      if (isOnlineGame && !isOpponentMove) {
        _networkingService.sendMove(gameId, rInit, cInit, rFinal, cFinal, 0, onlinePlayerColor)
            .catchError((e) => print("Error sending move: $e"));
      }
    } else {
      // Battle failed (e.g., due to limitedMoveActive)
      throw LimitMoveException("Move prevented by limited move condition or battle rules.");
    }
  }

  void _performSplit(int rInit, int cInit, int rFinal, int cFinal, {bool isOpponentMove = false}) {
     if (!isOpponentMove && isOnlineGame && !_isMyTurn) {
      throw InvalidMoveException("Not your turn (online game).");
    }

    Ball? originalBall = tiles[rInit][cInit].ball;
    if (originalBall == null || originalBall.size < 10) { // Min size from Java
      throw UnderSizedSpitException("Ball at ($rInit, $cInit) is too small to split (size: ${originalBall?.size ?? 0}).");
    }

    // Check current player's turn for local moves
    if (!isOpponentMove && !isOnlineGame) {
        bool isGreenPlayer = (_playerTurn == 0);
        if (!((isGreenPlayer && originalBall is BallGreen) || (!isGreenPlayer && originalBall is BallPink))) {
            throw InvalidMoveException("Not your ball to split.");
        }
    }

    int splitBallSize = originalBall.size ~/ 3; // Integer division
    if (splitBallSize == 0 && originalBall.size >=10 ) splitBallSize = 1; // Ensure at least 1 if possible

    // Apply 1.2 multiplier like in Java, then ensure it's an int
    int finalSplitBallSize = (splitBallSize * 1.2).toInt();
    if (finalSplitBallSize == 0 && splitBallSize > 0) finalSplitBallSize = 1;


    Ball newSplitBall;
    if (originalBall is BallGreen) {
      newSplitBall = BallGreen(finalSplitBallSize);
    } else {
      newSplitBall = BallPink(finalSplitBallSize);
    }

    originalBall.size -= splitBallSize; // Reduce original ball's size (not the 1.2x part)
    if(originalBall.size < 0) originalBall.size = 0;


    if (tiles[rFinal][cFinal].battle(newSplitBall, false)) { // limitedMove is false for splits
      _anyMoveFlag = true;
      updateStatus();
      if (isOnlineGame && !isOpponentMove) {
        _networkingService.sendMove(gameId, rInit, cInit, rFinal, cFinal, 1, onlinePlayerColor)
            .catchError((e) => print("Error sending split: $e"));
      }
    } else {
      // This case should be rare if battle logic is sound, means split part couldn't be placed.
      // Restore original ball size as split effectively failed.
      originalBall.size += splitBallSize;
      throw InvalidMoveException("Split part could not be placed at ($rFinal, $cFinal).");
    }
  }

  void _triggerAIMove() {
    if (gameOver) return;
    print("AI's turn (Difficulty: $difficulty)");

    List<int> aiMoveCoords;
    // The AI algorithm expects List<List<Tile>>
    // It returns [yInitial, xInitial, yFinal, xFinal, type]
    // type: 0 for move, -1 for split, 1 for chaser move

    // Ensure AI doesn't get stuck in recursive calls due to its own invalid moves
    try {
      switch (difficulty) {
        case 0: // Easy
          aiMoveCoords = ArtificialIntelligenceAlgorithm.easyMove(tiles);
          break;
        case 1: // Hard (no chaser) - original Java code had hardMove(tiles, false)
          aiMoveCoords = ArtificialIntelligenceAlgorithm.hardMove(tiles, false);
          break;
        case 2: // Hard (chaser) - original Java code had hardMove(tiles, true)
          aiMoveCoords = ArtificialIntelligenceAlgorithm.hardMove(tiles, true);
          break;
        default:
          aiMoveCoords = ArtificialIntelligenceAlgorithm.easyMove(tiles);
      }

      int rInit = aiMoveCoords[0];
      int cInit = aiMoveCoords[1];
      int rFinal = aiMoveCoords[2];
      int cFinal = aiMoveCoords[3];
      int moveType = aiMoveCoords[4];

      if (rInit == -1) { // AI algorithm indicated no move found
          print("AI found no valid move, passing turn.");
      } else if (moveType == 0 || moveType == 1) { // Standard move or chaser move
        print("AI performing move: ($rInit, $cInit) -> ($rFinal, $cFinal)");
        _performMove(rInit, cInit, rFinal, cFinal, isOpponentMove: true); // AI is effectively an opponent
      } else if (moveType == -1) { // Split
        // AI's hardMove for split returns target coordinates directly.
        print("AI performing split: ($rInit, $cInit) -> ($rFinal, $cFinal)");
        _performSplit(rInit, cInit, rFinal, cFinal, isOpponentMove: true); // AI is effectively an opponent
      }
    } catch (e) {
      print("AI Error: $e. AI attempting random fallback move.");
      // Fallback to a random move if AI logic fails catastrophically
      try {
        aiMoveCoords = ArtificialIntelligenceAlgorithm.randomMove(tiles);
        _performMove(aiMoveCoords[0], aiMoveCoords[1], aiMoveCoords[2], aiMoveCoords[3], isOpponentMove: true);
      } catch (e2) {
        print("AI Random Fallback Error: $e2. AI forfeits turn.");
      }
    } finally {
      playerHasMadeMoveThisTurn = true; // AI made its move
      _switchTurn(); // Switch back to player or end game
    }
  }

  void _switchTurn() {
    if (!isOnlineGame) {
      _playerTurn = (_playerTurn + 1) % 2;
    } else {
      // Online turn switching is more complex. Server implicitly dictates via getOnlineMove.
      // Local _isMyTurn flag is key.
      _playerTurn = (_playerTurn + 1) % 2; // Still track theoretical turn for display
      _isMyTurn = (onlinePlayerColor == _playerTurn && !_finishOnlineGameSignal && !gameOver);
    }
    playerHasMadeMoveThisTurn = false;
    updateStatus(); // Recalculate ball counts and game over status
    print("Turn switched. Current player: $_playerTurn. Is my turn (online): $_isMyTurn");
    if (gameOver) {
        print("Game Over! Green: $greenBallCount, Pink: $pinkBallCount");
        if (isOnlineGame) _onlinePollingTimer?.cancel();
    }
  }

  void updateStatus() {
    greenBallCount = 0;
    pinkBallCount = 0;
    for (int i = 0; i < boardHeight; i++) {
      for (int j = 0; j < boardWidth; j++) {
        Ball? ball = tiles[i][j].ball;
        if (ball is BallGreen) {
          greenBallCount++;
        } else if (ball is BallPink) {
          pinkBallCount++;
        }
      }
    }

    // Limited move rule from Java:
    // if((playerTurn == 1 && pinkBalls <= 2 && isMyTurn) || (playerTurn == 0 && greenBalls <= 2 && isMyTurn)
    //    ||(playerTurn == 1 && pinkBalls <= 2 && GameId == 0) || (playerTurn == 0 && greenBalls <= 2 && GameId == 0)){
    //    limitedMove = true;
    // }
    // Simplified: if current player has <= 2 balls of their color.
    if (_playerTurn == 0 && greenBallCount <= 2) { // Green's turn
        limitedMoveActive = true;
    } else if (_playerTurn == 1 && pinkBallCount <= 2) { // Pink's turn
        limitedMoveActive = true;
    } else {
        limitedMoveActive = false;
    }

    if (!gameOver && (pinkBallCount == 0 || greenBallCount == 0) && (greenBallCount + pinkBallCount > 0) /*Ensure not start of game*/) {
      gameOver = true;
      if (isOnlineGame) {
        _onlinePollingTimer?.cancel();
        // Optionally send a final game state or signal if needed, though server might determine winner
      }
    }
    _anyMoveFlag = true; // Signal UI to refresh
  }

  // Getters for UI
  bool get isGameOver => gameOver;
  int get currentPlayerTurn => _playerTurn; // 0 for Green, 1 for Pink
  bool get isCurrentPlayersTurnOnline => isOnlineGame && _isMyTurn;
  bool get anyMoveOccurred {
    bool temp = _anyMoveFlag;
    _anyMoveFlag = false; // Reset after check
    return temp;
  }

  void setFinishOnlineGame() {
      if (isOnlineGame && !_finishOnlineGameSignal) {
          _finishOnlineGameSignal = true;
          // Send a special move to server to indicate leaving/conceding
          _networkingService.sendMove(gameId, 0,0,0,0,0, -1) // -1 turn signals leaving
              .then((_) => print("Sent finish game signal to server."))
              .catchError((e) => print("Error sending finish game signal: $e"));
          gameOver = true; // Assume game ends locally too
          _onlinePollingTimer?.cancel();
          // Notify UI or trigger navigation
      }
  }

  void dispose() {
    _onlinePollingTimer?.cancel();
  }
}
