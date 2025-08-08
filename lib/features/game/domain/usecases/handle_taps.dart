// domain/use_cases/handle_tap_use_case.dart
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

import '../repositories/game_repository.dart';

class HandleTapUseCase {
  final GameRepository repository;

  HandleTapUseCase(this.repository);

  GameState call({required int row, required int col}) {
    return repository.handleTap(row, col);
  }
}