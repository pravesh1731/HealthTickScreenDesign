import '../../core/result/result.dart';
import '../entities/journey.dart';
import '../repositories/journey_repository.dart';

class GetJourney {
  const GetJourney(this._repository);

  final JourneyRepository _repository;

  Future<Result<Journey>> call() => _repository.getJourney();
}
