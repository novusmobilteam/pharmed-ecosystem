import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IHospitalizationRepository {
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizations({
    int? skip,
    int? take,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Result<ApiResponse<List<Hospitalization>>>> getActiveHospitalizations({
    int? skip,
    int? take,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Result<void>> createHospitalization(Hospitalization item);
  Future<Result<void>> updateHospitalization(Hospitalization item);
  Future<Result<void>> deleteHospitalization(Hospitalization item);

  /// Kabinde, reçetesi yazılmış hastaları getiren servis. İlaç Alım işlemi
  /// bu servis ile başlıyor.
  Future<Result<List<Hospitalization>>> getPatientsWithActivePrescription();

  Future<Result<List<Hospitalization>>> getFilteredHospitalizations(PatientFilterType filter);

  Future<Result<List<Hospitalization>>> getHospitalizationsByService(int serviceId);
}
