import 'dart:convert';
import 'package:http/http.dart' as http;

// Service class to handle all HTTP communications with the backend PHP scripts.
class NetworkingService {
  // TODO: Replace with the actual base URL of the PHP server
  // final String _baseUrl = "http://spitball.000webhostapp.com"; // Original URL
  // Using a placeholder for now, as 000webhostapp might be unreliable or down.
  // This should be configurable, perhaps via an environment variable or a settings file.
  final String _baseUrl = "YOUR_PHP_SERVER_BASE_URL_HERE";


  // Corresponds to createGame.php logic in MenuActivity
  // Expected to return a Map like: {'GAMEID': int, 'NUMPLAYERS': int, 'TURN': int (optional)}
  Future<Map<String, dynamic>> createOrJoinOnlineGame() async {
    final url = Uri.parse('\$_baseUrl/createGame.php');
    try {
      // 'CREATE' method was used in MenuActivity to find/create a game.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'METHOD': 'CREATE'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Ensure correct types, especially for integers
        return {
          'GAMEID': int.tryParse(data['GAMEID'].toString()) ?? 0,
          'NUMPLAYERS': int.tryParse(data['NUMPLAYERS'].toString()) ?? 0,
          // 'TURN' might not always be present if just fetching NUMPLAYERS
          'TURN': data.containsKey('TURN') ? int.tryParse(data['TURN'].toString()) : null,
        };
      } else {
        print("Create/Join Game Error: Status \${response.statusCode}, Body: \${response.body}");
        throw Exception('Failed to create or join online game: \${response.statusCode}');
      }
    } catch (e) {
      print("Create/Join Game Exception: \$e");
      throw Exception('Failed to create or join online game: \$e');
    }
  }

  // Corresponds to leaveRoom logic in MenuActivity (calls leaveGame.php)
  Future<void> leaveOnlineGame(int gameId) async {
    final url = Uri.parse('\$_baseUrl/leaveGame.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'GAMEID': gameId.toString()}),
      );

      if (response.statusCode == 200) {
        // Success, response body might be minimal or just a confirmation
        print("Successfully left game \$gameId. Response: \${response.body}");
      } else {
        print("Leave Game Error: Status \${response.statusCode}, Body: \${response.body}");
        throw Exception('Failed to leave online game: \${response.statusCode}');
      }
    } catch (e) {
      print("Leave Game Exception: \$e");
      throw Exception('Failed to leave online game: \$e');
    }
  }

  // Corresponds to getOnlineMove in GameManager (calls gameMove.php)
  // Returns a Map representing the move:
  // {'XINIT': int, 'YINIT': int, 'XLAST': int, 'YLAST': int, 'SPLIT': int, 'TURN': int, 'GAMEID': int}
  // Can return null if no new move or error.
  Future<Map<String, dynamic>?> getOnlineMove(int gameId) async {
    final url = Uri.parse('\$_baseUrl/gameMove.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'METHODTYPE': 'GETMOVE', 'GAMEID': gameId.toString()}),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null; // No new move data
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.isEmpty || data['XINIT'] == null) return null; // Check for empty or incomplete data

        return {
          'XINIT': int.tryParse(data['XINIT'].toString()) ?? 0,
          'YINIT': int.tryParse(data['YINIT'].toString()) ?? 0,
          'XLAST': int.tryParse(data['XLAST'].toString()) ?? 0,
          'YLAST': int.tryParse(data['YLAST'].toString()) ?? 0,
          'SPLIT': int.tryParse(data['SPLIT'].toString()) ?? 0,
          'TURN': int.tryParse(data['TURN'].toString()) ?? 0,
          'GAMEID': int.tryParse(data['GAMEID'].toString()) ?? 0,
        };
      } else {
        print("Get Online Move Error: Status \${response.statusCode}, Body: \${response.body}");
        // Don't throw an exception here, as polling might expect null on non-critical errors
        return null;
      }
    } catch (e) {
      print("Get Online Move Exception: \$e");
      return null; // Return null on exception during polling
    }
  }

  // Corresponds to sendMoves in GameManager (calls gameMove.php)
  Future<void> sendMove(
    int gameId,
    int initialRow, // yInitial in Java
    int initialCol, // xInitial in Java
    int finalRow,   // yLast in Java
    int finalCol,   // xLast in Java
    int splitType,  // 0 for move, 1 for split
    int playerTurn, // Current player's turn identifier (0 for Green, 1 for Pink)
  ) async {
    final url = Uri.parse('\$_baseUrl/gameMove.php');
    try {
      final Map<String, String> moveData = {
        'METHODTYPE': 'MOVE',
        'GAMEID': gameId.toString(),
        'XINIT': initialCol.toString(), // Server expects X for column
        'YINIT': initialRow.toString(), // Server expects Y for row
        'XLAST': finalCol.toString(),
        'YLAST': finalRow.toString(),
        'SPLIT': splitType.toString(),
        'TURN': playerTurn.toString(),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(moveData),
      );

      if (response.statusCode == 200) {
        // Success, response body might be minimal (e.g., "insercion")
        print("Successfully sent move for game \$gameId. Response: \${response.body}");
      } else {
        print("Send Move Error: Status \${response.statusCode}, Body: \${response.body}");
        throw Exception('Failed to send move: \${response.statusCode}');
      }
    } catch (e) {
      print("Send Move Exception: \$e");
      throw Exception('Failed to send move: \$e');
    }
  }
}
