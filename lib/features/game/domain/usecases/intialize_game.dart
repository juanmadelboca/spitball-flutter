import 'package:dartz/dartz.dart';
import 'package:spitball/core/error/failure.dart';

import 'package:spitball/features/game/domain/entities/board.dart';
import 'package:spitball/features/game/domain/repositories/game_repository.dart';

class InitializeGameUseCase {
  final GameRepository repository;

  InitializeGameUseCase(this.repository);

  Future<Either<Failure, BoardEntity>> call({required int aiLevel}) async {
    return repository.initializeGame(aiLevel: aiLevel);
  }
}
