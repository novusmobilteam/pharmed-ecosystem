import '../../../../core/core.dart';

import '../entity/station.dart';
import '../repository/i_station_repository.dart';

class GetCurrentStationUseCase extends NoParamsUseCase<Station?> {
  final IStationRepository _repository;

  GetCurrentStationUseCase(this._repository);

  @override
  Future<Result<Station?>> call() {
    return _repository.getCurrentStation();
  }
}
