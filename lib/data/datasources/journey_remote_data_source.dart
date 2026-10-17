import '../../core/network/api_client.dart';
import '../../domain/entities/journey.dart';
import '../models/journey_model.dart';

class JourneyRemoteDataSource {
  const JourneyRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Journey> fetchJourney() async => JourneyModel.fromJson(await _api.getJson('journey'));
}
