import 'package:flutter/material.dart';
import 'package:spitball/features/menu/presentation/widgets/glass_button.dart';
import 'package:spitball/features/menu/presentation/widgets/menu_background.dart';
import 'package:spitball/features/tutorial/presentation/widgets/demo_board.dart';
import 'package:spitball/features/tutorial/presentation/widgets/tutorial_slide.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialSlide> _slides = const [
    TutorialSlide(
      title: 'OBJECTIVE',
      description: 'The goal is to eliminate all opponent balls. Capture them or force them into a corner!',
      demoType: DemoType.none,
    ),
    TutorialSlide(
      title: 'MOVING',
      description: 'Tap your ball to select it. Then tap any adjacent tile to move. Easy!',
      demoType: DemoType.move,
    ),
    TutorialSlide(
      title: 'ATTACKING (WIN)',
      description: 'If your ball is BIGGER or EQUAL size, you eat the enemy ball and grow larger!',
      demoType: DemoType.attackWin,
    ),
    TutorialSlide(
      title: 'ATTACKING (LOSE)',
      description: 'Watch out! If you attack a BIGGER ball, you get eaten instead!',
      demoType: DemoType.attackLose,
    ),
    TutorialSlide(
      title: 'SPLITTING',
      description: 'Tap a tile 2 steps away (straight line) to SPLIT. Half remains, half moves to the new spot.',
      demoType: DemoType.split,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MenuBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header / Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: _slides,
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? Colors.yellowAccent : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      GlassButton(
                        text: _currentPage == _slides.length - 1 ? 'LET\'S PLAY!' : 'NEXT',
                        fontSize: 20,
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
