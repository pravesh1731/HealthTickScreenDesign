import '../../core/network/api_client.dart';
import '../../domain/entities/lesson.dart';
import '../models/lesson_model.dart';

class LessonRemoteDataSource {
  const LessonRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Lesson> fetchLesson(String id) async =>
      LessonModel.fromJson(await _api.getJson('lessons/$id'));

  Future<LessonCompletion> completeLesson(String id) async =>
      LessonModel.completionFromJson(await _api.postJson('lessons/$id/complete'));
}
