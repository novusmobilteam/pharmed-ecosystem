// [SWREQ-CORE-UNIT-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateUnitUseCase {
  final IUnitRepository repository;

  UpdateUnitUseCase(this.repository);

  Future<Result<void>> call(Unit unit) {
    return repository.updateUnit(unit);
  }
}
