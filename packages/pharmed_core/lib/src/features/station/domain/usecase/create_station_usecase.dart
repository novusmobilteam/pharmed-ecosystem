// [SWREQ-CORE-WAREHOUSE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateStationUseCase {
  final IStationRepository _repository;

  CreateStationUseCase(this._repository);

  Future<Result<void>> call(Station params) {
    return _repository.createStation(params);
  }
}
