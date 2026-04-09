import 'package:pharmed_core/pharmed_core.dart';

class DeleteKitUseCase {
  final IKitRepository _repository;

  DeleteKitUseCase(this._repository);

  Future<Result<void>> call(Kit kit) {
    return _repository.deleteKit(kit);
  }
}
