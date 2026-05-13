import 'package:pharmed_core/pharmed_core.dart';

class MasterWastageUseCase {
  final IWasteRepository _repository;

  MasterWastageUseCase(this._repository);

  Future<Result<void>> call(WasteParams params) async {
    return _repository.masterWastage(params.toJson());
  }
}
