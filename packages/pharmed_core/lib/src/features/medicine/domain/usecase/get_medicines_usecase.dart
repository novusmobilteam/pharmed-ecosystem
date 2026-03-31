// [SWREQ-CORE-MEDICINE-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetMedicinesParams {
  final int? skip;
  final int? take;
  final String? search;

  GetMedicinesParams({this.skip, this.take, this.search});
}

class GetMedicinesUseCase {
  final IMedicineRepository _repository;

  GetMedicinesUseCase(this._repository);

  Future<Result<ApiResponse<List<Medicine>>>> call(GetMedicinesParams params) {
    return _repository.getMedicines(skip: params.skip, take: params.take, search: params.search);
  }
}
