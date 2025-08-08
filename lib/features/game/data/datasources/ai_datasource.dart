
// The abstract contract for any AI implementation
import '../../domain/entities/tile.dart' show Tile;

abstract class AiDataSource {
  List<int> calculateEasyMove(List<List<Tile>> tiles);
  List<int> calculateHardMove(List<List<Tile>> tiles, {required bool chaser});
}