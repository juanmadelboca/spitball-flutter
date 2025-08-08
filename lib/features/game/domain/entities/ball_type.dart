
//TODO: UNIFY TO BALL
enum BallTypeEntity {
  ballGreen,
  ballPink;

  @override
  String toString() {
    switch (this) {
      case BallTypeEntity.ballGreen:
        return 'BallGreen';
      case BallTypeEntity.ballPink:
        return 'BallPink';
    }
  }
}
