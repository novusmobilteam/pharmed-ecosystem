// [SWREQ-CORE-SERVICE-UC-007]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetServiceUseCase {
  const GetServiceUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<HospitalService?>> call(int serviceId) => _repository.getService(serviceId);
}
