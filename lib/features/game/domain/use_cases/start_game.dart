import 'package:spitball/features/game/domain/entities/ball_type.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';
import 'package:spitball/features/game/presentation/providers/game_state.dart';

class StartGame {
  GameState call() {
    final tiles = _loadTiles();
    _initializeBoard(tiles);
    return GameState(tiles: tiles);
  }

  List<List<Tile>> _loadTiles() {
    return List.generate(
      5,
      (_) => List.generate(9, (_) => Tile()),
    );
  }

  void _initializeBoard(List<List<Tile>> tiles) {
    tiles[1][3].setBall(20, BallType.ballGreen);
    tiles[2][2].setBall(20, BallType.ballGreen);
    tiles[3][3].setBall(20, BallType.ballGreen);
    tiles[1][5].setBall(20, BallType.ballPink);
    tiles[2][6].setBall(20, BallType.ballPink);
    tiles[3][5].setBall(20, BallType.ballPink);
  }
}
