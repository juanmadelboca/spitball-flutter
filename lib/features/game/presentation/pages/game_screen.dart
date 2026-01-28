import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spitball/features/game/data/datasources/ai_datasource_impl.dart';
import 'package:spitball/features/game/data/repositories/game_repository_impl.dart';

import 'package:spitball/features/game/domain/usecases/game_update.dart';
import 'package:spitball/features/game/domain/usecases/handle_taps.dart';
import 'package:spitball/features/game/domain/usecases/intialize_game.dart';

import 'package:flame/game.dart';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';
import 'package:spitball/features/game/presentation/flame_game/spitball_game.dart';
import 'package:spitball/features/menu/presentation/pages/menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spitball/features/menu/presentation/widgets/pixel_button.dart';

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

        return GameBloc(
          initializeGameUseCase: initializeGameUseCase,
          handleTapUseCase: handleTapUseCase,
          getGameUpdatesUseCase: getGameUpdatesUseCase,
        )..add(GameStarted(aiLevel: aiLevel));
      },
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  void _showGameOverDialog(BuildContext context, GameOver state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GAME OVER',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Winner: ${state.winner}!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vt323(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Green: ${state.greenBallCount}\nPink: ${state.pinkBallCount}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vt323(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 30),
                PixelButton(
                  text: 'MENU',
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushReplacementNamed(MainMenuScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121), // Ensure scaffold matches game bg
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: BlocListener<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameOver) {
                _showGameOverDialog(context, state);
              } else if (state is GameInProgress && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage!,
                      style: GoogleFonts.vt323(fontSize: 20, color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: const BeveledRectangleBorder(), // Retro style
                  ),
                );
              }
            },
            child: BlocBuilder<GameBloc, GameState>(
              buildWhen: (previous, current) {
                return previous.runtimeType != current.runtimeType;
              },
              builder: (context, state) {
                if (state is GameInitial) {
                  return const Center(child: CircularProgressIndicator(color: Colors.yellowAccent));
                }
                if (state is GameInProgress) {
                  return GameWidget(
                    game: SpitballGame(gameBloc: context.read<GameBloc>()),
                  );
                }
                if (state is GameOver) {
                   // While the dialog is showing, we might see this. 
                   // Let's just keep the last frame or show emptiness to avoid clutter behind dialog.
                   // Actually, usually you want to see the board.
                   // But since GameInProgress is gone, we can't see the FlameGame.
                   // Ideally we'd keep the FlameGame visible, but BlocBuilder switches widgets.
                   // For now, let's show a pixelated "GAME OVER" text if the dialog is dismissed?
                   // Or just nothing since the dialog is modal.
                  return Center(
                    child: Text(
                      "GAME OVER",
                      style: GoogleFonts.pressStart2p(fontSize: 32, color: Colors.white),
                    ),
                  );
                }

                if (state is GameError) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.black, width: 4),
                         boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(8, 8),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'ERROR: ${state.message}',
                        style: GoogleFonts.vt323(fontSize: 24, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Center(child: Text("Something went wrong!"));
              },
            ),
          ),
        ),
      ),
    );
  }
}
