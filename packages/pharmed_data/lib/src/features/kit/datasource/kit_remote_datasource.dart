import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class KitRemoteDataSource extends BaseRemoteDataSource {
  KitRemoteDataSource({required super.apiManager});

  final String _base = '/Kit';

  @override
  String get logSwreq => 'SWREQ-DATA-KIT-001';

  @override
  String get logUnit => 'SW-UNIT-KIT';

  Future<Result<ApiResponse<List<KitDto>>>> getKits({int? skip, int? take, String? search}) async {
    final res = await fetchRequest<ApiResponse<List<KitDto>>>(
      path: _base,
      skip: skip,
      take: take,
      searchQuery: search,
      searchFields: ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(KitDto.fromJson),
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  Future<Result<void>> createKit(KitDto dto) {
    return postRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit oluşturuldu',
    );
  }

  Future<Result<void>> updateKit(KitDto dto) {
    return putRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit güncellendi',
    );
  }

  Future<Result<void>> deleteKit(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Kit silindi');
  }
}
