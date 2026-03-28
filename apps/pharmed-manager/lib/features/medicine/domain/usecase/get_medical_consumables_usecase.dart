import '../../../../core/core.dart';

import '../entity/medicine.dart';
import '../repository/i_medicine_repository.dart';

class GetMedicalConsumablesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetMedicalConsumablesParams({this.skip, this.take, this.search});
}

class GetMedicalConsumablesUseCase implements UseCase<ApiResponse<List<Medicine>>, GetMedicalConsumablesParams> {
  final IMedicineRepository _repository;

  GetMedicalConsumablesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Medicine>>>> call(GetMedicalConsumablesParams params) {
    return _repository.getMedicines(skip: params.skip, take: params.take, search: params.search);
  }
}
