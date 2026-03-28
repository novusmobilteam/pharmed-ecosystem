import '../../../../core/core.dart';

import '../entity/dosage_form.dart';
import '../repository/i_dosage_form_repository.dart';

class CreateDosageFormUseCase extends UseCase<void, DosageForm> {
  final IDosageFormRepository repository;

  CreateDosageFormUseCase(this.repository);

  @override
  Future<Result<void>> call(DosageForm dosageForm) {
    return repository.createDosageForm(dosageForm);
  }
}
