// [SWREQ-CORE-DOSAGE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateDosageFormUseCase {
  final IDosageFormRepository repository;

  UpdateDosageFormUseCase(this.repository);

  Future<Result<void>> call(DosageForm dosageForm) {
    return repository.updateDosageForm(dosageForm);
  }
}
