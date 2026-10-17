import '../../core/result/result.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLesson {
  const GetLesson(this._repository);

  final LessonRepository _repository;

  Future<Result<Lesson>> call(String id) => _repository.getLesson(id);
}
