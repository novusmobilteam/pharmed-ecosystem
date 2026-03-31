// [SWREQ-CORE-DOSAGE-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteDosageFormUseCase {
  final IDosageFormRepository repository;

  DeleteDosageFormUseCase(this.repository);

  Future<Result<void>> call(DosageForm dosageForm) {
    return repository.deleteDosageForm(dosageForm);
  }
}
