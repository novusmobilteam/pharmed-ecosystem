import '../../../../core/core.dart';

import '../entity/warning.dart';
import '../repository/i_warning_repository.dart';

class UpdateWarningUseCase extends UseCase<void, Warning> {
  final IWarningRepository repository;

  UpdateWarningUseCase(this.repository);

  @override
  Future<Result<void>> call(Warning warning) {
    return repository.updateWarning(warning);
  }
}
