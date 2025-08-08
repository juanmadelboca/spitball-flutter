import 'dart:async';

import 'package:spitball/features/game/domain/entities/board.dart';
import 'package:spitball/features/game/domain/repositories/game_repository.dart';


class GetGameUpdatesUseCase {
  final GameRepository repository;

  GetGameUpdatesUseCase(this.repository);

  Stream<BoardEntity> call() {
    return repository.gameUpdates;
  }
}
