import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Kabin sıcaklık kontrol işlemleri için uzak (API) veri kaynağı.
class CabinTemperatureRemoteDataSource extends BaseRemoteDataSource {
  CabinTemperatureRemoteDataSource({required super.apiManager});

  final String _basePath = '/CabinTemperatureControl';

  @override
  String get logSwreq => 'SWREQ-DATA-CABINTEMP-001';

  @override
  String get logUnit => 'SW-UNIT-CABINTEMP';

  Future<Result<List<CabinTemperatureDto>>> getCabinTemperature(int stationId) async {
    final res = await fetchRequest(
      path: '$_basePath/stationCabinList/$stationId',
      parser: BaseRemoteDataSource.listParser(CabinTemperatureDto.fromJson),
      successLog: 'Cabin temperatures fetched',
      emptyLog: 'No cabin temperature',
    );
    return res.when(ok: (data) => Result.ok(data ?? []), error: Result.error);
  }

  Future<Result<void>> createCabinTemperature(CabinTemperatureDto dto) {
    return postRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Cabin temperature created',
    );
  }

  Future<Result<void>> updateCabinTemperature(CabinTemperatureDto dto) {
    if (dto.id == null) {
      return Future.value(Result.error(CustomException(message: 'updateCabinTemperature: id is null')));
    }
    return putRequest(
      path: '$_basePath/detail/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Cabin temperature updated',
    );
  }

  Future<Result<CabinTemperatureDto?>> getCurrentCabinThresholds({required int stationId, required int cabinId}) async {
    final result = await fetchRequest(
      path: '$_basePath/$stationId/$cabinId',
      parser: BaseRemoteDataSource.singleParser(CabinTemperatureDto.fromJson),
    );

    return result.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  Future<Result<void>> saveSensorValues({
    required CabinSensorReading data,
    required int stationId,
    required int cabinId,
  }) async {
    return postRequest(
      path: '/CabinTemperatureValues',
      parser: BaseRemoteDataSource.voidParser(),
      body: {
        "stationId": stationId,
        "cabinId": cabinId,
        "temperatureInside": data.temperature ?? 0,
        "temperatureOutside": 0,
        "humidity": data.humidity ?? 0,
      },
    );
  }
}
