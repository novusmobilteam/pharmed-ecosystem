import '../../../../core/core.dart';
import '../../domain/entity/medicine_withdraw_item.dart';
import '../../domain/entity/patient_medicine_withdraw_item.dart';
import '../../domain/repository/i_medicine_withdraw_repository.dart';
import '../datasource/medicine_withdraw_datasource.dart';

class MedicineWithdrawRepository implements IMedicineWithdrawRepository {
  final MedicineWithdrawDataSource _ds;

  MedicineWithdrawRepository(this._ds);

  @override
  Future<Result<void>> checkFreeWithdraw(Map<String, dynamic> data) async {
    return await _ds.checkFreeWithdraw(data);
  }

  @override
  Future<Result<void>> checkOrderedWithdraw(Map<String, dynamic> data) async {
    return await _ds.checkOrderedWithdraw(data);
  }

  @override
  Future<Result<void>> checkOrderlessWithdraw(Map<String, dynamic> data) async {
    return await _ds.checkOrderlessWithdraw(data);
  }

  @override
  Future<Result<void>> completeFreeWithdraw(Map<String, dynamic> data) async {
    return await _ds.completeFreeWithdraw(data);
  }

  @override
  Future<Result<void>> completeOrderedWithdraw(Map<String, dynamic> data) async {
    return await _ds.completeOrderedWithdraw(data);
  }

  @override
  Future<Result<void>> completeOrderlessWithdraw(Map<String, dynamic> data) async {
    return await _ds.completeOrderlessWithdraw(data);
  }

  @override
  Future<Result<List<PatientMedicineWithdrawItem>>> getPatientMedicines({required int hospitalizationId}) async {
    final res = await _ds.getPatientMedicines(hospitalizationId: hospitalizationId);
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
  Future<Result<List<MedicineWithdrawItem>>> getWithdrawItems({required int hospitalizationId}) async {
    final res = await _ds.getWithdrawItems(hospitalizationId: hospitalizationId);
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
  Future<Result<void>> withdrawPatientMedicine({required int id}) async {
    return await _ds.withdrawPatientMedicine(id: id);
  }

  @override
  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data) async {
    return await _ds.definePatientMedicine(data);
  }
}
