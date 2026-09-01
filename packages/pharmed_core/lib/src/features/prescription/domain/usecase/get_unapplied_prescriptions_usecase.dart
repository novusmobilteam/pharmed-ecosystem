import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnappliedPrescriptionsUseCase {
  final IPrescriptionRepository _repository;

  GetUnappliedPrescriptionsUseCase(this._repository);

  Future<Result<ApiResponse<List<Prescription>>?>> call({PagedQueryParams? params}) {
    return _repository.getUnappliedPrescriptions(params: params);
  }
}

class GetOverduePrescriptionsUseCase {
  final IPrescriptionRepository _repository;

  GetOverduePrescriptionsUseCase(this._repository);

  Future<Result<ApiResponse<List<Prescription>>?>> call({PagedQueryParams? params}) {
    return _repository.getOverduePrescripitons(params: params);
  }
}
