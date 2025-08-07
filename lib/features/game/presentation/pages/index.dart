import 'dart:async'; // Added for Timer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For potential providers
import 'package:spitball/core/controllers/game_controller.dart';
import 'package:spitball/features/menu/presentation/pages/menu.dart';

import '../widgets/board.dart';
class GameScreen extends ConsumerStatefulWidget {
  final GameController gameController;

  const GameScreen({required this.gameController, super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = widget.gameController;
    // Start a timer to periodically check for game updates and rebuild UI
    // This is similar to the refresh mechanism in the original Android GameActivity
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_controller.isGameOver || !mounted) {
        timer.cancel();
        if (mounted && _controller.isGameOver) _showGameOverDialog();
        return;
      }
      // Check if any move occurred that requires a UI update
      if (_controller.anyMoveOccurred) {
        if (mounted) setState(() {});
      }
      // For online games, GameController's internal polling handles opponent moves.
      // We just need to refresh UI if state changes.
      // If GameController itself becomes a Notifier, this can be more reactive.
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose(); // Dispose the controller to cancel its internal timers
    super.dispose();
  }

  void _showGameOverDialog() {
    // Ensure dialog is not shown if context is no longer valid
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(
              'Winner: ${_controller.pinkBallCount == 0 ? "Green" : "Pink"}! \nGreen Balls: ${_controller.greenBallCount}\nPink Balls: ${_controller.pinkBallCount}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to Menu'),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(MainMenuScreen.routeName);
              },
            ),
            // TODO: Add "Play Again" option if desired
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: BoardWidget(
            gameController: _controller,
            onTileTap: (row, col) {
              if (!_controller.isGameOver) {
                final success = _controller.handleTap(row, col);
                if (success || _controller.anyMoveOccurred) {
                  if (mounted) setState(() {});
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
