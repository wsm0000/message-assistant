import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class GatewayFailure extends Failure {
  const GatewayFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
