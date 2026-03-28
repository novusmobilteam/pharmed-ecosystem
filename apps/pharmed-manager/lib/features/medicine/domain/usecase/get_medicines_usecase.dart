import '../../../../core/core.dart';

import '../entity/medicine.dart';
import '../repository/i_medicine_repository.dart';

class GetMedicinesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetMedicinesParams({this.skip, this.take, this.search});
}

class GetMedicinesUseCase implements UseCase<ApiResponse<List<Medicine>>, GetMedicinesParams> {
  final IMedicineRepository _repository;

  GetMedicinesUseCase(this._repository);

  @override
  Future<Result<ApiResponse<List<Medicine>>>> call(GetMedicinesParams params) {
    return _repository.getMedicines(skip: params.skip, take: params.take, search: params.search);
  }
}
