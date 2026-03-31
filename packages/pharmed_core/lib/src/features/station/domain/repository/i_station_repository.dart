import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IStationRepository {
  Future<Result<ApiResponse<List<Station>>>> getStations({int? skip, int? take, String? search});
  Future<Result<void>> createStation(Station station);
  Future<Result<void>> updateStation(Station station);
  Future<Result<void>> deleteStation(Station station);

  Future<Result<Station?>> getStation(int stationId);
  Future<Result<Station?>> getCurrentStation();
  Future<Result<void>> updateStationMacAddress(int stationId);
}
