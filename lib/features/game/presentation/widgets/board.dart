import 'package:flutter/material.dart';

import '../../domain/entities/ball.dart';
import '../../domain/entities/tile.dart'; // Import your Tile and Ball entities

class BoardWidget extends StatelessWidget {
  /// The 2D list representing the current state of the board.
  final List<List<Tile>> board;

  /// Callback function to execute when a tile is tapped.
  final Function(int row, int col) onTileTap;

  /// The row of the currently selected tile, for UI highlighting.
  final int? selectedRow;

  /// The column of the currently selected tile, for UI highlighting.
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
    // Use AspectRatio to maintain the board's shape regardless of screen size.
    return AspectRatio(
      aspectRatio: 9 / 5, // Based on your board's dimensions (width / height)
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling
        itemCount: board.length * board[0].length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: board[0].length, // 9 columns
        ),
        itemBuilder: (context, index) {
          // Calculate the row and column from the grid index
          final int row = index ~/ board[0].length;
          final int col = index % board[0].length;
          final Tile tile = board[row][col];
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
              // Center the ball widget within the tile
              child: _buildBall(tile),
            ),
          );
        },
      ),
    );
  }

  /// Helper widget to build the ball if one exists on the tile.
  Widget? _buildBall(Tile tile) {
    if (tile.ball == null) {
      return null;
    }

    // Determine the color based on the ball type
    final Color ballColor =
    (tile.ball is BallGreen) ? Colors.green.shade400 : Colors.pink.shade400;

    return Center(
      child: Container(
        width: 30, // Example size, you can make this dynamic
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