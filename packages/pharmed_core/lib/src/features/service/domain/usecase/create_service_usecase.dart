// [SWREQ-CORE-SERVICE-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateServiceUseCase {
  const CreateServiceUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<void>> call(HospitalService service) => _repository.createService(service);
}
