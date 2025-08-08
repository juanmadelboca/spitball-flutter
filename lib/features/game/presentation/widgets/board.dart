import 'package:flutter/material.dart';

import '../../domain/entities/ball.dart';
import '../../domain/entities/tile.dart';

class BoardWidget extends StatelessWidget {
  final List<List<TileEntity>> board;

  final Function(int row, int col) onTileTap;

  final int? selectedRow;

  final int? selectedCol;

  const BoardWidget({
    super.key,
    required this.board,
    required this.onTileTap,
    this.selectedRow,
    this.selectedCol,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 5,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: board.length * board[0].length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: board[0].length,
        ),
        itemBuilder: (context, index) {
          final int row = index ~/ board[0].length;
          final int col = index % board[0].length;
          final TileEntity tile = board[row][col];
          final bool isSelected = (row == selectedRow && col == selectedCol);

          return GestureDetector(
            onTap: () => onTileTap(row, col),
            child: Container(
              margin: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                border: Border.all(
                  color: isSelected ? Colors.yellow : Colors.blueGrey[700]!,
                  width: isSelected ? 3.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: _buildBall(tile),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildBall(TileEntity tile) {
    if (tile.ball == null) {
      return null;
    }

    final Color ballColor = (tile.ball is BallGreenEntity) ? Colors.green.shade400 : Colors.pink.shade400;

    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: ballColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            tile.ball!.size.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
