// [SWREQ-CORE-UNIT-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateUnitUseCase {
  final IUnitRepository repository;

  CreateUnitUseCase(this.repository);

  Future<Result<void>> call(Unit unit) {
    return repository.createUnit(unit);
  }
}
