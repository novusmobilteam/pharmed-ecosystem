import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetInconsistenciesUseCase {
  final IInconsistencyRepository _repository;

  GetInconsistenciesUseCase(this._repository);

  Future<Result<ApiResponse<List<Inconsistency>>>> call() {
    return _repository.getInconsistencies();
  }
}
