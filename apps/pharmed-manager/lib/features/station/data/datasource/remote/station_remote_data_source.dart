import '../../../../../core/core.dart';
import '../../../../../core/utils/device_info.dart';
import '../../model/station_dto.dart';
import 'station_data_source.dart';

class StationRemoteDataSource extends BaseRemoteDataSource implements StationDataSource {
  final String _basePath = '/Station';

  StationRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<StationDTO>>>> getStations({
    int? skip,
    int? take,
    String? search,
  }) async {
    final r = await fetchRequest<ApiResponse<List<StationDTO>>>(
      path: _basePath,
      // skip: skip,
      // take: take,
      // searchText: search,
      // searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(StationDTO.fromJson),
      successLog: 'Stations fetched',
      emptyLog: 'No stations',
    );
    return r.when(
      ok: (d) => Result.ok(d ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<StationDTO?>> createStation(StationDTO dto) {
    return createRequest<StationDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(StationDTO.fromJson),
      successLog: 'Station created',
    );
  }

  @override
  Future<Result<void>> updateStation(StationDTO dto) {
    if (dto.id == null) {
      return Future.value(Result.error(CustomException(message: 'updateStation: id is null')));
    }
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Station updated',
    );
  }

  @override
  Future<Result<void>> deleteStation(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Station deleted',
    );
  }

  @override
  Future<Result<void>> updateStationMacAddress(int stationId) async {
    final macAddress = await DeviceInfo.getMacAddress();
    return updateRequest(
      path: '$_basePath/macAddress/$stationId?macAddress=$macAddress',
      parser: voidParser(),
      successLog: 'Station updated',
    );
  }

  @override
  Future<Result<StationDTO?>> getStation(int stationId) async {
    final r = await fetchRequest<StationDTO>(
      path: '$_basePath/$stationId',
      parser: singleParser(StationDTO.fromJson),
    );
    return r.when(
      ok: (d) => Result.ok(d),
      error: Result.error,
    );
  }

  @override
  Future<Result<StationDTO?>> getCurrentStation() async {
    final r = await fetchRequest<StationDTO>(
      path: '$_basePath/currentStation',
      parser: singleParser(StationDTO.fromJson),
    );
    return r.when(
      ok: (d) => Result.ok(d),
      error: Result.error,
    );
  }
}
