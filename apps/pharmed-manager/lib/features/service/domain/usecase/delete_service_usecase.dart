import '../../../../core/core.dart';

import '../entity/service.dart';
import '../repository/i_service_repository.dart';

class DeleteServiceUseCase extends UseCase<void, HospitalService> {
  final IServiceRepository _repository;

  DeleteServiceUseCase(this._repository);

  @override
  Future<Result<void>> call(HospitalService params) {
    return _repository.deleteService(params);
  }
}
