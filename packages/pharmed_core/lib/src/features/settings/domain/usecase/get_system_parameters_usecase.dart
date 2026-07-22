import 'package:pharmed_core/pharmed_core.dart';

class GetSystemParametersUseCase {
  GetSystemParametersUseCase(this._repository);

  final ISettingsRepository _repository;

  Future<Result<List<SystemParameter>>> call() {
    return _repository.getSystemParameters();
  }
}
