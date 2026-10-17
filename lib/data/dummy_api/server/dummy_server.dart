import 'dart:convert';

import '../../../core/error/exceptions.dart';
import '../hardcoded/journey_config_data.dart';
import '../hardcoded/lesson_content_data.dart';
import 'content.dart';
import 'errors.dart';
import 'journey_config.dart';
import 'journey_service.dart';

/// Plays the role of the backend's HTTP layer: routes a request to the
/// [JourneyService] and turns business errors into the status codes a real
/// server would send (404 not found, 403 lesson locked).
class DummyServer {
  DummyServer(this.service);

  /// Seeded from the hard-coded JSON in `data/dummy_api/hardcoded/`.
  factory DummyServer.withHardcodedData() => DummyServer(
    JourneyService(
      config: JourneyConfig.fromJson(jsonDecode(journeyConfigJson) as Map<String, dynamic>),
      content: ContentCatalog.fromJson(jsonDecode(lessonContentJson) as Map<String, dynamic>),
    ),
  );

  final JourneyService service;

  /// Returns the JSON response body, or throws [HttpStatusException].
  ///
  /// Routes: `GET journey`, `GET lessons/<id>`, `POST lessons/<id>/complete`.
  Map<String, dynamic> handle(String method, String path) {
    final parts = path.split('/');
    try {
      if (method == 'GET' && path == 'journey') return service.journeyJson();
      if (method == 'GET' && parts.length == 2 && parts[0] == 'lessons') {
        return service.lesson(parts[1]).toDetailJson();
      }
      if (method == 'POST' &&
          parts.length == 3 &&
          parts[0] == 'lessons' &&
          parts[2] == 'complete') {
        return service.completeLesson(parts[1]);
      }
    } on DomainException catch (error) {
      final statusCode = switch (error) {
        NotFoundException() => 404,
        LessonLockedException() => 403,
      };
      throw HttpStatusException(error.message, statusCode: statusCode, code: error.code);
    }
    throw HttpStatusException('No route for $method /$path', statusCode: 404, code: 'NOT_FOUND');
  }
}
