// Custom exceptions for the game logic.

class InvalidMoveException implements Exception {
  final String message;
  InvalidMoveException(this.message);
  @override
  String toString() => 'InvalidMoveException: \$message';
}

class LimitMoveException implements Exception {
  final String message;
  LimitMoveException(this.message);
  @override
  String toString() => 'LimitMoveException: \$message';
}

class UnderSizedSpitException implements Exception {
  final String message;
  UnderSizedSpitException(this.message);
  @override
  String toString() => 'UnderSizedSpitException: \$message';
}
