import '../../../../core/core.dart';

import '../entity/service.dart';
import '../repository/i_service_repository.dart';

class GetServicesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetServicesParams({this.skip, this.take, this.search});
}

class GetServicesUseCase implements UseCase<ApiResponse<List<HospitalService>>, GetServicesParams> {
  final IServiceRepository _repository;

  GetServicesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<HospitalService>>>> call(GetServicesParams params) {
    return _repository.getServices(skip: params.skip, take: params.take, search: params.search);
  }
}
