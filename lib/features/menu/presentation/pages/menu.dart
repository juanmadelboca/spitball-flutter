import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spitball/features/menu/presentation/widgets/wooden_button.dart';

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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/ballgreen.png',
                  height: 150,
                ),
                const SizedBox(height: 10),
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
                WoodenButton(
                  text: 'Play',
                  hasIcon: true,
                  onPressed: () {
                    setState(() {
                      _isPlayMenuExpanded = !_isPlayMenuExpanded;
                    });
                  },
                ),
                if (_isPlayMenuExpanded)
                  Column(
                    children: [
                      WoodenButton(
                        text: 'Easy',
                        fontSize: 22,
                        onPressed: () => _startGame(context, 0),
                      ),
                      WoodenButton(
                        text: 'Medium',
                        fontSize: 22,
                        onPressed: () => _startGame(context, 1),
                      ),
                      WoodenButton(
                        text: 'Hard',
                        fontSize: 22,
                        onPressed: () => _startGame(context, 2),
                      ),
                    ],
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
