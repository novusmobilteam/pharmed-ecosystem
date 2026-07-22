import 'package:pharmed_core/pharmed_core.dart';

class UpdateSystemParametersUseCase {
  UpdateSystemParametersUseCase(this._repository);

  final ISettingsRepository _repository;

  Future<Result<void>> call(SystemParameter parameter) {
    return _repository.updateSystemParameter(parameter);
  }
}
