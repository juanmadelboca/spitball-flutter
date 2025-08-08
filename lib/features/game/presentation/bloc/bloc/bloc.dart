import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spitball/features/game/domain/entities/board.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';
import 'package:spitball/features/game/domain/usecases/game_update.dart';
import 'package:spitball/features/game/domain/usecases/handle_taps.dart';
import 'package:spitball/features/game/domain/usecases/intialize_game.dart';


part 'event.dart';
part 'state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final InitializeGameUseCase _initializeGameUseCase;
  final HandleTapUseCase _handleTapUseCase;
  final GetGameUpdatesUseCase _getGameUpdatesUseCase;

  StreamSubscription? _gameUpdatesSubscription;

  GameBloc({
    required InitializeGameUseCase initializeGameUseCase,
    required HandleTapUseCase handleTapUseCase,
    required GetGameUpdatesUseCase getGameUpdatesUseCase,
  })  : _initializeGameUseCase = initializeGameUseCase,
        _handleTapUseCase = handleTapUseCase,
        _getGameUpdatesUseCase = getGameUpdatesUseCase,
        super(GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<TileTapped>(_onTileTapped);
    on<_GameUpdated>(_onGameUpdated);

    _gameUpdatesSubscription = _getGameUpdatesUseCase().listen((boardEntity) {
      add(_GameUpdated(boardEntity));
    });
  }

  GameState _mapBoardEntityToState(BoardEntity boardEntity) {
    if (boardEntity.isGameOver) {
      return GameOver(
        winner: boardEntity.winner ?? 'N/A',
        greenBallCount: 0,
        pinkBallCount: 0,
      );
    }
    return GameInProgress(
      board: boardEntity.tiles,
      currentPlayer: boardEntity.currentPlayer,
      isMyTurn: true,
      selectedRow: boardEntity.selectedRow,
      selectedCol: boardEntity.selectedCol,
    );
  }

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) async {
    final result = await _initializeGameUseCase(aiLevel: event.aiLevel);
    result.fold(
      (failure) => emit(GameError(message: failure.toString())),
      (boardEntity) => emit(_mapBoardEntityToState(boardEntity)),
    );
  }

  void _onTileTapped(TileTapped event, Emitter<GameState> emit) async {
    final result = await _handleTapUseCase(row: event.row, col: event.col);
    result.fold(
      (failure) => emit(GameError(message: failure.toString())),
      (boardEntity) => emit(_mapBoardEntityToState(boardEntity)),
    );
  }

  void _onGameUpdated(_GameUpdated event, Emitter<GameState> emit) {
    emit(_mapBoardEntityToState(event.boardEntity));
  }

  @override
  Future<void> close() {
    _gameUpdatesSubscription?.cancel();
    return super.close();
  }
}
