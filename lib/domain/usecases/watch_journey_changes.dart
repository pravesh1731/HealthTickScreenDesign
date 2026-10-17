import '../repositories/journey_repository.dart';

/// Real-time updates: tells the app when it should reload the journey.
class WatchJourneyChanges {
  const WatchJourneyChanges(this._repository);

  final JourneyRepository _repository;

  Stream<void> call() => _repository.watchChanges();
}
