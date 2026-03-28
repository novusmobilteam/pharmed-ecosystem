import '../../../../core/core.dart';

import '../entity/station.dart';
import '../repository/i_station_repository.dart';

class DeleteStationUseCase extends UseCase<void, Station> {
  final IStationRepository _repository;

  DeleteStationUseCase(this._repository);

  @override
  Future<Result<void>> call(Station params) {
    return _repository.deleteStation(params);
  }
}
