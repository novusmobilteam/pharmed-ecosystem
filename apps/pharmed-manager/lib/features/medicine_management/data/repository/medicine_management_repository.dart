import '../../../../core/core.dart';
import '../../domain/repository/i_medicine_management_repository.dart';
import '../datasource/medicine_management_datasource.dart';

class MedicineManagementRepository implements IMedicineManagementRepository {
  final MedicineManagementDataSource _ds;

  MedicineManagementRepository(this._ds);

  @override
  Future<Result<List<PrescriptionItem>>> getDisposables({required int hospitalizationId}) async {
    final res = await _ds.getDisposables(hospitalizationId: hospitalizationId);
    return res.when(
      ok: (dtos) => Result.ok(PrescriptionItemMapper().toEntityList(dtos)),
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> destruction(Map<String, dynamic> data) async {
    return await _ds.destruction(data);
  }

  @override
  Future<Result<void>> wastage(Map<String, dynamic> data) async {
    return await _ds.wastage(data);
  }

  @override
  Future<Result<void>> disposeMaterial(List<Map<String, dynamic>> data) async {
    return await _ds.disposeMaterial(data);
  }

  @override
  Future<Result<List<MedicineAssignment>>> getDisposableMaterials() async {
    final res = await _ds.getDisposableMaterials();
    return res.when(
      ok: (dtos) => Result.ok(MedicineAssignmentMapper().toEntityList(dtos)),
      error: (e) => Result.error(e),
    );
  }
}
