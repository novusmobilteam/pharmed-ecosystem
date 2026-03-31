// [SWREQ-CORE-STATION-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateStationUseCase {
  final IStationRepository _repository;

  UpdateStationUseCase(this._repository);

  Future<Result<void>> call(Station params) {
    return _repository.updateStation(params);
  }
}
