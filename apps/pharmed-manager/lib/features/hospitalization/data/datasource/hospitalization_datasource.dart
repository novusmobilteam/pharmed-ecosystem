import '../../../../core/core.dart';
import '../model/hospitalization_dto.dart';

/// Hasta Yatış (Hospitalization) işlemleri için veri kaynağı arayüzü.
abstract class HospitalizationDataSource {
  /// Hasta yatışlarını sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<HospitalizationDTO>>>> getHospitalizations({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni yatış oluşturma servisi
  Future<Result<void>> createHospitalization(HospitalizationDTO dto);

  /// Mevcut yatışı güncelleme servisi
  Future<Result<void>> updateHospitalization(HospitalizationDTO dto);

  /// Yatış silme servisi
  Future<Result<void>> deleteHospitalization(int id);

  /// Reçete İşlemleri'nde gösterilecek hastaları getiren servis
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsWithPrescription();

  /// Kabinde, reçetesi yazılmış hastaları getiren servis. İlaç Alım işlemi
  /// bu servis ile başlıyor.
  Future<Result<List<HospitalizationDTO>>> getPatientsWithActivePrescription();

  Future<Result<List<HospitalizationDTO>>> getFilteredHospitalizations(PatientFilterType filter);

  Future<Result<List<HospitalizationDTO>>> getHospitalizationsByService(int serviceId);
}
