part of 'bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameInProgress extends GameState {
  final List<List<Tile>> board;
  final int currentPlayer; // 0 for Green, 1 for Pink
  final bool isMyTurn;
  final int? selectedRow;
  final int? selectedCol;

  const GameInProgress({
    required this.board,
    required this.currentPlayer,
    required this.isMyTurn,
    this.selectedRow,
    this.selectedCol,
  });

  @override
  List<Object?> get props => [board, currentPlayer, isMyTurn, selectedRow, selectedCol];
}

class GameOver extends GameState {
  final String winner;
  final int greenBallCount;
  final int pinkBallCount;

  const GameOver({
    required this.winner,
    required this.greenBallCount,
    required this.pinkBallCount,
  });

  @override
  List<Object?> get props => [winner, greenBallCount, pinkBallCount];
}

class GameError extends GameState {
  final String message;

  const GameError({required this.message});

  @override
  List<Object> get props => [message];
}