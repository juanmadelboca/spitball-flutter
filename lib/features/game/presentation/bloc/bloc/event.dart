part of 'bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class GameStarted extends GameEvent {
  final int aiLevel;

  const GameStarted({required this.aiLevel});

  @override
  List<Object> get props => [aiLevel];
}

class TileTapped extends GameEvent {
  final int row;
  final int col;

  const TileTapped(this.row, this.col);

  @override
  List<Object> get props => [row, col];
}

// THE CHANGE: This now carries the pure domain entity.
class _GameUpdated extends GameEvent {
  final BoardEntity boardEntity;

  const _GameUpdated(this.boardEntity);

  @override
  List<Object> get props => [boardEntity];
}