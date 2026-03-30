// [SWREQ-CORE-STATION-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetStationUseCase {
  final IStationRepository _repository;

  GetStationUseCase(this._repository);

  Future<Result<Station?>> call(int stationId) {
    return _repository.getStation(stationId);
  }
}
