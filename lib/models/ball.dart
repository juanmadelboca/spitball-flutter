// Represents a ball in the game.

// Abstract base class for a ball.
abstract class Ball {
  int size;

  Ball(this.size);
}

// Represents a green ball.
class BallGreen extends Ball {
  BallGreen(int size) : super(size);
}

// Represents a pink ball.
class BallPink extends Ball {
  BallPink(int size) : super(size);
}
