
// Abstract class for all Failures. They are part of the Domain layer.
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

// A specific failure for game-related errors
class GameFailure extends Failure {
  final String message;

  const GameFailure(this.message);

  @override
  List<Object> get props => [message];
}

// A generic failure for any other case
class GenericFailure extends Failure {
  final String message;

  const GenericFailure(this.message);

  @override
  List<Object> get props => [message];
}