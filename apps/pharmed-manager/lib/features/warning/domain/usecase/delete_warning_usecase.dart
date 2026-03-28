import '../../../../core/core.dart';

import '../entity/warning.dart';
import '../repository/i_warning_repository.dart';

class DeleteWarningUseCase extends UseCase<void, Warning> {
  final IWarningRepository repository;

  DeleteWarningUseCase(this.repository);

  @override
  Future<Result<void>> call(Warning warning) {
    return repository.deleteWarning(warning);
  }
}
