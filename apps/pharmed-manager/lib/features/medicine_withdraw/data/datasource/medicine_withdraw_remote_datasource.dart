import '../model/medicine_withdraw_item_dto.dart';

import '../../../../core/core.dart';
import '../model/patient_medicine_withdraw_item_dto.dart';
import 'medicine_withdraw_datasource.dart';

class MedicineWithdrawRemoteDataSource extends BaseRemoteDataSource implements MedicineWithdrawDataSource {
  MedicineWithdrawRemoteDataSource({required super.apiManager});

  @override
  Future<Result<void>> checkFreeWithdraw(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/PatientIndependentMaterial/check',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> checkOrderedWithdraw(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Prescription/detail/checkCollect',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> checkOrderlessWithdraw(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Prescription/detail/OrderlessCollectCheck',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> completeFreeWithdraw(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/PatientIndependentMaterial',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> completeOrderedWithdraw(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Prescription/detail/collect',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> completeOrderlessWithdraw(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Prescription/detail/OrderlessCollect',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> definePatientMedicine(Map<String, dynamic> data) async {
    final res = await createRequest(
      path: '/Patient/otherDrug',
      parser: voidParser(),
      body: data,
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<MedicineWithdrawItemDTO>>> getWithdrawItems({required int hospitalizationId}) async {
    final res = await fetchRequest<List<MedicineWithdrawItemDTO>>(
      path: '/Prescription/detail/getCollect/$hospitalizationId',
      parser: listParser(MedicineWithdrawItemDTO.fromJson),
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <MedicineWithdrawItemDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> withdrawPatientMedicine({required int id}) async {
    final res = await createRequest(
      path: '/Patient/otherDrugCollect/$id',
      parser: voidParser(),
    );
    return res.when(
      ok: (data) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<PatientMedicineWithdrawItemDTO>>> getPatientMedicines({required int hospitalizationId}) async {
    final res = await fetchRequest<List<PatientMedicineWithdrawItemDTO>>(
      path: '/Patient/otherDrug/$hospitalizationId',
      parser: listParser(PatientMedicineWithdrawItemDTO.fromJson),
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <PatientMedicineWithdrawItemDTO>[]),
      error: Result.error,
    );
  }
}
