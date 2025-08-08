// presentation/bloc/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';
import 'package:spitball/features/game/domain/usecases/game_update.dart';
import 'package:spitball/features/game/domain/usecases/handle_taps.dart';
import 'package:spitball/features/game/domain/usecases/intialize_game.dart';

// Import your use cases
// Import other domain/entity files

part 'event.dart';
part 'state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  // Dependencies are now Use Cases, not the repository
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

    // Call the use case to get the stream
    _gameUpdatesSubscription = _getGameUpdatesUseCase().listen((newState) {
      add(_GameUpdated(newState));
    });
  }

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    // Call the use case instance directly
    emit(_initializeGameUseCase());
  }

  void _onTileTapped(TileTapped event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      // Call the use case with parameters
      final newState = _handleTapUseCase(row: event.row, col: event.col);
      emit(newState);
    }
  }

  void _onGameUpdated(_GameUpdated event, Emitter<GameState> emit) {
    emit(event.newState);
  }

  @override
  Future<void> close() {
    _gameUpdatesSubscription?.cancel();
    // You would have a dispose use case here
    // _disposeGameUseCase();
    return super.close();
  }
}
