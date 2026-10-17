import 'package:equatable/equatable.dart';

/// Domain-level description of what went wrong. Pure Dart: the presentation
/// layer decides how each failure is worded and drawn.
sealed class Failure extends Equatable {
  const Failure(this.debugMessage);

  /// Developer-facing detail for logs. Never shown to users as-is.
  final String debugMessage;

  /// Whether trying the same request again could reasonably succeed.
  bool get isRetryable => true;

  @override
  List<Object?> get props => [runtimeType, debugMessage];

  @override
  String toString() => '$runtimeType($debugMessage)';
}

/// No connection, DNS failure, connection refused (e.g. backend not running).
final class NetworkFailure extends Failure {
  const NetworkFailure(super.debugMessage);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure(super.debugMessage);
}

/// 5xx responses.
final class ServerFailure extends Failure {
  const ServerFailure(super.debugMessage, {required this.statusCode});

  final int statusCode;
}

/// 404 – the resource is gone, e.g. a circle was removed from the backend.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.debugMessage);

  @override
  bool get isRetryable => false;
}

/// 403 – e.g. opening a lesson that is still locked.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.debugMessage, {required this.code});

  final String code;

  @override
  bool get isRetryable => false;
}

/// 400 / 422 – the request itself was rejected.
final class RejectedRequestFailure extends Failure {
  const RejectedRequestFailure(super.debugMessage, {required this.code});

  final String code;

  @override
  bool get isRetryable => false;
}

/// The server answered, but with data we could not understand.
final class ParsingFailure extends Failure {
  const ParsingFailure(super.debugMessage);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.debugMessage);
}
