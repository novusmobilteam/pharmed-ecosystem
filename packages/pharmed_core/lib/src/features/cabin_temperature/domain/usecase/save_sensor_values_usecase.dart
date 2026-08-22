// [SWREQ-HW-SENSOR-003] [IEC 62304 §5.5]
// Tek bir sensör okumasını sunucuya kaydeder.
//
// stationId'yi kendi çözer; cabinId çağırandan gelir (cache paket dışında).
// Örnekleme/throttle sorumluluğu çağırana aittir; bu use case her çağrıda
// tek kayıt gönderir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class SaveSensorValuesUseCase {
  const SaveSensorValuesUseCase(this._repo, this._getCurrentStation);

  final ICabinTemperatureRepository _repo;
  final GetCurrentStationUseCase _getCurrentStation;

  Future<Result<void>> call({required CabinSensorReading reading, required int cabinId}) async {
    final stationResult = await _getCurrentStation();

    final stationId = switch (stationResult) {
      Ok(:final value) => value?.id,
      Error() => null,
    };

    if (stationId == null) {
      return Result.error(
        ServiceException(message: contextlessL10n().cabinTemperature_currentStationNotFoundError, statusCode: 400),
      );
    }

    final result = await _repo.saveSensorValues(data: reading, stationId: stationId, cabinId: cabinId);

    return result;
  }
}
