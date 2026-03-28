import '../../../../core/core.dart';

import '../entity/unit.dart';
import '../repository/i_unit_repository.dart';

class UpdateUnitUseCase extends UseCase<void, Unit> {
  final IUnitRepository repository;

  UpdateUnitUseCase(this.repository);

  @override
  Future<Result<void>> call(Unit unit) {
    return repository.updateUnit(unit);
  }
}
