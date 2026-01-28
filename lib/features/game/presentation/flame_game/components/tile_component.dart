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
    // Checkerboard pattern matching DemoBoard
    final bool isEven = (row + col) % 2 == 0;
    final color = isEven ? const Color(0xFFD7B899) : const Color(0xFFA67B5B);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw square rect (hard edges)
    final rect = size.toRect();
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTileTapped(row, col);
  }
}
