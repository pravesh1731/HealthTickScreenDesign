import '../../core/error/guard.dart';
import '../../core/result/result.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_remote_data_source.dart';

class LessonRepositoryImpl implements LessonRepository {
  const LessonRepositoryImpl(this._remote);

  final LessonRemoteDataSource _remote;

  @override
  Future<Result<Lesson>> getLesson(String id) => guard(() => _remote.fetchLesson(id));

  @override
  Future<Result<LessonCompletion>> completeLesson(String id) =>
      guard(() => _remote.completeLesson(id));
}
