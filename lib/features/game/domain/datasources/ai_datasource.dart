import 'package:spitball/features/game/domain/entities/tile.dart';

abstract class AiDataSource {
  List<int> calculateEasyMove(List<List<TileEntity>> tiles);

  List<int> calculateHardMove(List<List<TileEntity>> tiles, {required bool chaser});
}
