// [SWREQ-HW-SENSOR-002] [IEC 62304 §5.5]
// Kabinin ısı/nem eşiklerini getirir.
//
// Servis eksik/hatalı değer dönerse eşik değerlendirmesi yapılamaz;
// bu durumda ilgili alan null kalır ve UI o metrik için uyarı üretmez
// (yanlış "aralık dışı" alarmı vermektense hiç uyarmamak tercih edilir).
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class GetCabinThresholdsUseCase {
  const GetCabinThresholdsUseCase(this._repo, this._getCurrentStation);

  final ICabinTemperatureRepository _repo;
  final GetCurrentStationUseCase _getCurrentStation;

  Future<Result<CabinSensorThresholds>> call({required int cabinId}) async {
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

    final result = await _repo.getCurrentCabinThresholds(stationId: stationId, cabinId: cabinId);

    return switch (result) {
      Ok(:final value) => Result.ok(_toThresholds(value)),
      Error(:final error) => Result.error(error),
    };
  }

  /// Servis null dönerse (kabin için eşik tanımlanmamış) tüm alanlar null —
  /// UI fallback'e düşer.
  CabinSensorThresholds _toThresholds(CabinTemperature? source) {
    if (source == null) {
      MedLogger.warn(
        unit: 'SW-UNIT-DOMAIN',
        swreq: 'SWREQ-HW-SENSOR-002',
        message: 'Kabin için eşik tanımlı değil — varsayılan kullanılacak',
      );
      return CabinSensorThresholds.fallback;
    }

    return CabinSensorThresholds(
      tempMin: source.bottomTemperatureInside?.toDouble(),
      tempMax: source.topTemperatureInside?.toDouble(),
      humidityMin: source.bottomLimitHumidity?.toDouble(),
      humidityMax: source.topLimitHumidity?.toDouble(),
    );
  }
}
