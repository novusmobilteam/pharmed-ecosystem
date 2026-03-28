import '../../../../core/core.dart';
import '../../domain/entity/material_type.dart';
import '../../domain/repository/i_material_type_repository.dart';
import '../datasource/material_type_datasource.dart';

class MaterialTypeRepository implements IMaterialTypeRepository {
  final MaterialTypeDataSource _ds;

  MaterialTypeRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<MaterialType>>>> getMaterialTypes({int? skip, int? take, String? search}) async {
    final res = await _ds.getMaterialTypes(search: search, skip: skip, take: take);
    return res.when(
      ok: (response) {
        List<MaterialType> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(ApiResponse<List<MaterialType>>(
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
  Future<Result<void>> createMaterialType(MaterialType entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createMaterialType(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateMaterialType(MaterialType entity) async {
    final dto = entity.toDTO();
    final r = await _ds.updateMaterialType(dto);

    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteMaterialType(MaterialType type) async {
    final id = type.id;
    if (id == null) {
      return Result.error(CustomException(message: 'deleteMaterialType: id is null'));
    }
    final r = await _ds.deleteMaterialTypeById(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }
}
