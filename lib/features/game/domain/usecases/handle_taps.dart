import 'package:dartz/dartz.dart';
import 'package:spitball/core/error/failure.dart';

import 'package:spitball/features/game/domain/entities/board.dart';
import 'package:spitball/features/game/domain/repositories/game_repository.dart';

class HandleTapUseCase {
  final GameRepository repository;

  HandleTapUseCase(this.repository);

  Future<Either<Failure, BoardEntity>> call({required int row, required int col}) {
    return repository.handleTap(row, col);
  }
}
