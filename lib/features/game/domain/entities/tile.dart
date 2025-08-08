import 'ball.dart';
import 'ball_type.dart';

class TileEntity {
  BallEntity? _ball;

  TileEntity() {
    _ball = null;
  }

  BallEntity? get ball => _ball;

  void setBall(int size, BallTypeEntity type) {
    switch (type) {
      case BallTypeEntity.ballGreen:
        _ball = BallGreenEntity(size);
        break;
      case BallTypeEntity.ballPink:
        _ball = BallPinkEntity(size);
        break;
    }
  }

  void removeBall() {
    _ball = null;
  }

  bool battle(BallEntity immigrantBall, bool limitedMove) {
    if (_ball == null || _ball!.size == 0) {
      _ball = immigrantBall;
      return true;
    }

    BallEntity currentBall = _ball!;

    bool isImmigrantGreen = immigrantBall is BallGreenEntity;
    bool isCurrentGreen = currentBall is BallGreenEntity;
    bool isImmigrantPink = immigrantBall is BallPinkEntity;
    bool isCurrentPink = currentBall is BallPinkEntity;

    if (limitedMove && ((isImmigrantGreen && isCurrentGreen) || (isImmigrantPink && isCurrentPink))) {
      print("GAME: You have too few balls to perform that move due to limited move rule.");
      return false;
    }

    if (immigrantBall.size >= currentBall.size) {
      int newSize = currentBall.size + immigrantBall.size;
      if (isImmigrantGreen) {
        _ball = BallGreenEntity(newSize);
      } else {
        _ball = BallPinkEntity(newSize);
      }
    } else {
      currentBall.size += immigrantBall.size;
    }
    return true;
  }
}
