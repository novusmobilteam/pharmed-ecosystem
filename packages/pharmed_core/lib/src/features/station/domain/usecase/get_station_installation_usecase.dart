// [SWREQ-SETUP-RESTORE-002] [IEC 62304 §5.5]
// Cihazın MAC adresiyle kayıtlı istasyon kurulumunu getirir.
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class GetStationInstallationUseCase {
  final IStationRepository _repository;

  GetStationInstallationUseCase(this._repository);

  Future<Result<StationInstallation>> call() async {
    final macAddress = await DeviceInfo.getMacAddress();
    return _repository.getStationInstallation(macAddress);
  }
}
