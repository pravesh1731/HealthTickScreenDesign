import '../../core/result/result.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class CompleteLesson {
  const CompleteLesson(this._repository);

  final LessonRepository _repository;

  Future<Result<LessonCompletion>> call(String id) => _repository.completeLesson(id);
}
