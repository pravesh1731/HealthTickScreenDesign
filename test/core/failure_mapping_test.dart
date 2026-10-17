import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/core/error/exceptions.dart';
import 'package:health_tick_demo/core/error/failures.dart';
import 'package:health_tick_demo/core/error/guard.dart';
import 'package:health_tick_demo/core/result/result.dart';

void main() {
  test('maps every exception type to the matching failure', () {
    expect(mapErrorToFailure(const NoConnectionException('x')), isA<NetworkFailure>());
    expect(mapErrorToFailure(const RequestTimeoutException('x')), isA<TimeoutFailure>());
    expect(
      mapErrorToFailure(const HttpStatusException('x', statusCode: 500, code: 'E')),
      isA<ServerFailure>(),
    );
    expect(
      mapErrorToFailure(const HttpStatusException('x', statusCode: 404, code: 'E')),
      isA<NotFoundFailure>(),
    );
    expect(
      mapErrorToFailure(const HttpStatusException('x', statusCode: 403, code: 'E')),
      isA<ForbiddenFailure>(),
    );
    expect(
      mapErrorToFailure(const HttpStatusException('x', statusCode: 400, code: 'E')),
      isA<RejectedRequestFailure>(),
    );
    expect(mapErrorToFailure(const FormatException('bad')), isA<ParsingFailure>());
    expect(mapErrorToFailure(StateError('boom')), isA<UnexpectedFailure>());
  });

  test('guard returns Ok on success and Err instead of throwing', () async {
    final ok = await guard(() async => 42);
    final err = await guard<int>(() async => throw const FormatException('bad'));

    expect((ok as Ok<int>).value, 42);
    expect((err as Err<int>).failure, isA<ParsingFailure>());
  });
}
