// main_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spitball/features/menu/presentation/widgets/wooden_button.dart';

// Assuming your other files and providers are correctly set up
import '../../../game/presentation/pages/game_screen.dart';
import 'high_scores.dart';
import '../../../settings/presentation/pages/index.dart';
import '../../../tutorial/presentation/pages/index.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  static const routeName = "/MainMenuScreen";

  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover, // or BoxFit.fill or BoxFit.fitWidth depending on your image
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Added for smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 1. Slime Character Image
                Image.asset(
                  'assets/images/ballgreen.png', // Make sure this path is correct
                  height: 150,
                ),
                const SizedBox(height: 10),

                // 2. Main Menu Title
                Text(
                  'MAIN MENU',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 50,
                    color: const Color(0xFFf3c64a),
                    shadows: [
                      const Shadow(
                        blurRadius: 3.0,
                        color: Colors.black,
                        offset: Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Play Button
                WoodenButton(
                  text: 'Play',
                  hasIcon: true,
                  onPressed: () {
                    setState(() {
                      _isPlayMenuExpanded = !_isPlayMenuExpanded;
                    });
                  },
                ),

                // 4. Difficulty Buttons (Conditional)
                if (_isPlayMenuExpanded)
                  Column(
                    children: [
                      WoodenButton(
                        text: 'Easy',
                        fontSize: 22,
                        onPressed: () => _startGame(context, 0), // AI Difficulty 0
                      ),
                      WoodenButton(
                        text: 'Medium',
                        fontSize: 22,
                        onPressed: () => _startGame(context, 1), // AI Difficulty 1
                      ),
                      WoodenButton(
                        text: 'Hard',
                        fontSize: 22,
                        onPressed: () => _startGame(context, 2), // AI Difficulty 2
                      ),
                    ],
                  ),

                // 5. Other Menu Buttons
                WoodenButton(
                  text: 'Settings',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                ),
                WoodenButton(
                  text: 'High Scores',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HighScoresScreen()));
                  },
                ),
                WoodenButton(
                  text: 'Tutorial',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialScreen()));
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
