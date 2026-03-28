import '../../../../core/core.dart';

import '../entity/unit.dart';
import '../repository/i_unit_repository.dart';

class CreateUnitUseCase extends UseCase<void, Unit> {
  final IUnitRepository repository;

  CreateUnitUseCase(this.repository);

  @override
  Future<Result<void>> call(Unit unit) {
    return repository.createUnit(unit);
  }
}
