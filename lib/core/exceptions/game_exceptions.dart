class GameException implements Exception {
  final String message;

  const GameException(this.message);

  @override
  String toString() => 'GameException: $message';
}

// Specific exceptions that describe exactly what went wrong.

class InvalidMoveException extends GameException {
  const InvalidMoveException(super.message);
}

class UnderSizedSpitException extends GameException {
  const UnderSizedSpitException(super.message);
}

class LimitMoveException extends GameException {
  const LimitMoveException(super.message);
}
