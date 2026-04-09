import 'package:pharmed_core/pharmed_core.dart';

class UpdateWarningUseCase {
  final IWarningRepository repository;

  UpdateWarningUseCase(this.repository);

  Future<Result<void>> call(Warning warning) {
    return repository.updateWarning(warning);
  }
}
