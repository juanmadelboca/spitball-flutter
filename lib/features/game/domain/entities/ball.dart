abstract class BallEntity {
  int size;

  BallEntity(this.size);
}

class BallGreenEntity extends BallEntity {
  BallGreenEntity(super.size);
}

class BallPinkEntity extends BallEntity {
  BallPinkEntity(super.size);
}
