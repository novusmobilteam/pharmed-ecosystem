import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IPatientRepository {
  Future<Result<ApiResponse<List<Patient>>>> getPatients({int? skip, int? take, String? search});

  Future<Result<Patient?>> createPatient(Patient patient);
  Future<Result<void>> updatePatient(Patient patient);
  Future<Result<void>> deletePatient(Patient patient);

  /// Acil hasta sonlandırma servisi
  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  });

  Future<Result<List<MyPatient>>> getMyPatients();
  Future<Result<void>> addPatient(int userId, int hospitalizationId);
  Future<Result<void>> addPatients(List<Map<String, dynamic>> data);
  Future<Result<void>> removePatient(int id);
  Future<Result<void>> removePatients(List<int> ids);

  /// Yatış yapmış ya da maks 1 gün önce çıkış yapmış hastaları getiren servis
  /// Hasta İstem İncele ekranında kullanılıyor
  Future<Result<List<Patient>>> getHospitalizedAndRecentExits();

  Future<Result<Hospitalization?>> createUrgentPatient(int serviceId);

  /// Acil hastaları getiren servis
  Future<Result<List<UrgentPatient>>> getUrgentPatients();
}
