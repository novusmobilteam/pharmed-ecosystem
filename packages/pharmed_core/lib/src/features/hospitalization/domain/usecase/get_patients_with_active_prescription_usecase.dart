import 'package:pharmed_core/pharmed_core.dart';

class GetPatientsWithActivePrescriptionUseCase {
  final IHospitalizationRepository _repository;

  GetPatientsWithActivePrescriptionUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call() {
    return _repository.getPatientsWithActivePrescription();
  }
}
