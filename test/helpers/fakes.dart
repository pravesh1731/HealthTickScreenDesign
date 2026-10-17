import 'dart:async';
import 'dart:collection';

import 'package:health_tick_demo/core/error/failures.dart';
import 'package:health_tick_demo/core/result/result.dart';
import 'package:health_tick_demo/domain/entities/journey.dart';
import 'package:health_tick_demo/domain/entities/lesson.dart';
import 'package:health_tick_demo/domain/repositories/journey_repository.dart';
import 'package:health_tick_demo/domain/repositories/lesson_repository.dart';

/// Hand-written fakes: responses are queued per call, live events are pushed
/// manually, so each test reads as a script of what the backend does.
class FakeJourneyRepository implements JourneyRepository {
  final responses = Queue<Result<Journey>>();

  /// Push into this to simulate the server announcing a change.
  final changes = StreamController<void>.broadcast();
  int getCalls = 0;

  @override
  Future<Result<Journey>> getJourney() async {
    getCalls++;
    return responses.isEmpty
        ? const Err(UnexpectedFailure('no response queued'))
        : responses.removeFirst();
  }

  @override
  Stream<void> watchChanges() => changes.stream;
}

class FakeLessonRepository implements LessonRepository {
  final lessonResponses = Queue<Result<Lesson>>();
  final completeResponses = Queue<Result<LessonCompletion>>();
  int completeCalls = 0;

  @override
  Future<Result<Lesson>> getLesson(String id) async => lessonResponses.removeFirst();

  @override
  Future<Result<LessonCompletion>> completeLesson(String id) async {
    completeCalls++;
    return completeResponses.removeFirst();
  }
}
