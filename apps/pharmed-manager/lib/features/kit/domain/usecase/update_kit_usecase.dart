import '../../../../core/core.dart';

import '../entity/kit.dart';
import '../repository/i_kit_repository.dart';

class UpdateKitUseCase implements UseCase<void, Kit> {
  final IKitRepository _repository;

  UpdateKitUseCase(this._repository);

  @override
  Future<Result<void>> call(Kit kit) {
    return _repository.updateKit(kit);
  }
}
