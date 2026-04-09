import 'package:pharmed_core/pharmed_core.dart';

class GetWarningsUseCase {
  final IWarningRepository _repository;
  GetWarningsUseCase(this._repository);

  Future<Result<List<Warning>>> call() {
    return _repository.getWarnings();
  }
}
