import 'dart:developer' as developer;

import '../result/result.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Runs a data-layer operation and converts anything it throws into a typed
/// [Failure], so no exception ever escapes a repository.
Future<Result<T>> guard<T>(Future<T> Function() operation) async {
  try {
    return Ok(await operation());
  } catch (error, stackTrace) {
    final failure = mapErrorToFailure(error);
    developer.log(
      'Request failed: $failure',
      name: 'repository',
      error: error,
      stackTrace: failure is UnexpectedFailure ? stackTrace : null,
    );
    return Err(failure);
  }
}

Failure mapErrorToFailure(Object error) => switch (error) {
  NoConnectionException(:final message) => NetworkFailure(message),
  RequestTimeoutException(:final message) => TimeoutFailure(message),
  HttpStatusException(:final statusCode, :final message) when statusCode >= 500 => ServerFailure(
    message,
    statusCode: statusCode,
  ),
  HttpStatusException(statusCode: 404, :final message) => NotFoundFailure(message),
  HttpStatusException(statusCode: 403, :final message, :final code) => ForbiddenFailure(
    message,
    code: code,
  ),
  HttpStatusException(:final message, :final code) => RejectedRequestFailure(message, code: code),
  ResponseFormatException(:final message) => ParsingFailure(message),
  // Model parsing throws FormatException with the path of the bad field.
  FormatException(:final message) => ParsingFailure(message),
  _ => UnexpectedFailure(error.toString()),
};
