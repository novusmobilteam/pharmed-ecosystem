import 'package:pharmed_core/pharmed_core.dart';

class SolveInconsistencyUseCase {
  final IInconsistencyRepository _repository;

  SolveInconsistencyUseCase(this._repository);

  Future<Result<void>> call(int inconsistencyId, {required String description}) async {
    return _repository.solveInconsistency(inconsistencyId, description: description);
  }
}
