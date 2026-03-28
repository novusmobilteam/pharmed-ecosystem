import '../../../../core/core.dart';

import '../entity/service.dart';
import '../repository/i_service_repository.dart';

class UpdateServiceUseCase extends UseCase<void, HospitalService> {
  final IServiceRepository _repository;

  UpdateServiceUseCase(this._repository);

  @override
  Future<Result<void>> call(HospitalService params) {
    return _repository.updateService(params);
  }
}
