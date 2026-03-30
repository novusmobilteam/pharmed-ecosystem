// [SWREQ-CORE-SERVICE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateServiceUseCase {
  const UpdateServiceUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<void>> call(HospitalService service) => _repository.updateService(service);
}
