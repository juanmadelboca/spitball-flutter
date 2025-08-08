// lib/features/game/domain/entities/board_entity.dart
import 'package:equatable/equatable.dart';
import 'tile.dart';

class BoardEntity extends Equatable {
  final List<List<Tile>> tiles;
  final int currentPlayer;
  final int? selectedRow;
  final int? selectedCol;
  final bool isGameOver;
  final String? winner;

  const BoardEntity({
    required this.tiles,
    required this.currentPlayer,
    this.selectedRow,
    this.selectedCol,
    this.isGameOver = false,
    this.winner,
  });

  @override
  List<Object?> get props => [tiles, currentPlayer, selectedRow, selectedCol, isGameOver, winner];
}
