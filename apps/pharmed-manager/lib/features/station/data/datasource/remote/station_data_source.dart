import '../../../../../core/core.dart';
import '../../model/station_dto.dart';

abstract class StationDataSource {
  Future<Result<ApiResponse<List<StationDTO>>>> getStations({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<StationDTO?>> getStation(int stationId);
  Future<Result<StationDTO?>> getCurrentStation();
  Future<Result<void>> createStation(StationDTO dto);
  Future<Result<void>> updateStation(StationDTO dto);
  Future<Result<void>> deleteStation(int id);
  Future<Result<void>> updateStationMacAddress(int stationId);
}
