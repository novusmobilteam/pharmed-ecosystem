import '../../../../core/core.dart';
import '../entity/prescription.dart';
import '../entity/prescription_item.dart';
import '../entity/prescription_other_request.dart';

abstract class IPrescriptionRepository {
  Future<Result<Prescription>> createPrescription(Prescription prescription);
  Future<Result<List<PrescriptionItem>>> getPrescriptionDetail(int prescriptionId);
  Future<Result<List<Prescription>>> getPatientPrescriptions(int hospitalizationId);
  Future<Result<List<PrescriptionItem>>> getPatientPrescriptionHistory(int patientId);
  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItem> items);

  Future<Result<PrescriptionOtherRequest>> createOtherRequest(PrescriptionOtherRequest request);

  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids);
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids);
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids);

  Future<Result<void>> updatePrescriptionItem(PrescriptionItem entity);
  Future<Result<void>> deletePrescription(int prescriptionId);

  // Okutulmayan Karekodlar
  Future<Result<List<PrescriptionItem>>> getUnscannedBarcodes();

  // Okutulan Karekodlar
  Future<Result<List<PrescriptionItem>>> getScannedBarcodes();

  // Silinen Karekodlar
  Future<Result<List<PrescriptionItem>>> getDeletedBarcodes();

  // Karekod uyarı aç/kapat
  Future<Result<void>> toggleWarning(int id);

  // Okutulmayan karekod barkod gir
  Future<Result<void>> scanBarcode({
    required int prescriptionItemId,
    required String qrCode,
  });

  // Okutulmayan Karekod sil
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description});

  // Uygulanmamış Reçeteler
  Future<Result<List<Prescription>>> getUnappliedPrescriptions();
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptionDetail(int prescriptionId);

  /// Kabine ait? ilaç aktivitelerini getiren servis.
  Future<Result<List<PrescriptionItem>>> getMedicineActivities();

  /// Acil Hasta'ya ataması yapılmış ilaçları getiren servis.
  Future<Result<List<PrescriptionItem>>> getEmergencyPatientMedicines(int hospitalizationId);

  /// Hastalarım'a gün içinde yazılmış olan ilaçları getiren servis(Günlük İş Listesi).
  Future<Result<List<PrescriptionItem>>> getDailyJobList();
}
