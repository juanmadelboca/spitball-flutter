part of 'bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

// Event to start a new game
class GameStarted extends GameEvent {
  // Pass game settings like difficulty, online mode, etc.
  // For simplicity, we'll omit them here but you'd add them.
}

// Event when a user taps a tile on the board
class TileTapped extends GameEvent {
  final int row;
  final int col;

  const TileTapped(this.row, this.col);

  @override
  List<Object> get props => [row, col];
}

// Internal event for when the game state is updated from an external source (like AI or network)
class _GameUpdated extends GameEvent {
  final GameState newState;

  const _GameUpdated(this.newState);

  @override
  List<Object> get props => [newState];
}