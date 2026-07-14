import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class CabinTemperatureRepositoryImpl implements ICabinTemperatureRepository {
  final CabinTemperatureRemoteDataSource _dataSource;
  final CabinTemperatureMapper _cabinTemperatureMapper;

  CabinTemperatureRepositoryImpl({
    required CabinTemperatureRemoteDataSource dataSource,
    required CabinTemperatureMapper cabinTemperatureMapper,
  }) : _dataSource = dataSource,
       _cabinTemperatureMapper = cabinTemperatureMapper;

  @override
  Future<Result<List<CabinTemperature>>> getCabinTemperature(int stationId) async {
    final result = await _dataSource.getCabinTemperature(stationId);
    return result.when(
      ok: (dtos) => Result.ok(_cabinTemperatureMapper.toEntityList(dtos)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createCabinTemperature(CabinTemperature entity) async {
    final result = await _dataSource.createCabinTemperature(_cabinTemperatureMapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateCabinTemperature(CabinTemperature entity) async {
    final result = await _dataSource.updateCabinTemperature(_cabinTemperatureMapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> saveSensorValues({
    required CabinSensorReading data,
    required int stationId,
    required int cabinId,
  }) async {
    return await _dataSource.saveSensorValues(data: data, stationId: stationId, cabinId: cabinId);
  }

  @override
  Future<Result<CabinTemperature?>> getCurrentCabinThresholds({required int stationId, required int cabinId}) async {
    final result = await _dataSource.getCurrentCabinThresholds(stationId: stationId, cabinId: cabinId);
    return result.when(
      ok: (dto) => Result.ok(_cabinTemperatureMapper.toEntityOrNull(dto)),
      error: (e) => Result.error(e),
    );
  }
}
