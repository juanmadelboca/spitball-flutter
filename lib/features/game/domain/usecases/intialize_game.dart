// domain/use_cases/initialize_game_use_case.dart
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

import '../repositories/game_repository.dart';

class InitializeGameUseCase {
  final GameRepository repository;

  InitializeGameUseCase(this.repository);

  // The 'call' method allows us to invoke the class instance like a function.
  GameState call() {
    return repository.initializeGame();
  }
}