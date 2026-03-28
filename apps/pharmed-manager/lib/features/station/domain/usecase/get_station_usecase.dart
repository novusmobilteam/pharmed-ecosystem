import '../../../../core/core.dart';

import '../entity/station.dart';
import '../repository/i_station_repository.dart';

class GetStationUseCase extends UseCase<Station?, int> {
  final IStationRepository _repository;

  GetStationUseCase(this._repository);

  @override
  Future<Result<Station?>> call(int stationId) {
    return _repository.getStation(stationId);
  }
}
