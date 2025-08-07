import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';
import '../../domain/entities/ball.dart';

class BoardWidget extends StatefulWidget {
  final List<List<Tile>> tiles;
  final Function(int row, int col) onTileTap;
  final int selectedRow;
  final int selectedCol;

  const BoardWidget({
    super.key,
    required this.tiles,
    required this.onTileTap,
    this.selectedRow = -1,
    this.selectedCol = -1,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth * 0.90;
          final availableHeight = constraints.maxHeight * 0.90;

          final tileWidth = availableWidth / 9;
          final tileHeight = availableHeight / 5;
          final tileSize = min(tileWidth, tileHeight).floorToDouble();

          final boardPixelWidth = tileSize * 9;
          final boardPixelHeight = tileSize * 5;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.05,
              vertical: constraints.maxHeight * 0.05,
            ),
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/b2.jpg'),
                    fit: BoxFit.contain, // or BoxFit.fill or BoxFit.fitWidth depending on your image
                  ),
                ),
                width: boardPixelWidth,
                height: boardPixelHeight,
                child: Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: List.generate(
                    9 * 5,
                    (index) {
                      final row = index ~/ 9;
                      final col = index % 9;
                      final tile = widget.tiles[row][col];
                      final ball = tile.ball;

                      final isSelected = widget.selectedRow == row && widget.selectedCol == col;

                      return SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: GestureDetector(
                          onTap: () => widget.onTileTap(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, width: 0.5),
                              color: isSelected ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                            ),
                            child: isSelected
                                ? AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) => Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: _buildBallWidget(ball, tileSize, tileSize, true),
                                    ),
                                  )
                                : _buildBallWidget(ball, tileSize, tileSize, false),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBallWidget(Ball? ball, double tileWidth, double tileHeight, bool isSelected) {
    if (ball == null || ball.size == 0) return const SizedBox.shrink();

    final isGreen = ball is BallGreen;
    final maxVisualSize = tileWidth * 0.8;
    final minVisualSize = tileWidth * 0.2;
    var visualSize = minVisualSize + (ball.size / 100.0) * (maxVisualSize - minVisualSize);
    visualSize = visualSize.clamp(minVisualSize, maxVisualSize);

    Widget content;

    if (isGreen) {
      content = Image.asset(
        'assets/images/ballgreen.png',
        width: visualSize,
        height: visualSize,
        fit: BoxFit.contain,
      );
    } else {
      content = Image.asset(
        'assets/images/ballpink.png',
        width: visualSize,
        height: visualSize,
        fit: BoxFit.contain,
      );
    }

    return Center(child: content);
  }
}
