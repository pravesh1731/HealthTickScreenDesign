/// Business-rule failures. [DummyServer] maps each one to a status code and
/// a stable machine readable `code` the app can switch on.
sealed class DomainException implements Exception {
  const DomainException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

class NotFoundException extends DomainException {
  const NotFoundException(String message) : super('NOT_FOUND', message);
}

class LessonLockedException extends DomainException {
  const LessonLockedException(String lessonId)
    : super('LESSON_LOCKED', 'Lesson "$lessonId" is still locked.');
}
