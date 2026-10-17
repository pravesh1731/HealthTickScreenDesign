import 'package:flutter/material.dart';

import '../../../core/error/failures.dart';

/// User-facing wording for each failure. Kept in the presentation layer so
/// the domain stays free of UI strings and icons.
extension FailureCopy on Failure {
  String get title => switch (this) {
    NetworkFailure() => "You're offline",
    TimeoutFailure() => 'This is taking too long',
    ServerFailure() => 'Something went wrong on our side',
    NotFoundFailure() => "We couldn't find that",
    ForbiddenFailure() => "This isn't unlocked yet",
    RejectedRequestFailure() => "That didn't go through",
    ParsingFailure() => 'We received something unexpected',
    UnexpectedFailure() => 'Something went wrong',
  };

  String get message => switch (this) {
    NetworkFailure() =>
      "We can't reach Health Tick right now. Check your connection and try again.",
    TimeoutFailure() => 'The server is responding slowly. Please try again.',
    ServerFailure() => 'Our servers had a hiccup. Please try again in a moment.',
    NotFoundFailure() => 'It may have been moved or removed from your journey.',
    ForbiddenFailure() => 'Finish the earlier lessons to unlock this one.',
    RejectedRequestFailure() => 'Please try again. If it keeps happening, restart the app.',
    ParsingFailure() => "The data we got doesn't look right. Please try again.",
    UnexpectedFailure() => 'Please try again.',
  };

  IconData get icon => switch (this) {
    NetworkFailure() => Icons.wifi_off_rounded,
    TimeoutFailure() => Icons.hourglass_bottom_rounded,
    ServerFailure() => Icons.cloud_off_rounded,
    NotFoundFailure() => Icons.search_off_rounded,
    ForbiddenFailure() => Icons.lock_outline_rounded,
    RejectedRequestFailure() ||
    ParsingFailure() ||
    UnexpectedFailure() => Icons.error_outline_rounded,
  };
}
