import '../../../../core/core.dart';
import '../entity/station.dart';

abstract class IStationRepository {
  Future<Result<ApiResponse<List<Station>>>> getStations({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<Station?>> getStation(int stationId);
  Future<Result<Station?>> getCurrentStation();
  Future<Result<void>> createStation(Station entity);
  Future<Result<void>> updateStation(Station entity);
  Future<Result<void>> deleteStation(Station entity);
  Future<Result<void>> updateStationMacAddress(int stationId);
}
