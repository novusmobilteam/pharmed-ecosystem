// [SWREQ-CORE-STATION-UC-005]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteStationUseCase {
  final IStationRepository _repository;

  DeleteStationUseCase(this._repository);

  Future<Result<void>> call(Station params) {
    return _repository.deleteStation(params);
  }
}
