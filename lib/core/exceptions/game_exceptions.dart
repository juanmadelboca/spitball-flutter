/// Base class for all custom exceptions related to game logic.
/// Implementing Exception makes it a proper Dart exception class.
class GameException implements Exception {
  final String message;

  const GameException(this.message);

  @override
  String toString() => 'GameException: $message';
}

// Specific exceptions that describe exactly what went wrong.

class InvalidMoveException extends GameException {
  const InvalidMoveException(String message) : super(message);
}

class UnderSizedSpitException extends GameException {
  const UnderSizedSpitException(String message) : super(message);
}

class LimitMoveException extends GameException {
  const LimitMoveException(String message) : super(message);
}
