import '../../../../core/core.dart';
import '../entity/hospitalization.dart';

abstract class IHospitalizationRepository {
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizations({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<void>> createHospitalization(Hospitalization item);
  Future<Result<void>> updateHospitalization(Hospitalization item);
  Future<Result<void>> deleteHospitalization(Hospitalization item);

  /// Reçete İşlemleri'nde gösterilecek hastaları getiren servis
  Future<Result<List<Hospitalization>>> getHospitalizationsWithPrescription();

  /// Kabinde, reçetesi yazılmış hastaları getiren servis. İlaç Alım işlemi
  /// bu servis ile başlıyor.
  Future<Result<List<Hospitalization>>> getPatientsWithActivePrescription();

  Future<Result<List<Hospitalization>>> getFilteredHospitalizations(PatientFilterType filter);

  Future<Result<List<Hospitalization>>> getHospitalizationsByService(int serviceId);
}
