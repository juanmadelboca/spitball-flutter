// domain/usecases/get_game_updates_use_case.dart
import 'dart:async';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

import '../repositories/game_repository.dart';

class GetGameUpdatesUseCase {
  final GameRepository repository;

  GetGameUpdatesUseCase(this.repository);

  Stream<GameState> call() {
    return repository.gameUpdates;
  }
}