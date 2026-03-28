import '../../../../core/core.dart';
import '../../domain/entity/medicine.dart';
import '../../domain/repository/i_medicine_repository.dart';
import '../datasource/medicine_datasource.dart';

class MedicineRepository implements IMedicineRepository {
  final MedicineDataSource _ds;

  MedicineRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Medicine>>>> getMedicines({int? skip, int? take, String? search}) async {
    final res = await _ds.getMedicines(skip: skip, take: take, search: search);

    return res.when(
      ok: (response) {
        List<Medicine> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(
          ApiResponse<List<Medicine>>(
            data: entities,
            statusCode: response.statusCode,
            isSuccess: response.isSuccess,
            totalCount: response.totalCount,
            groupCount: response.groupCount,
          ),
        );
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Medicine>>>> getDrugs({int? skip, int? take, String? search}) async {
    final res = await _ds.getDrugs(skip: skip, take: take, search: search);
    return res.when(
      ok: (response) {
        List<Drug> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }
        return Result.ok(
          ApiResponse<List<Drug>>(
            data: entities,
            statusCode: response.statusCode,
            isSuccess: response.isSuccess,
            totalCount: response.totalCount,
            groupCount: response.groupCount,
          ),
        );
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Medicine>>>> getMedicalConsumables({int? skip, int? take, String? search}) async {
    final res = await _ds.getMedicalConsumables();
    return res.when(
      ok: (response) {
        List<MedicalConsumable> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(
          ApiResponse<List<MedicalConsumable>>(
            data: entities,
            statusCode: response.statusCode,
            isSuccess: response.isSuccess,
            totalCount: response.totalCount,
            groupCount: response.groupCount,
          ),
        );
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<ApiResponse<List<Medicine>>>> getEquivalentMedicines(int id) async {
    final res = await _ds.getEquivalentMedicines(id);
    return res.when(
      ok: (response) {
        List<Medicine> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(
          ApiResponse<List<Medicine>>(
            data: entities,
            statusCode: response.statusCode,
            isSuccess: response.isSuccess,
            totalCount: response.totalCount,
            groupCount: response.groupCount,
          ),
        );
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> createMedicine(Medicine medicine) async {
    return _ds.createMedicine(medicine.toDTO());
  }

  @override
  Future<Result<void>> deleteMedicine(Medicine medicine) async {
    return _ds.deleteMedicine(medicine.toDTO());
  }

  @override
  Future<Result<void>> updateMedicine(Medicine medicine) async {
    return _ds.updateMedicine(medicine.toDTO());
  }

  @override
  Future<Result<Drug?>> getDrug(int id) async {
    final res = await _ds.getDrug(id);
    return res.when(ok: (data) => Result.ok(data?.toEntity()), error: (error) => Result.error(error));
  }
}
