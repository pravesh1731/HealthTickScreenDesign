/// Exceptions thrown inside the data layer. They never cross a repository
/// boundary: [guard] converts them into [Failure]s.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NoConnectionException extends ApiException {
  const NoConnectionException(super.message);
}

final class RequestTimeoutException extends ApiException {
  const RequestTimeoutException(super.message);
}

/// A non-2xx response. [code] comes from the backend's error envelope
/// (`{"error": {"code": ..., "message": ...}}`) when one is present.
final class HttpStatusException extends ApiException {
  const HttpStatusException(super.message, {required this.statusCode, required this.code});

  final int statusCode;
  final String code;
}

/// The body was not valid JSON or did not match the expected schema.
final class ResponseFormatException extends ApiException {
  const ResponseFormatException(super.message);
}
