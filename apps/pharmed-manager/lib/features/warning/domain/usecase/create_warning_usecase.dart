import '../../../../core/core.dart';

import '../entity/warning.dart';
import '../repository/i_warning_repository.dart';

class CreateWarningUseCase extends UseCase<void, Warning> {
  final IWarningRepository repository;

  CreateWarningUseCase(this.repository);

  @override
  Future<Result<void>> call(Warning warning) {
    return repository.createWarning(warning);
  }
}
