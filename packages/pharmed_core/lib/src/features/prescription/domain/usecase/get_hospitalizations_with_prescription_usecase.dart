import 'package:pharmed_core/pharmed_core.dart';

class GetHospitalizationsWithPrescriptionUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsWithPrescriptionUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call() {
    return _repository.getHospitalizationsWithPrescription();
  }
}
