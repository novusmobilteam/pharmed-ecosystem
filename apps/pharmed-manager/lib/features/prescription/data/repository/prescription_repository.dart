import '../../../../core/core.dart';
import '../../domain/entity/prescription.dart';
import '../../domain/entity/prescription_item.dart';
import '../../domain/entity/prescription_other_request.dart';
import '../../domain/repository/i_prescription_repository.dart';
import '../datasource/prescription_datasource.dart';

class PrescriptionRepository implements IPrescriptionRepository {
  final PrescriptionDataSource _ds;

  PrescriptionRepository(this._ds);

  @override
  Future<Result<Prescription>> createPrescription(Prescription prescription) async {
    final dto = prescription.toDTO();

    final r = await _ds.createPrescription(dto);
    return r.when(
      ok: (saved) {
        return Result.ok((saved ?? dto).toEntity());
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getPrescriptionDetail(int registrationId) async {
    final r = await _ds.getPrescriptionDetail(registrationId);
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItem> items) async {
    final dtoList = items.map((e) => e.toDTO()).toList();

    final r = await _ds.createPrescriptionDetail(dtoList);
    return r.when(
      ok: (_) => const Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUnscannedBarcodes() async {
    final res = await _ds.getUnscannedBarcodes();
    return res.when(
      ok: (response) {
        List<PrescriptionItem> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getScannedBarcodes() async {
    final res = await _ds.getScannedBarcodes();
    return res.when(
      ok: (response) {
        List<PrescriptionItem> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getDeletedBarcodes() async {
    final res = await _ds.getDeletedBarcodes();
    return res.when(
      ok: (response) {
        List<PrescriptionItem> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode}) {
    return _ds.scanBarcode(
      prescriptionItemId: prescriptionItemId,
      qrCode: qrCode,
    );
  }

  @override
  Future<Result<List<Prescription>>> getUnappliedPrescriptions() async {
    final res = await _ds.getUnappliedPrescriptions();
    return res.when(
      ok: (response) {
        List<Prescription> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptionDetail(int prescriptionId) async {
    final r = await _ds.getUnappliedPrescriptionDetail(prescriptionId);
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<PrescriptionOtherRequest>> createOtherRequest(PrescriptionOtherRequest request) async {
    final dto = request.toDTO();
    final r = await _ds.createOtherRequest(dto);
    return r.when(
      ok: (saved) => Result.ok((saved ?? dto).toEntity()),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<Prescription>>> getPatientPrescriptions(int hospitalizationId) async {
    final r = await _ds.getPatientPrescriptions(hospitalizationId);
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _ds.approvePrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _ds.cancelPrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids) async {
    return await _ds.rejectPrescriptionRequests(prescriptionId, ids);
  }

  @override
  Future<Result<void>> updatePrescriptionItem(PrescriptionItem entity) async {
    return await _ds.updatePrescriptionItem(entity.toDTO());
  }

  @override
  Future<Result<void>> deletePrescription(int prescriptionId) async {
    return await _ds.deletePrescription(prescriptionId);
  }

  @override
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description}) async {
    return await _ds.deleteUnscannedBarcode(
      prescriptionItemId: prescriptionItemId,
      description: description,
    );
  }

  @override
  Future<Result<void>> toggleWarning(int prescriptionId) async {
    return await _ds.toggleWarning(prescriptionId);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getMedicineActivities() async {
    final r = await _ds.getMedicineActivities();
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getEmergencyPatientMedicines(int hospitalizationId) async {
    final r = await _ds.getEmergencyPatientMedicines(hospitalizationId);
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getDailyJobList() async {
    final r = await _ds.getDailyJobList();
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getPatientPrescriptionHistory(int patientId) async {
    final r = await _ds.getPatientPrescriptionHistory(patientId);
    return r.when(
      ok: (list) {
        final entities = (list).map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }
}
