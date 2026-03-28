import '../../../../core/core.dart';

import '../entity/dosage_form.dart';
import '../repository/i_dosage_form_repository.dart';

class DeleteDosageFormUseCase extends UseCase<void, DosageForm> {
  final IDosageFormRepository repository;

  DeleteDosageFormUseCase(this.repository);

  @override
  Future<Result<void>> call(DosageForm dosageForm) {
    return repository.deleteDosageForm(dosageForm.id ?? 0);
  }
}
