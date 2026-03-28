import '../../../../core/core.dart';
import '../../domain/entity/drug_type.dart';
import '../datasource/drug_type_datasource.dart';
import '../../domain/repository/i_drug_type_repository.dart';

class DrugTypeRepository implements IDrugTypeRepository {
  final DrugTypeDataSource _ds;

  DrugTypeRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<DrugType>>>> getDrugTypes({int? skip, int? take, String? search}) async {
    final res = await _ds.getDrugTypes();
    return res.when(
      ok: (response) {
        List<DrugType> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<DrugType>>(
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
  Future<Result<void>> createDrugType(DrugType entity) async {
    return await _ds.createDrugType(entity.toDto());
  }

  @override
  Future<Result<void>> updateDrugType(DrugType entity) async {
    return await _ds.updateDrugType(entity.toDto());
  }

  @override
  Future<Result<void>> deleteDrugType(DrugType type) async {
    final res = await _ds.deleteDrugType(type.id ?? 0);
    return res.when(
      ok: Result.ok,
      error: Result.error,
    );
  }
}
