// lib/widgets/wooden_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wood_texture.dart';

class WoodenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final bool hasIcon;

  const WoodenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 28.0,
    this.hasIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 60,
          width: 280,
          decoration: BoxDecoration(
            // The decoration now only handles the border and shadow.
            // The background is handled by the Stack child.
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5a3d2b), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 4), // Shadow position
              ),
            ],
          ),
          // ClipRRect ensures the texture respects the container's rounded corners.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9.0), // Slightly less than container to be safe
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Layer 1: The SVG Wood Texture fills the background
                const WoodTexture(),

                // Layer 2: The Text and Icon are placed on top
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text.toUpperCase(),
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: fontSize,
                        shadows: [
                          const Shadow(
                            blurRadius: 2.0,
                            color: Color.fromARGB(255, 85, 59, 41),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    if (hasIcon)
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
