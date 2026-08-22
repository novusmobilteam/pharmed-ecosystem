import 'package:pharmed_core/pharmed_core.dart';

class MasterDestructionUseCase {
  final IWasteRepository _repository;

  MasterDestructionUseCase(this._repository);

  Future<Result<void>> call(WasteParams params) async {
    return _repository.masterDestruction(params.toJson());
  }
}
