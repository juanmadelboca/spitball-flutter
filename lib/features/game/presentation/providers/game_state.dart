import 'packagepackage:spitball/features/game/domain/entities/tile.dart';

class GameState {
  final List<List<Tile>> tiles;
  final bool gameOver;
  final int playerTurn;
  final int clicks;
  final int initialRow;
  final int initialCol;

  GameState({
    required this.tiles,
    this.gameOver = false,
    this.playerTurn = 0,
    this.clicks = 0,
    this.initialRow = -1,
    this.initialCol = -1,
  });

  GameState copyWith({
    List<List<Tile>>? tiles,
    bool? gameOver,
    int? playerTurn,
    int? clicks,
    int? initialRow,
    int? initialCol,
  }) {
    return GameState(
      tiles: tiles ?? this.tiles,
      gameOver: gameOver ?? this.gameOver,
      playerTurn: playerTurn ?? this.playerTurn,
      clicks: clicks ?? this.clicks,
      initialRow: initialRow ?? this.initialRow,
      initialCol: initialCol ?? this.initialCol,
    );
  }
}
