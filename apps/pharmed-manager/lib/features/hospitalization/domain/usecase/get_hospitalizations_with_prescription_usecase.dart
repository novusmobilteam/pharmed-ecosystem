import '../../../../core/core.dart';

import '../entity/hospitalization.dart';
import '../repository/i_hospitalization_repository.dart';

class GetHospitalizationsWithPrescriptionUseCase implements NoParamsUseCase<List<Hospitalization>> {
  final IHospitalizationRepository _repository;

  GetHospitalizationsWithPrescriptionUseCase(this._repository);

  @override
  Future<Result<List<Hospitalization>>> call() {
    return _repository.getHospitalizationsWithPrescription();
  }
}
