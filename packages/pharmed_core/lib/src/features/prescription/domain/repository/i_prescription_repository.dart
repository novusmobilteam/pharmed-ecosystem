import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IPrescriptionRepository {
  Future<Result<Prescription?>> createPrescription(Prescription prescription);
  Future<Result<PrescriptionItem?>> getPrescriptionDetail(int prescriptionId);
  Future<Result<List<Prescription>>> getPatientPrescriptions(int hospitalizationId);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getPatientPrescriptionHistory(
    int patientId, {
    PagedQueryParams? params,
  });

  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItem> items);

  Future<Result<void>> checkPrescriptionRequests(int prescriptionId, List<int> ids);
  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids);
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids);
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids);
  Future<Result<void>> rejectApprovedRequests(int prescriptionId, List<int> ids);

  Future<Result<void>> updatePrescriptionItem(PrescriptionItem entity);
  Future<Result<void>> deletePrescription(int prescriptionId);

  // Okutulmayan Karekodlar
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getUnscannedBarcodes({PagedQueryParams? params});

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getUnscannedBarcodesWithStationId({
    PagedQueryParams? params,
    required int stationId,
  });

  // Okutulan Karekodlar
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getScannedBarcodes({
    PagedQueryParams? params,
    required int stationId,
  });

  // Silinen Karekodlar
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getDeletedBarcodes({
    PagedQueryParams? params,
    required int stationId,
  });

  // Karekod uyarı aç/kapat
  Future<Result<void>> toggleWarning(int id);

  // Okutulmayan karekod barkod gir
  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode});

  // Okutulmayan Karekod sil
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description});

  // Uygulanmamış Reçeteler
  Future<Result<ApiResponse<List<Prescription>>?>> getUnappliedPrescriptions({PagedQueryParams? params});
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptionDetail(int prescriptionId);
  // Geciken uygulamalar
  Future<Result<ApiResponse<List<Prescription>>?>> getOverduePrescripitons({PagedQueryParams? params});

  /// İlaç hareketlerini(dolum,alım,iade,fire/imha) getiren servis.
  Future<Result<List<PrescriptionItem>>> getDrugActivity();

  /// İşlem yapılan kabine ait hareketlerini(dolum,alım,iade,fire/imha) getiren servis.
  Future<Result<ApiResponse<List<PrescriptionItemMovement>>?>> getCurrentStationDrugActivity({
    PagedQueryParams? params,
  });

  /// Acil Hasta'ya ataması yapılmış ilaçları getiren servis.
  Future<Result<List<PrescriptionItem>>> getEmergencyPatientMedicines(int hospitalizationId);

  /// Hastalarım'a gün içinde yazılmış olan ilaçları getiren servis(Günlük İş Listesi).
  Future<Result<List<PrescriptionItem>>> getDailyJobList(int hospitalizationId);

  /// Reçete kalemine RFID etiketi atar.
  ///
  /// [prescriptionItemId] — kalem ID'si
  /// [epc]               — atanacak etiket EPC değeri (12 byte hex string)
  ///
  /// Başarılı olursa atanan [epc] değerini döner.
  Future<Result<String>> assignRfidTag({required int prescriptionItemId, required String epc});

  /// Reçete kalemine atanmış RFID etiketini siler.
  ///
  /// [prescriptionItemId] — kalem ID'si
  Future<Result<void>> deleteRfidTag({required int prescriptionItemId});

  /// Reçete detay objesine ait hareketleri getirir
  Future<Result<List<PrescriptionItemMovement>>> getPrescriptionItemMovements(int prescriptionItemId);
}
