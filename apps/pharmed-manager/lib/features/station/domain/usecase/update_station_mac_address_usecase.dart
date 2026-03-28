import '../../../../core/core.dart';

import '../repository/i_station_repository.dart';

class UpdateStationMacAddressUseCase extends UseCase<void, int> {
  final IStationRepository _repository;

  UpdateStationMacAddressUseCase(this._repository);

  @override
  Future<Result<void>> call(int stationId) {
    return _repository.updateStationMacAddress(stationId);
  }
}
