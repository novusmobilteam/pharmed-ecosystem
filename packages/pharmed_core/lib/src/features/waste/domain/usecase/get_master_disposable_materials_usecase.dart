import 'package:pharmed_core/pharmed_core.dart';

class GetMasterDisposableMaterialsUseCase {
  final IWasteRepository _repository;

  GetMasterDisposableMaterialsUseCase(this._repository);

  Future<Result<List<MedicineAssignment>>> call() {
    return _repository.getMasterDisposableMaterials();
  }
}
