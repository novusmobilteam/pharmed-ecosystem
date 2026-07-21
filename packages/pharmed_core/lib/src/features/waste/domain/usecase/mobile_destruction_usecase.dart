import 'package:pharmed_core/pharmed_core.dart';

class MobileDestructionUseCase {
  final IWasteRepository _repository;

  MobileDestructionUseCase(this._repository);

  Future<Result<void>> call(WasteParams params) async {
    return _repository.mobileDestruction(params.toJson());
  }
}
