import '../../../../core/core.dart';
import '../model/material_type_dto.dart';
import 'material_type_datasource.dart';

class MaterialTypeRemoteDataSource extends BaseRemoteDataSource implements MaterialTypeDataSource {
  final String _basePath = '/MaterialType';

  MaterialTypeRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<MaterialTypeDTO>>>> getMaterialTypes({int? skip, int? take, String? search}) async {
    final res = await fetchRequest<ApiResponse<List<MaterialTypeDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(MaterialTypeDTO.fromJson),
      successLog: 'Material types fetched',
      emptyLog: 'No material types',
    );
    return res.when(
      ok: (data) => Result.ok(
        data ?? const ApiResponse(data: [], totalCount: 0),
      ),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createMaterialType(MaterialTypeDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Material type created',
    );
  }

  @override
  Future<Result<void>> updateMaterialType(MaterialTypeDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Material type updated',
    );
  }

  @override
  Future<Result<void>> deleteMaterialTypeById(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Material type deleted',
    );
  }
}
