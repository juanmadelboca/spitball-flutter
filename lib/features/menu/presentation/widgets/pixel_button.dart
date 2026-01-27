import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool hasIcon;
  final double fontSize;
  final Color? baseColor;

  const PixelButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.hasIcon = false,
    this.fontSize = 14, // Smaller default font size
    this.baseColor,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.baseColor ?? Colors.blue;
    final darkColor = HSLColor.fromColor(color).withLightness(0.3).toColor();
    final lightColor = HSLColor.fromColor(color).withLightness(0.8).toColor();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        height: 45, // Reduced from 60
        child: Stack(
          children: [
            // Shadow Layer (Bottom-Right) - Reduced
            if (!_isPressed)
              Positioned(
                bottom: 0,
                right: 0,
                left: 2,
                top: 4,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            
            // Main Button Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 30),
              top: _isPressed ? 2 : 0,
              left: _isPressed ? 2 : 0,
              right: _isPressed ? 0 : 2,
              bottom: _isPressed ? 0 : 2,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border(
                    top: BorderSide(color: lightColor, width: 2), // Reduced border width
                    left: BorderSide(color: lightColor, width: 2),
                    right: BorderSide(color: darkColor, width: 2),
                    bottom: BorderSide(color: darkColor, width: 2),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.hasIcon) ...[
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 18, // Smaller icon
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: widget.fontSize,
                          color: Colors.white,
                          shadows: [
                             const Shadow(
                              blurRadius: 0,
                              color: Colors.black,
                              offset: Offset(1, 1), // Smaller shadow
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
