import '../../../../core/core.dart';
import '../../domain/entity/unit.dart';
import '../datasource/unit_datasource.dart';
import '../../domain/repository/i_unit_repository.dart';

class UnitRepository implements IUnitRepository {
  final UnitDataSource _ds;

  UnitRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Unit>>>> getUnits({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getUnits();
    return res.when(
      ok: (response) {
        List<Unit> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(ApiResponse<List<Unit>>(
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
  Future<Result<void>> createUnit(Unit entity) async {
    final dto = entity.toDTO();
    return await _ds.createUnit(dto);
  }

  @override
  Future<Result<void>> updateUnit(Unit entity) async {
    final dto = entity.toDTO();
    return await _ds.updateUnit(dto);
  }

  @override
  Future<Result<void>> deleteUnit(Unit unit) async {
    final id = unit.id ?? 0;
    return await _ds.deleteUnit(id);
  }
}
