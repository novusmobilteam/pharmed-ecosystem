import '../../../../core/core.dart';

import '../entity/service.dart';

import '../repository/i_service_repository.dart';

class CreateServiceUseCase extends UseCase<void, HospitalService> {
  final IServiceRepository _repository;

  CreateServiceUseCase(this._repository);

  @override
  Future<Result<void>> call(HospitalService params) {
    return _repository.createService(params);
  }
}
