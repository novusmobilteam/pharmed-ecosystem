import '../../../../core/core.dart';
import '../../domain/entity/station.dart';
import '../../domain/repository/i_station_repository.dart';
import '../datasource/remote/station_data_source.dart';

class StationRepository implements IStationRepository {
  final StationDataSource _ds;

  StationRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Station>>>> getStations({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getStations(search: search, skip: skip, take: take);
    return res.when(
      ok: (response) {
        List<Station> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<Station>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createStation(Station entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createStation(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateStation(Station entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateStation(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteStation(Station station) async {
    final id = station.id;
    if (id == null) return Result.error(CustomException(message: 'deleteStation: id is null'));
    final r = await _ds.deleteStation(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateStationMacAddress(int stationId) {
    return _ds.updateStationMacAddress(stationId);
  }

  @override
  Future<Result<Station?>> getStation(int stationId) async {
    final res = await _ds.getStation(stationId);

    return res.when(
      ok: (s) => Result.ok(s?.toEntity()),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Station?>> getCurrentStation() async {
    final res = await _ds.getCurrentStation();

    return res.when(
      ok: (s) => Result.ok(s?.toEntity()),
      error: (e) => Result.error(e),
    );
  }
}
