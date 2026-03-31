// [SWREQ-CORE-UNIT-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteUnitUseCase {
  final IUnitRepository repository;

  DeleteUnitUseCase(this.repository);

  Future<Result<void>> call(Unit unit) {
    return repository.deleteUnit(unit);
  }
}
