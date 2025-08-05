import 'ball.dart';
import 'ball_type.dart';

// Represents a single tile on the game board.
// It can hold a ball and manages battle logic when a new ball enters.
class Tile {

  // A tile is initially empty (represented by a Ball of size 0).
  // Note: In Dart, there's no direct equivalent of an anonymous Ball(0) instance
  // without a concrete type. We'll need a way to represent an "empty" or "neutral" ball state.
  // For now, let's make BallPink the default for size 0, or consider a specific EmptyBall class later.
  // Or, make _ball nullable. Let's try nullable for better representation of emptiness.
  Ball? _ball;

  Tile() {
    // Initialize with no ball (null)
    _ball = null;
  }

  // Gets the current ball on the tile. Can be null if empty.
  Ball? get ball => _ball;

  // Places a new ball of a specific type and size on the tile.
  void setBall(int size, BallType type) {
    switch (type) {
      case BallType.ballGreen:
        _ball = BallGreen(size);
        break;
      case BallType.ballPink:
        _ball = BallPink(size);
        break;
    }
  }

  // Removes the ball from the tile, making it empty.
  void removeBall() {
    _ball = null;
  }

  // Handles the interaction when an immigrantBall tries to occupy this tile.
  // Returns true if the move/battle was successful, false otherwise.
  // limitedMove: A game rule that might prevent same-type balls from merging if a player has few balls.
  bool battle(Ball immigrantBall, bool limitedMove) {
    // If the tile is empty, the immigrant ball simply occupies it.
    if (_ball == null || _ball!.size == 0) {
      _ball = immigrantBall;
      return true;
    }

    // Current ball on the tile
    Ball currentBall = _ball!;

    // Check for limited move condition: same type and limitedMove is true
    bool isImmigrantGreen = immigrantBall is BallGreen;
    bool isCurrentGreen = currentBall is BallGreen;
    bool isImmigrantPink = immigrantBall is BallPink;
    bool isCurrentPink = currentBall is BallPink;

    if (limitedMove && ((isImmigrantGreen && isCurrentGreen) || (isImmigrantPink && isCurrentPink))) {
      // In Java: Log.i("GAME", "You have too little balls to perform that move.");
      print("GAME: You have too few balls to perform that move due to limited move rule.");
      return false;
    }

    // Battle logic
    if (immigrantBall.size >= currentBall.size) {
      int newSize = currentBall.size + immigrantBall.size;
      // The immigrant ball's type determines the new ball type on the tile.
      if (isImmigrantGreen) {
        _ball = BallGreen(newSize);
      } else { // It must be BallPink
        _ball = BallPink(newSize);
      }
    } else {
      // The current ball on the tile absorbs the immigrant ball.
      currentBall.size += immigrantBall.size;
      // _ball remains the same type, just with increased size (already handled by modifying currentBall.size)
    }
    return true;
  }
}
