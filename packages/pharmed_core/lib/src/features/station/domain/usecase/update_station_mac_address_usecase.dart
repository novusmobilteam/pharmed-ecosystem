// [SWREQ-CORE-STATION-UC-007]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';

class UpdateStationMacAddressUseCase {
  final IStationRepository _repository;

  UpdateStationMacAddressUseCase(this._repository);

  Future<Result<void>> call(int stationId) {
    return _repository.updateStationMacAddress(stationId);
  }
}
