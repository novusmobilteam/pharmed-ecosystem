import 'package:pharmed_core/pharmed_core.dart';

class CreateKitUseCase {
  final IKitRepository _repository;

  CreateKitUseCase(this._repository);

  Future<Result<void>> call(Kit kit) {
    return _repository.createKit(kit);
  }
}
