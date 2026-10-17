import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../data/datasources/journey_remote_data_source.dart';
import '../data/datasources/lesson_remote_data_source.dart';
import '../data/dummy_api/dummy_api_client.dart';
import '../data/dummy_api/server/dummy_server.dart';
import '../data/repositories/journey_repository_impl.dart';
import '../data/repositories/lesson_repository_impl.dart';
import '../domain/repositories/journey_repository.dart';
import '../domain/repositories/lesson_repository.dart';
import '../domain/usecases/complete_lesson.dart';
import '../domain/usecases/get_journey.dart';
import '../domain/usecases/get_lesson.dart';
import '../domain/usecases/watch_journey_changes.dart';

// Dependency injection. This is the only file that names concrete classes;
// everything else depends on interfaces. Tests override the two repository
// providers with fakes.

final dummyServerProvider = Provider<DummyServer>((ref) {
  final server = DummyServer.withHardcodedData();
  ref.onDispose(server.service.dispose);
  return server;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => DummyApiClient(ref.watch(dummyServerProvider)),
);

final journeyRepositoryProvider = Provider<JourneyRepository>(
  (ref) => JourneyRepositoryImpl(
    remote: JourneyRemoteDataSource(ref.watch(apiClientProvider)),
    serverChanges: ref.watch(dummyServerProvider).service.changes,
  ),
);

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => LessonRepositoryImpl(LessonRemoteDataSource(ref.watch(apiClientProvider))),
);

final getJourneyProvider = Provider((ref) => GetJourney(ref.watch(journeyRepositoryProvider)));

final watchJourneyChangesProvider = Provider(
  (ref) => WatchJourneyChanges(ref.watch(journeyRepositoryProvider)),
);

final getLessonProvider = Provider((ref) => GetLesson(ref.watch(lessonRepositoryProvider)));

final completeLessonProvider = Provider(
  (ref) => CompleteLesson(ref.watch(lessonRepositoryProvider)),
);
