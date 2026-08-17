import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IHospitalizationRepository {
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizations(PagedQueryParams params);

  Future<Result<ApiResponse<List<Hospitalization>>>> getActiveHospitalizations(PagedQueryParams params);

  Future<Result<void>> createHospitalization(Hospitalization item);
  Future<Result<void>> updateHospitalization(Hospitalization item);
  Future<Result<void>> deleteHospitalization(Hospitalization item);

  /// Kabinde, reçetesi yazılmış hastaları getiren servis. İlaç Alım işlemi
  /// bu servis ile başlıyor.
  Future<Result<List<Hospitalization>>> getPatientsWithActivePrescription();

  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizationsByService(
    PagedQueryParams params, {
    required int serviceId,
    required PatientFilterType filter,
    bool myPatients = false,
  });

  /// Taburcu etme servisi
  Future<Result<void>> discharge(int hospitalizationId);
}
