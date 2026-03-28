import '../../../../core/core.dart';
import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../domain/repository/i_medicine_management_repository.dart';
import '../datasource/medicine_management_datasource.dart';

class MedicineManagementRepository implements IMedicineManagementRepository {
  final MedicineManagementDataSource _ds;

  MedicineManagementRepository(this._ds);

  @override
  Future<Result<List<PrescriptionItem>>> getDisposables({required int hospitalizationId}) async {
    final res = await _ds.getDisposables(hospitalizationId: hospitalizationId);
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
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
  Future<Result<List<CabinAssignment>>> getDisposableMaterials() async {
    final res = await _ds.getDisposableMaterials();
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }
}
