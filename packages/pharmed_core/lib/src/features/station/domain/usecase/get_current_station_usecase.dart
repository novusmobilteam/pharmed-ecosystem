// [SWREQ-CORE-STATION-UC-006]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class GetCurrentStationUseCase {
  final IStationRepository _repository;

  GetCurrentStationUseCase(this._repository);

  Future<Result<Station?>> call() async {
    final macAddress = await DeviceInfo.getMacAddress();
    return _repository.getCurrentStation(macAddress);
  }
}
