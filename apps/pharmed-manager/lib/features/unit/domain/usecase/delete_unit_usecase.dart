import '../../../../core/core.dart';

import '../entity/unit.dart';
import '../repository/i_unit_repository.dart';

class DeleteUnitUseCase extends UseCase<void, Unit> {
  final IUnitRepository repository;

  DeleteUnitUseCase(this.repository);

  @override
  Future<Result<void>> call(Unit unit) {
    return repository.deleteUnit(unit);
  }
}
