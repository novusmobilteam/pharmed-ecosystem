import '../../../../core/core.dart';

import '../entity/cabin.dart';
import '../repository/i_cabin_repository.dart';

class UpdateCabinUseCase implements UseCase<void, Cabin> {
  final ICabinRepository _repository;
  UpdateCabinUseCase(this._repository);

  @override
  Future<Result<void>> call(Cabin params) => _repository.updateCabin(params);
}
