import '../../../../core/core.dart';
import '../../domain/entity/dosage_form.dart';
import '../../domain/repository/i_dosage_form_repository.dart';
import '../datasource/dosage_form_datasource.dart';

class DosageFormRepository implements IDosageFormRepository {
  final DosageFormDataSource _ds;

  DosageFormRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<DosageForm>>>> getDosageForms({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await _ds.getDosageForms(
      skip: skip,
      take: take,
      search: search,
    );
    return res.when(
      ok: (response) {
        List<DosageForm> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(ApiResponse<List<DosageForm>>(
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
  Future<Result<void>> createDosageForm(DosageForm entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createDosageForm(dto);

    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateDosageForm(DosageForm entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateDosageForm(dto);

    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteDosageForm(int id) async {
    final res = await _ds.deleteDosageForm(id);
    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }
}
