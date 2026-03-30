// [SWREQ-CORE-DOSAGE-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateDosageFormUseCase {
  final IDosageFormRepository repository;

  CreateDosageFormUseCase(this.repository);

  Future<Result<void>> call(DosageForm dosageForm) {
    return repository.createDosageForm(dosageForm);
  }
}
