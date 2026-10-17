import '../../core/result/result.dart';
import '../entities/journey.dart';

abstract interface class JourneyRepository {
  Future<Result<Journey>> getJourney();

  /// Fires whenever the journey changes on the server, e.g. a new circle was
  /// unlocked or the number of circles changed.
  Stream<void> watchChanges();
}
