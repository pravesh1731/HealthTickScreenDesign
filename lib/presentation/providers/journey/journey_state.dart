import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/journey.dart';

class JourneyState extends Equatable {
  const JourneyState({this.journey, this.isLoading = false, this.failure});

  /// The last journey that loaded. Kept on screen if a later reload fails.
  final Journey? journey;
  final bool isLoading;

  /// Why the last load failed, if it did.
  final Failure? failure;

  @override
  List<Object?> get props => [journey, isLoading, failure];
}
