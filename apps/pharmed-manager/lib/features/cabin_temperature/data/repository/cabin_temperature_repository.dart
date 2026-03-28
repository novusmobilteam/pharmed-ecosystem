import '../../../../core/core.dart';
import '../../domain/entity/cabin_temperature.dart';
import '../../domain/entity/cabin_temperature_detail.dart';

abstract class ICabinTemperatureRepository {
  Future<Result<List<CabinTemperature>>> getCabinTemperatures();
  Future<Result<List<CabinTemperatureDetail>>> getCabinTemperatureDetails(int stationId);

  Future<Result<CabinTemperature?>> createCabinTemperature(CabinTemperature entity);
  Future<Result<CabinTemperatureDetail?>> createCabinTemperatureDetail(CabinTemperatureDetail entity);

  Future<Result<CabinTemperatureDetail?>> updateCabinTemperatureDetail(CabinTemperatureDetail entity);

  Future<Result<void>> deleteCabinTemperatureDetail(CabinTemperatureDetail entity);
}
