import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spitball/features/menu/presentation/widgets/glass_button.dart';
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
    print('Starting game with AI difficulty: $difficulty');

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
                       child: Image.asset(
                        'assets/images/ballgreen.png',
                        height: isWide ? 140 : 160,
                        filterQuality: FilterQuality.high,
                       ),
                     ),
                    const SizedBox(height: 10),
                    Text(
                      'SPITBALL',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: isWide ? 60 : 55,
                        color: const Color(0xFFf3c64a),
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(5.0, 5.0),
                          ),
                          const Shadow( // Extra outline effect
                            blurRadius: 2.0,
                            color: Colors.black,
                            offset: Offset(-2.0, -2.0),
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
                      GlassButton(
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
                                  GlassButton(
                                    text: 'Easy',
                                    fontSize: 20,
                                    baseColor: Colors.green,
                                    onPressed: () => _startGame(context, 0),
                                  ),
                                  GlassButton(
                                    text: 'Medium',
                                    fontSize: 20,
                                    baseColor: Colors.orange,
                                    onPressed: () => _startGame(context, 1),
                                  ),
                                  GlassButton(
                                    text: 'Hard',
                                    fontSize: 20,
                                    baseColor: Colors.red,
                                    onPressed: () => _startGame(context, 2),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      GlassButton(
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
