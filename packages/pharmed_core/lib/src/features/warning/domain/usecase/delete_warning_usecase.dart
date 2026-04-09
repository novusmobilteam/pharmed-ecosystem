import 'package:pharmed_core/pharmed_core.dart';

class DeleteWarningUseCase {
  final IWarningRepository repository;

  DeleteWarningUseCase(this.repository);

  Future<Result<void>> call(Warning warning) {
    return repository.deleteWarning(warning);
  }
}
