import '../../../../core/core.dart';
import '../model/service_dto.dart';
import 'service_data_source.dart';

/// Hastane Servisi işlemleri için uzak (API) veri kaynağı.
class ServiceRemoteDataSource extends BaseRemoteDataSource implements ServiceDataSource {
  final String _basePath = '/Service';

  ServiceRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<ServiceDTO>>>> getServices({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<ServiceDTO>>>(
      path: _basePath,
      // skip: skip,
      // take: take,
      // searchText: search,
      // searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(ServiceDTO.fromJson),
      successLog: 'Hospital services fetched',
      emptyLog: 'No hospital services',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createService(ServiceDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Hospital service created',
    );
  }

  @override
  Future<Result<void>> updateService(ServiceDTO dto) {
    if (dto.id == null) {
      return Future.value(
        Result.error(CustomException(message: 'updateService: id is null')),
      );
    }
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Hospital service updated',
    );
  }

  @override
  Future<Result<void>> deleteService(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Hospital service deleted',
    );
  }
}
