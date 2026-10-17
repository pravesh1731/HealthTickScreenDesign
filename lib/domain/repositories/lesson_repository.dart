import '../../core/result/result.dart';
import '../entities/lesson.dart';

abstract interface class LessonRepository {
  Future<Result<Lesson>> getLesson(String id);

  Future<Result<LessonCompletion>> completeLesson(String id);
}
