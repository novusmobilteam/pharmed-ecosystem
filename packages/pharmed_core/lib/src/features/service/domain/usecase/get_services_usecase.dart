// [SWREQ-CORE-SERVICE-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetServicesParams {
  const GetServicesParams({this.skip, this.take, this.search});

  final int? skip;
  final int? take;
  final String? search;
}

class GetServicesUseCase {
  const GetServicesUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<ApiResponse<List<HospitalService>>>> call(GetServicesParams params) =>
      _repository.getServices(skip: params.skip, take: params.take, search: params.search);
}

class GetAllServicesUseCase {
  const GetAllServicesUseCase(this._repository);

  final IServiceRepository _repository;

  Future<Result<List<HospitalService>?>> call() => _repository.getAllServices();
}
