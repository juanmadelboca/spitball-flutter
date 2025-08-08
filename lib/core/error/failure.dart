import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

class GameFailure extends Failure {
  final String message;

  const GameFailure(this.message);

  @override
  List<Object> get props => [message];
}

class GenericFailure extends Failure {
  final String message;

  const GenericFailure(this.message);

  @override
  List<Object> get props => [message];
}
