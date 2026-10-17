import '../../core/error/guard.dart';
import '../../core/result/result.dart';
import '../../domain/entities/journey.dart';
import '../../domain/repositories/journey_repository.dart';
import '../datasources/journey_remote_data_source.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  const JourneyRepositoryImpl({
    required JourneyRemoteDataSource remote,
    required this.serverChanges,
  }) : _remote = remote;

  final JourneyRemoteDataSource _remote;

  /// Change signal pushed by the server (with a real backend: a WebSocket).
  final Stream<void> serverChanges;

  @override
  Future<Result<Journey>> getJourney() => guard(_remote.fetchJourney);

  @override
  Stream<void> watchChanges() => serverChanges;
}
