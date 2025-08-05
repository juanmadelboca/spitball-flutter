// Defines the type of ball in the game.
enum BallType {
  ballGreen,
  ballPink;

  @override
  String toString() {
    switch (this) {
      case BallType.ballGreen:
        return 'BallGreen';
      case BallType.ballPink:
        return 'BallPink';
    }
  }
}
