import 'package:pharmed_core/pharmed_core.dart';

class UpdateKitUseCase {
  final IKitRepository _repository;

  UpdateKitUseCase(this._repository);

  Future<Result<void>> call(Kit kit) {
    return _repository.updateKit(kit);
  }
}
