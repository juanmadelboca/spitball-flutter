// domain/use_cases/initialize_game_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:spitball/core/error/failure.dart';
import 'package:spitball/features/game/domain/entities/board.dart';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

import '../repositories/game_repository.dart';

class InitializeGameUseCase {
  final GameRepository repository;

  InitializeGameUseCase(this.repository);

  // The call method now accepts the AI level
  Future<Either<Failure, BoardEntity>> call({required int aiLevel}) async {
    return repository.initializeGame(aiLevel: aiLevel);
  }
}