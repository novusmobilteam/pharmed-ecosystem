import '../../../../core/core.dart';

import '../entity/station.dart';
import '../repository/i_station_repository.dart';

class CreateStationUseCase extends UseCase<void, Station> {
  final IStationRepository _repository;

  CreateStationUseCase(this._repository);

  @override
  Future<Result<void>> call(Station params) {
    return _repository.createStation(params);
  }
}
