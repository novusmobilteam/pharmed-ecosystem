import '../../../../core/core.dart';
import '../../domain/entity/drug_class.dart';
import '../datasource/drug_class_datasource.dart';
import '../../domain/repository/i_drug_class_repository.dart';

class DrugClassRepository implements IDrugClassRepository {
  final DrugClassDataSource _ds;

  DrugClassRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<DrugClass>>>> getDrugClasses({
    int? skip,
    int? take,
    String? search,
  }) async {
    final r = await _ds.getDrugClasses(
      skip: skip,
      take: take,
      search: search,
    );
    return r.when(
      ok: (response) {
        List<DrugClass> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<DrugClass>>(
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
  Future<Result<void>> createDrugClass(DrugClass entity) async {
    final dto = entity.toDTO();
    final r = await _ds.createDrugClass(dto);

    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateDrugClass(DrugClass entity) async {
    final dto = entity.toDTO();
    final r = await _ds.updateDrugClass(dto);

    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteDrugClass(DrugClass item) async {
    final id = item.id;
    if (id == null) return Result.error(CustomException(message: 'deleteDrugClass: id is null'));

    final r = await _ds.deleteDrugClassById(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }
}
