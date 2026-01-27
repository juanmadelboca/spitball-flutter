import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class TileComponent extends PositionComponent with TapCallbacks {
  final int row;
  final int col;
  final Function(int, int) onTileTapped;

  TileComponent({
    required this.row,
    required this.col,
    required double size,
    required Vector2 position,
    required this.onTileTapped,
  }) : super(size: Vector2.all(size), position: position);

  @override
  void render(Canvas canvas) {
    // Draw a simple background for the tile
    // Using a slightly transparent paint to show the background image behind
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw rounded rect
    final rrect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4.0));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTileTapped(row, col);
  }
}
