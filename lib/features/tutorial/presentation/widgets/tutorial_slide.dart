import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'demo_board.dart';

class TutorialSlide extends StatelessWidget {
  final String title;
  final String description;
  final DemoType demoType;

  const TutorialSlide({
    super.key,
    required this.title,
    required this.description,
    required this.demoType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLandscape = constraints.maxWidth > constraints.maxHeight;
        
        if (isLandscape) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Demo Board Side
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 250),
                      child: DemoBoard(type: demoType),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Text Side
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pressStart2p( // Pixel Title
                          fontSize: 18, // Reduced
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 0,
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                             const BoxShadow(
                              color: Colors.black,
                              blurRadius: 0,
                              offset: Offset(6, 6),
                            )
                          ]
                        ),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vt323(
                            fontSize: 22, // Reduced
                            height: 1.1,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Portrait Layout (Original)
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Start from top
              children: [
                const SizedBox(height: 20), // Top padding
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 20, 
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 0,
                        color: Colors.black,
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // Reduced gap
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                       const BoxShadow(
                        color: Colors.black,
                        blurRadius: 0,
                        offset: Offset(6, 6),
                      )
                    ]
                  ),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vt323(
                      fontSize: 24,
                      height: 1.1,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded( 
                  child: Center(
                    child: DemoBoard(type: demoType),
                  ),
                ),
                const Spacer(), // Push everything up
              ],
            ),
          );
        }
      }
    );
  }
}
