import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spitball/features/game/data/datasources/ai_datasource_impl.dart';
import 'package:spitball/features/game/data/repositories/game_repository_impl.dart';

import 'package:spitball/features/game/domain/usecases/game_update.dart';
import 'package:spitball/features/game/domain/usecases/handle_taps.dart';
import 'package:spitball/features/game/domain/usecases/intialize_game.dart';

import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';
import 'package:spitball/features/game/presentation/widgets/board.dart';
import 'package:spitball/features/menu/presentation/pages/menu.dart';

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
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Winner: ${state.winner}! \nGreen Balls: ${state.greenBallCount}\nPink Balls: ${state.pinkBallCount}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to Menu'),
              onPressed: () {
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
          child: BlocListener<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameOver) {
                _showGameOverDialog(context, state);
              }
            },
            child: BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                if (state is GameInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GameInProgress) {
                  return BoardWidget(
                    board: state.board,
                    onTileTap: (row, col) {
                      context.read<GameBloc>().add(TileTapped(row, col));
                    },
                  );
                }
                if (state is GameOver) {
                  return const Center(
                    child: Text(
                      "Game Over",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                if (state is GameError) {
                  return Center(child: Text('Error: ${state.message}'));
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
