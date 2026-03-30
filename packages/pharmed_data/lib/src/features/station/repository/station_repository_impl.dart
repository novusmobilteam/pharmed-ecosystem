import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/models/api_response/api_response.dart';
import 'package:pharmed_data/src/features/station/datasource/station_remote_datasource.dart';
import 'package:pharmed_data/src/features/station/mapper/station_mapper.dart';

// [SWREQ-DATA-STATION-002]
// IStationRepository implementasyonu.
// DTO → entity dönüşümü SttionMapper üzerinden yapılır.
// Sınıf: Class B
class StationRepositoryImpl implements IStationRepository {
  const StationRepositoryImpl({required StationRemoteDataSource dataSource, required StationMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final StationRemoteDataSource _dataSource;
  final StationMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Station>>>> getStations({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getStations(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Station>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createStation(Station entity) async {
    final result = await _dataSource.createStation(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateStation(Station entity) async {
    final result = await _dataSource.updateStation(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteStation(Station entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek servisin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteStation(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<Station?>> getCurrentStation() async {
    final result = await _dataSource.getCurrentStation();
    return result.when(
      ok: (stationDto) => Result.ok(StationMapper().toEntityOrNull(stationDto)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Station?>> getStation(int stationId) async {
    final result = await _dataSource.getStation(stationId);
    return result.when(
      ok: (stationDto) => Result.ok(StationMapper().toEntityOrNull(stationDto)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateStationMacAddress(int stationId) async {
    final result = await _dataSource.updateStationMacAddress(stationId);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
