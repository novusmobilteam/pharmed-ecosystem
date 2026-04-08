import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ServiceRemoteDataSource extends BaseRemoteDataSource {
  ServiceRemoteDataSource({required super.apiManager});

  static const _base = '/Service';

  @override
  String get logSwreq => 'SWREQ-DATA-SERVICE-001';

  @override
  String get logUnit => 'SW-UNIT-SERVICE';

  Future<Result<ApiResponse<List<ServiceDTO>>?>> getServices({int? skip, int? take, String? search}) async {
    final res = await fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(ServiceDTO.fromJson),
      successLog: 'Servisler getirildi',
      emptyLog: 'Servis bulunamadı',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  Future<Result<void>> createService(ServiceDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Servis oluşturuldu',
    );
  }

  Future<Result<void>> updateService(ServiceDTO dto) {
    print(dto.toJson().toString());
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Servis güncellendi',
    );
  }

  Future<Result<void>> deleteService(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Servis silindi');
  }
}
