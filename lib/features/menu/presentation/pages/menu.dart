import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spitball/features/menu/presentation/widgets/pixel_button.dart';
import 'package:spitball/features/menu/presentation/widgets/menu_background.dart';

import '../../../game/presentation/pages/game_screen.dart';
import '../../../tutorial/presentation/pages/index.dart';

class MainMenuScreen extends StatefulWidget {
  static const routeName = "/MainMenuScreen";

  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _isPlayMenuExpanded = false;

  void _startGame(BuildContext context, int difficulty) {
    // print('Starting game with AI difficulty: $difficulty');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => GameScreen(
                aiLevel: difficulty,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MenuBackground(),
          SafeArea(
            child: Center(
              child: LayoutBuilder(builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 600;

                Widget titleSection = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Hero( // Add Hero animation to logo if we navigate elsewhere
                       tag: 'game_logo',
                       child: ClipRect(
                         child: Align(
                           alignment: Alignment.topCenter,
                           heightFactor: 0.5, // Show only the top half (1st sprite)
                           child: Image.asset(
                             'assets/images/green_ball_idle.png',
                             height: isWide ? 140 : 160,
                             filterQuality: FilterQuality.none, // Pixel art needs no filtering
                           ),
                         ),
                       ),
                     ),
                    const SizedBox(height: 20),
                    Text(
                      'SPITBALL',
                      style: GoogleFonts.pressStart2p( // Pixel font
                        fontSize: isWide ? 40 : 35,
                        color: const Color(0xFFf3c64a),
                        shadows: [
                          const Shadow(
                            blurRadius: 0,
                            color: Colors.black,
                            offset: Offset(4.0, 4.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                Widget buttonsSection = SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelButton(
                        text: 'PLAY',
                        hasIcon: true,
                        baseColor: Colors.blue,
                        onPressed: () {
                          setState(() {
                            _isPlayMenuExpanded = !_isPlayMenuExpanded;
                          });
                        },
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _isPlayMenuExpanded
                            ? Column(
                                children: [
                                  PixelButton(
                                    text: 'Easy',
                                    fontSize: 16,
                                    baseColor: Colors.green,
                                    onPressed: () => _startGame(context, 0),
                                  ),
                                  PixelButton(
                                    text: 'Medium',
                                    fontSize: 16,
                                    baseColor: Colors.orange,
                                    onPressed: () => _startGame(context, 1),
                                  ),
                                  PixelButton(
                                    text: 'Hard',
                                    fontSize: 16,
                                    baseColor: Colors.red,
                                    onPressed: () => _startGame(context, 2),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      PixelButton(
                        text: 'TUTORIAL',
                        baseColor: Colors.purple,
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const TutorialScreen()));
                        },
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: titleSection),
                      Expanded(child: buttonsSection),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      titleSection,
                      const Spacer(flex: 1),
                      buttonsSection,
                      const Spacer(flex: 2),
                    ],
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
