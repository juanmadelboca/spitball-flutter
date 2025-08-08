import 'package:dartz/dartz.dart';
import 'package:spitball/core/error/failure.dart';
import 'package:spitball/features/game/domain/entities/board.dart';

abstract class GameRepository {
  Future<Either<Failure, BoardEntity>> initializeGame({required int aiLevel});

  Future<Either<Failure, BoardEntity>> handleTap(int row, int col);

  Stream<BoardEntity> get gameUpdates;

  void dispose();
}
