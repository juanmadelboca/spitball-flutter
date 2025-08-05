import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spitball/core/controllers/game_controller.dart';
import '../../domain/entities/ball.dart';

class BoardWidget extends StatefulWidget {
  final GameController gameController;
  final Function(int row, int col) onTileTap;

  const BoardWidget({
    super.key,
    required this.gameController,
    required this.onTileTap,
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

          final tileWidth = availableWidth / GameController.boardWidth;
          final tileHeight = availableHeight / GameController.boardHeight;
          final tileSize = min(tileWidth, tileHeight).floorToDouble();

          final boardPixelWidth = tileSize * GameController.boardWidth;
          final boardPixelHeight = tileSize * GameController.boardHeight;

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
                    GameController.boardWidth * GameController.boardHeight,
                    (index) {
                      final row = index ~/ GameController.boardWidth;
                      final col = index % GameController.boardWidth;
                      final tile = widget.gameController.tiles[row][col];
                      final ball = tile.ball;

                      final isSelected = widget.gameController.clicks == 1 &&
                          widget.gameController.initialRow == row &&
                          widget.gameController.initialCol == col;

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
