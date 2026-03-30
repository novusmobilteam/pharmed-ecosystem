// [SWREQ-CORE-SERVICE-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteServiceUseCase {
  const DeleteServiceUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<void>> call(HospitalService service) => _repository.deleteService(service);
}
