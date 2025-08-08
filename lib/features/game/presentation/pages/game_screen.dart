// presentation/pages/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spitball/features/game/data/datasources/ai_datasource_impl.dart';
import 'package:spitball/features/game/domain/repositories/game_repository_impl.dart';
import 'package:spitball/features/game/domain/usecases/game_update.dart';
import 'package:spitball/features/game/domain/usecases/handle_taps.dart';
import 'package:spitball/features/game/domain/usecases/intialize_game.dart';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';
import 'package:spitball/features/game/presentation/widgets/board.dart';
import 'package:spitball/features/menu/presentation/pages/menu.dart';

// Import all necessary files
// ... other imports for GameView

class GameScreen extends StatelessWidget {
  final int aiLevel;
  const GameScreen({super.key, required this.aiLevel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {

        final aiDataSource = AiDataSourceImpl();

        final gameRepository = GameRepositoryImpl(aiDataSource: aiDataSource);
        final initializeGameUseCase = InitializeGameUseCase(gameRepository);
        final handleTapUseCase = HandleTapUseCase(gameRepository);
        final getGameUpdatesUseCase = GetGameUpdatesUseCase(gameRepository);

        // 3. Create the BLoC, injecting the use cases
        return GameBloc(
          initializeGameUseCase: initializeGameUseCase,
          handleTapUseCase: handleTapUseCase,
          getGameUpdatesUseCase: getGameUpdatesUseCase,
        )..add(GameStarted(aiLevel: aiLevel));
      },
      child: GameView(), // The GameView widget itself remains unchanged
    );
  }
}

// The GameView widget from the previous example does not need any changes.
// It still sends events and listens to states in the same way.
class GameView extends StatelessWidget {
  const GameView({super.key});

  /// Helper method to show the Game Over dialog.
  /// It's kept separate for clarity.
  void _showGameOverDialog(BuildContext context, GameOver state) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Winner: ${state.winner}! \nGreen Balls: ${state.greenBallCount}\nPink Balls: ${state.pinkBallCount}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to Menu'),
              onPressed: () {
                // Use the dialog's context to pop it, then navigate.
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacementNamed(MainMenuScreen.routeName);
              },
            ),
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
          // BlocListener handles "side effects" like showing dialogs or SnackBars
          // without rebuilding the entire widget tree.
          child: BlocListener<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameOver) {
                _showGameOverDialog(context, state);
              }
              // You could also listen for a GameError state to show a SnackBar
              // if (state is GameError) { ... }
            },
            // BlocBuilder handles rebuilding the UI in response to state changes.
            child: BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                // Show a loading indicator while the game initializes
                if (state is GameInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show the main game board when the game is in progress
                if (state is GameInProgress) {
                  return BoardWidget(
                    board: state.board, // Pass the board data to the widget
                    onTileTap: (row, col) {
                      // Dispatch an event to the BLoC on user interaction
                      context.read<GameBloc>().add(TileTapped(row, col));
                    },
                  );
                }

                // When the game is over, the listener shows a dialog.
                // We can show a static screen behind the dialog.
                if (state is GameOver) {
                  return const Center(
                    child: Text(
                      "Game Over",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                // If an unrecoverable error occurs, show an error message
                if (state is GameError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                // Fallback for any other unexpected state
                return const Center(child: Text("Something went wrong!"));
              },
            ),
          ),
        ),
      ),
    );
  }
}
