import '../../../../core/core.dart';
import '../model/unit_dto.dart';
import 'unit_datasource.dart';

class UnitRemoteDataSource extends BaseRemoteDataSource implements UnitDataSource {
  UnitRemoteDataSource({required super.apiManager});

  final String _basePath = '/UnitCode';

  @override
  Future<Result<ApiResponse<List<UnitDTO>>>> getUnits({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(UnitDTO.fromJson),
      successLog: 'Units fetched',
      emptyLog: 'No units',
    );

    return res.when(
      ok: (data) => Result.ok(
        data ?? const ApiResponse(data: [], totalCount: 0),
      ),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createUnit(UnitDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Unit created',
    );
  }

  @override
  Future<Result<void>> updateUnit(UnitDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Unit updated',
    );
  }

  @override
  Future<Result<void>> deleteUnit(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Unit deleted',
    );
  }
}
