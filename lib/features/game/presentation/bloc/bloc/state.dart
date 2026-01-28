part of 'bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameInProgress extends GameState {
  final List<List<TileEntity>> board;
  final int currentPlayer;
  final bool isMyTurn;
  final int? selectedRow;
  final int? selectedCol;
  final String? errorMessage; // Transient error message

  const GameInProgress({
    required this.board,
    required this.currentPlayer,
    required this.isMyTurn,
    this.selectedRow,
    this.selectedCol,
    this.errorMessage,
  });

  GameInProgress copyWith({
    List<List<TileEntity>>? board,
    int? currentPlayer,
    bool? isMyTurn,
    int? selectedRow,
    int? selectedCol,
    String? errorMessage,
  }) {
    return GameInProgress(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      isMyTurn: isMyTurn ?? this.isMyTurn,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      errorMessage: errorMessage, // Nullable, so if passed as null it clears
    );
  }

  @override
  List<Object?> get props => [board, currentPlayer, isMyTurn, selectedRow, selectedCol, errorMessage];
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
