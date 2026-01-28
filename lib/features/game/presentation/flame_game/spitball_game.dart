import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';
import 'package:spitball/features/game/presentation/flame_game/components/ball_component.dart';
import 'package:spitball/features/game/presentation/flame_game/components/tile_component.dart';

class SpitballGame extends FlameGame {
  final GameBloc gameBloc;

  SpitballGame({required this.gameBloc});

  @override
  Color backgroundColor() => const Color(0xFF212121);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await add(
      FlameBlocProvider<GameBloc, GameState>.value(
        value: gameBloc,
        children: [
          BoardComponent(),
        ],
      ),
    );
  }
}

class BoardComponent extends Component with FlameBlocListenable<GameBloc, GameState>, HasGameRef<SpitballGame> {
  // Store previous board ball sizes to detect "Growth" (Eating)
  List<List<int>>? _previousSizes;

  @override
  void onMount() {
    super.onMount();
    // Render the initial state immediately once mounted and bloc is available
    _updateBoard(bloc.state);
  }

  @override
  void onNewState(GameState state) {
     _updateBoard(state);
  }

  void _updateBoard(GameState state) {
     if (state is GameInProgress) {
        // Clear everything and rebuild
        removeAll(children);

        final board = state.board;
        final rows = board.length;
        if (rows == 0) return;
        final cols = board[0].length;
        
        // Calculate cell size based on screen size
        final double screenSizeWidth = gameRef.size.x;
        final double screenSizeHeight = gameRef.size.y;
        
        // Add some padding
        final double padding = 20.0;
        final double availableWidth = screenSizeWidth - (padding * 2);
        final double availableHeight = screenSizeHeight - (padding * 2);
        
        final double cellWidth = availableWidth / cols;
        final double cellHeight = availableHeight / rows;
        
        // Keep cells square
        final double cellSize = (cellWidth < cellHeight ? cellWidth : cellHeight);
        
        // Center the grid
        final double gridWidth = cellSize * cols;
        final double gridHeight = cellSize * rows;
        
        final double startX = (screenSizeWidth - gridWidth) / 2;
        final double startY = (screenSizeHeight - gridHeight) / 2;
        
        // Prepare current sizes for next turn
        List<List<int>> currentSizes = List.generate(rows, (_) => List.filled(cols, 0));

        // Add Shadow (Hard black offset)
        add(RectangleComponent(
          position: Vector2(startX + 8, startY + 8),
          size: Vector2(gridWidth, gridHeight),
          paint: Paint()..color = Colors.black,
        ));

        // Add Board Background (Brown)
        add(RectangleComponent(
          position: Vector2(startX, startY),
          size: Vector2(gridWidth, gridHeight),
          paint: Paint()
            ..color = const Color(0xFF5D4037)
            ..style = PaintingStyle.fill,
        ));
        
        // Add Board Border (Black stroke) - render via separate component or just another rect if using border paint (but pure rect component uses one paint)
        add(RectangleComponent(
          position: Vector2(startX, startY),
          size: Vector2(gridWidth, gridHeight),
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0,
        ));

         for (int r = 0; r < rows; r++) {
           for (int c = 0; c < cols; c++) {
              final tile = board[r][c];
              final Vector2 tilePos = Vector2(startX + c * cellSize, startY + r * cellSize);
              
              // Helper to check if ball existed previously and was smaller
              bool didJustEat = false;
              int currentSize = tile.ball?.size ?? 0;
              currentSizes[r][c] = currentSize;

              if (tile.ball != null && _previousSizes != null) {
                  int prevSize = _previousSizes![r][c];
                  // If there was a ball here, and now it's bigger, it ate someone.
                  // Only valid if prevSize > 0 (it wasn't empty)
                  if (prevSize > 0 && currentSize > prevSize) {
                      didJustEat = true;
                  }
              }

              // Always add a TileComponent
              add(TileComponent(
                row: r, 
                col: c, 
                size: cellSize - 2.0, // Gap
                position: tilePos,
                onTileTapped: (row, col) {
                   bloc.add(TileTapped(row, col));
                },
              ));

              // If there is a ball, add a BallComponent on top
              if (tile.ball != null) {
                 add(BallComponent(
                   tile: tile, 
                   row: r, 
                   col: c, 
                   size: cellSize * 0.8, 
                   position: tilePos + Vector2.all(cellSize * 0.1), 
                   isSelected: (r == state.selectedRow && c == state.selectedCol),
                   triggersEatAnimation: didJustEat,
                   onBallTapped: (row, col) {
                     bloc.add(TileTapped(row, col));
                   },
                 ));
              }
           }
         }
         
         // Update cache
         _previousSizes = currentSizes;
     }
  }
}
