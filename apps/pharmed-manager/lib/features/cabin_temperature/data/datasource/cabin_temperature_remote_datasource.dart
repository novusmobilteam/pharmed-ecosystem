import '../../../../core/core.dart';
import '../model/cabin_temperature_dto.dart';
import '../model/cabin_temperature_detail_dto.dart';
import 'cabin_temperature_datasource.dart';

/// Kabin sıcaklık kontrol işlemleri için uzak (API) veri kaynağı.
class CabinTemperatureRemoteDataSource extends BaseRemoteDataSource
    implements CabinTemperatureDataSource {
  final String _basePath = '/CabinTemperatureControl';

  CabinTemperatureRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<CabinTemperatureDTO>>>> getCabinTemperatures({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<CabinTemperatureDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(CabinTemperatureDTO.fromJson),
      successLog: 'Cabin temperatures fetched',
      emptyLog: 'No cabin temperature',
    );

    return res.when(
      ok: (data) =>
          Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinTemperatureDetailDTO>>> getCabinTemperatureDetails(
      int stationId) async {
    final res = await fetchRequest<List<CabinTemperatureDetailDTO>>(
      path: '$_basePath/detail/station/$stationId',
      parser: listParser(CabinTemperatureDetailDTO.fromJson),
      successLog: 'Cabin temperatures fetched',
      emptyLog: 'No cabin temperature',
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <CabinTemperatureDetailDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<CabinTemperatureDTO?>> createCabinTemperature(
      CabinTemperatureDTO dto) {
    return createRequest<CabinTemperatureDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(CabinTemperatureDTO.fromJson),
      successLog: 'Cabin temperature created',
    );
  }

  @override
  Future<Result<CabinTemperatureDetailDTO?>> createCabinTemperatureDetail(
      CabinTemperatureDetailDTO dto) {
    return createRequest<CabinTemperatureDetailDTO?>(
      path: '$_basePath/detail',
      body: dto.toJson(),
      parser: singleParser(CabinTemperatureDetailDTO.fromJson),
      successLog: 'Cabin temperature detail created',
    );
  }

  @override
  Future<Result<CabinTemperatureDetailDTO?>> updateCabinTemperatureDetail(
      CabinTemperatureDetailDTO dto) {
    if (dto.id == null) {
      return Future.value(Result.error(
          CustomException(message: 'updateCabinTemperature: id is null')));
    }
    return updateRequest<CabinTemperatureDetailDTO?>(
      path: '$_basePath/detail/${dto.id}',
      body: dto.toJson(),
      parser: singleParser(CabinTemperatureDetailDTO.fromJson),
      successLog: 'Cabin temperature updated',
    );
  }

  @override
  Future<Result<void>> deleteCabinTemperatureDetail(int id) {
    return deleteRequest<void>(
      path: '$_basePath/detail/$id',
      parser: voidParser(),
      successLog: 'Cabin temperature deleted',
    );
  }
}
