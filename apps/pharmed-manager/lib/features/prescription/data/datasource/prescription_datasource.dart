import '../../../../core/core.dart';
import '../model/prescription_dto.dart';
import '../model/prescription_item_dto.dart';
import '../model/prescription_other_request_dto.dart';

/// Reçete (Prescription) işlemleri için veri kaynağı arayüzü.
abstract class PrescriptionDataSource {
  /// Reçete oluşturma servisi
  Future<Result<PrescriptionDTO?>> createPrescription(PrescriptionDTO dto);

  /// Reçete içeriği oluşturma servisi. Önce [createPrescription] servisi ile reçete
  /// oluşturuluyor. Ardından o servisten gelen id ile bu servis çalıştırılıyor ve reçete
  /// içeriği dolduruluyor. (I know its weird but...)
  Future<Result<void>> createPrescriptionDetail(List<PrescriptionItemDTO> items);

  /// Hastaya ait reçeteleri yatış id ile getiren servis.
  Future<Result<List<PrescriptionDTO>>> getPatientPrescriptions(int hospitalizationId);

  /// Hastaya ait reçetelerin detayını getiren servis.(Hangi ilaçlar yazılmış vs.)
  Future<Result<List<PrescriptionItemDTO>>> getPrescriptionDetail(int prescriptionId);

  /// Hastaya ait geçmiş reçete detaylarını getiren servis.
  Future<Result<List<PrescriptionItemDTO>>> getPatientPrescriptionHistory(int patientId);

  /// [Diğer İstem] oluşturmak için kullanılan servis.
  Future<Result<PrescriptionOtherRequestDTO?>> createOtherRequest(PrescriptionOtherRequestDTO dto);

  /// Reçete içeriğinde yer alan talepleri onaylama servisi
  Future<Result<void>> approvePrescriptionRequests(int prescriptionId, List<int> ids);

  /// Reçete içeriğinde yer alan talepleri reddetme servisi
  Future<Result<void>> rejectPrescriptionRequests(int prescriptionId, List<int> ids);

  /// Reçete içeriğinde yer alan talepleri iptal etme servisi
  Future<Result<void>> cancelPrescriptionRequests(int prescriptionId, List<int> ids);

  /// Reçete içeriğini güncelleme servisi. Genelde ilgili ilacın uygulama saatini falan
  /// güncellemek için kullanılıyor.
  Future<Result<void>> updatePrescriptionItem(PrescriptionItemDTO dto);

  /// Reçete silme servisi
  Future<Result<void>> deletePrescription(int prescriptionId);

  /// Okutulmayan Karekodları sayfalı listeler.
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getUnscannedBarcodes({int? skip, int? take, String? search});

  /// Okutulan Karekodları sayfalı listeler.
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getScannedBarcodes({int? skip, int? take, String? search});

  /// Silinen Karekodları sayfalı listeler.
  Future<Result<ApiResponse<List<PrescriptionItemDTO>>>> getDeletedBarcodes({int? skip, int? take, String? search});

  /// Karekod uyarı aç/kapat
  Future<Result<void>> toggleWarning(int prescriptionId);

  /// Karekod Gir
  Future<Result<void>> scanBarcode({required int prescriptionItemId, required String qrCode});

  /// Okutulmayan karekod sil
  Future<Result<void>> deleteUnscannedBarcode({required int prescriptionItemId, required String description});

  /// Uygulanmamış Reçeteleri sayfalı listeler.
  Future<Result<ApiResponse<List<PrescriptionDTO>>>> getUnappliedPrescriptions({int? skip, int? take, String? search});
  Future<Result<List<PrescriptionItemDTO>>> getUnappliedPrescriptionDetail(int prescriptionId);

  /// Kabine ait? ilaç aktivitelerini getiren servis.
  Future<Result<List<PrescriptionItemDTO>>> getMedicineActivities();

  /// Acil Hasta'ya ataması yapılmış ilaçları getiren servis.
  Future<Result<List<PrescriptionItemDTO>>> getEmergencyPatientMedicines(int hospitalizationId);

  /// Hastalarım'a gün içinde yazılmış olan ilaçları getiren servis(Günlük İş Listesi).
  Future<Result<List<PrescriptionItemDTO>>> getDailyJobList();
}
