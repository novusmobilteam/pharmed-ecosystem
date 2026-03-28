import '../../../../core/core.dart';
import '../../../hospitalization/data/model/hospitalization_dto.dart';
import '../model/my_patient_dto.dart';
import '../model/patient_dto.dart';
import '../model/urgent_patient_dto.dart';

/// Hasta işlemleri için veri kaynağı arayüzü.
abstract class PatientDataSource {
  /// Hastaları sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<PatientDTO>>>> getPatients({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni hasta oluşturma servisi
  Future<Result<PatientDTO?>> createPatient(PatientDTO dto);

  /// Mevcut hasta güncelleme servisi
  Future<Result<void>> updatePatient(PatientDTO dto);

  /// Hasta silme işlemi
  Future<Result<void>> deletePatient(int id);

  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  });

  /// Giriş yapmış kullanıcıya ait hastaları çekme servisi
  Future<Result<List<MyPatientDTO>>> getMyPatients();

  /// Giriş yapmış kullanıcıya yeni hasta ekleme servisi
  Future<Result<void>> addPatient(int userId, int hospitalizationId);

  Future<Result<void>> addPatiens(List<Map<String, dynamic>> data);

  /// Giriş yapmış kullanıcı üzerindeki hastayı kaldırma servisi
  Future<Result<void>> removePatient(int id);

  /// Giriş yapmış kullanıcı üzerindeki hastaları kaldırma servisi
  Future<Result<void>> removePatients(List<int> ids);

  /// Yatış yapmış ya da maks 1 gün önce çıkış yapmış hastaları getiren servis
  /// Hasta İstem İncele ekranında kullanılıyor
  Future<Result<List<PatientDTO>>> getHospitalizedAndRecentExits();

  Future<Result<HospitalizationDTO?>> createUrgentPatient(int serviceId);

  /// Acil hastaları getiren servis
  Future<Result<List<UrgentPatientDTO>>> getUrgentPatients();
}
