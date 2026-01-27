import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DemoType {
  none,
  move,
  attackWin,
  attackLose,
  split,
}

class DemoBoard extends StatefulWidget {
  final DemoType type;

  const DemoBoard({super.key, required this.type});

  @override
  State<DemoBoard> createState() => _DemoBoardState();
}

class _DemoBoardState extends State<DemoBoard> with SingleTickerProviderStateMixin {
  late List<List<DemoTile>> grid;
  Timer? _animTimer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _resetGrid();
    _startDemoLoop();
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  void _resetGrid() {
    // 3x3 Grid
    grid = List.generate(3, (r) => List.generate(3, (c) => DemoTile()));
    _setupInitialState();
  }

  void _setupInitialState() {
    // Clear all
    for (var row in grid) {
      for (var tile in row) {
        tile.ballSize = 0;
        tile.isPlayer = true;
      }
    }

    // Center is (1,1)
    switch (widget.type) {
      case DemoType.move:
        grid[1][0].ballSize = 5; // Player start
        break;
      case DemoType.attackWin:
        grid[1][0].ballSize = 8; // Player (Big)
        grid[1][1].ballSize = 4; // Enemy (Small)
        grid[1][1].isPlayer = false;
        break;
      case DemoType.attackLose:
        grid[1][0].ballSize = 3; // Player (Small)
        grid[1][1].ballSize = 5; // Enemy (Big)
        grid[1][1].isPlayer = false;
        break;
      case DemoType.split:
        grid[1][0].ballSize = 8; // Player (Big)
        // Target is (1,2) - two steps away
        break;
      default:
        break;
    }
  }

  void _startDemoLoop() {
    if (widget.type == DemoType.none) return;

    _animTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        _step++;
        if (_step > 2) {
          _step = 0;
          _resetGrid(); // Reset to start
        } else if (_step == 1) {
          // Perform Action
          _performAction();
        }
        // Step 2 is "Show Result" (hold)
      });
    });
  }

  void _performAction() {
    switch (widget.type) {
      case DemoType.move:
        // Move from (1,0) to (1,1)
        grid[1][1].ballSize = grid[1][0].ballSize;
        grid[1][0].ballSize = 0;
        break;
      case DemoType.attackWin:
        // (1,0) attacks (1,1). Player (8) eats Enemy (4) -> New Size 12
        grid[1][1].ballSize = grid[1][0].ballSize + grid[1][1].ballSize;
        grid[1][1].isPlayer = true; // Captured!
        grid[1][0].ballSize = 0;
        break;
      case DemoType.attackLose:
        // (1,0) attacks (1,1). Player (3) vs Enemy (5) -> Enemy becomes 8
        grid[1][1].ballSize = grid[1][0].ballSize + grid[1][1].ballSize;
        grid[1][1].isPlayer = false; // Still Enemy
        grid[1][0].ballSize = 0; // Player consumed
        break;
      case DemoType.split:
        // Split from (1,0) to (1,2)
        int original = grid[1][0].ballSize;
        int half = (original / 2).floor();
        grid[1][0].ballSize = original - half;
        grid[1][2].ballSize = half;
        grid[1][2].isPlayer = true;
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smaller dimension to keep it square, or default to 200 if unbounded
        double size = 200;
        if (constraints.maxWidth != double.infinity && constraints.maxHeight != double.infinity) {
          size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
        } else if (constraints.maxWidth != double.infinity) {
          size = constraints.maxWidth;
        } else if (constraints.maxHeight != double.infinity) {
          size = constraints.maxHeight;
        }
        
        // Ensure we don't go too big or too small
        size = size.clamp(100.0, 300.0);

        return Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF5D4037), // Darker Brown
            border: Border.all(color: Colors.black, width: 4), // Hard border
            boxShadow: [
               const BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: Offset(8, 8),
              ),
            ],
          ),
          child: Column(
            children: List.generate(3, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(3, (c) {
                    return Expanded(
                      child: _buildTile(r, c),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      }
    );
  }

  Widget _buildTile(int r, int c) {
    final tile = grid[r][c];
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: (r + c) % 2 == 0 ? const Color(0xFFD7B899) : const Color(0xFFA67B5B), // Checkerboard
        border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1), // Grid lines
      ),
      child: Center(
        child: tile.ballSize > 0
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30 + (tile.ballSize * 1.5).clamp(0, 20).toDouble(),
                height: 30 + (tile.ballSize * 1.5).clamp(0, 20).toDouble(),
                decoration: BoxDecoration(
                  color: tile.isPlayer ? Colors.blue : Colors.red,
                  // Square with border instead of circle for 8-bit feel
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${tile.ballSize}',
                    style: GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 10, // Very small for pixel font inside small block
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class DemoTile {
  int ballSize = 0;
  bool isPlayer = true;
}
