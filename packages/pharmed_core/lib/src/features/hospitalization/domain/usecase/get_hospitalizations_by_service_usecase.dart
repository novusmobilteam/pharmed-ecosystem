import 'package:pharmed_core/pharmed_core.dart';

class GetHospitalizationsByServiceUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsByServiceUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call({
    required int serviceId,
    required PatientFilterType filter,
    bool myPatients = false,
  }) {
    return _repository.getHospitalizationsByService(serviceId: serviceId, filter: filter, myPatients: myPatients);
  }
}

/// Alım ekranının "Diğer Servis" sekmesi: fiziki servisi aktif servis olan,
/// yatışı başka bir serviste görünen hastalar.
class GetOtherServiceHospitalizationsUseCase {
  final IHospitalizationRepository _repository;

  GetOtherServiceHospitalizationsUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call({required int serviceId, required PatientFilterType filter}) {
    return _repository.getOtherServiceHospitalizations(serviceId: serviceId, filter: filter);
  }
}
