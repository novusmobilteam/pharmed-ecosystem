import 'package:pharmed_core/pharmed_core.dart';

class CreateWarningUseCase {
  final IWarningRepository repository;

  CreateWarningUseCase(this.repository);

  Future<Result<void>> call(Warning warning) {
    return repository.createWarning(warning);
  }
}
