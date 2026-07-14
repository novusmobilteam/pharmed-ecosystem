import 'package:pharmed_core/pharmed_core.dart';

abstract interface class ICabinTemperatureRepository {
  Future<Result<List<CabinTemperature>>> getCabinTemperature(int stationId);
  Future<Result<void>> createCabinTemperature(CabinTemperature entity);
  Future<Result<void>> updateCabinTemperature(CabinTemperature entity);
  Future<Result<void>> saveSensorValues({
    required CabinSensorReading data,
    required int stationId,
    required int cabinId,
  });
  Future<Result<CabinTemperature?>> getCurrentCabinThresholds({required int stationId, required int cabinId});
}
