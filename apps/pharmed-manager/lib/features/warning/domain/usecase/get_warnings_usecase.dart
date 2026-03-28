import '../../../../core/core.dart';

import '../entity/warning.dart';
import '../repository/i_warning_repository.dart';

class GetWarningsUseCase implements NoParamsUseCase<List<Warning>> {
  final IWarningRepository _repository;
  GetWarningsUseCase(this._repository);

  @override
  Future<Result<List<Warning>>> call() {
    return _repository.getWarnings();
  }
}
