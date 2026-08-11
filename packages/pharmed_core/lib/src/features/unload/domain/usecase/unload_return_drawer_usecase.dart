import 'package:pharmed_core/pharmed_core.dart';

class UnloadReturnDrawerUseCase {
  const UnloadReturnDrawerUseCase(this._repository);

  final IUnloadRepository _repository;

  Future<Result<void>> call(List<int> medicineIds) => _repository.unloadReturnDrawer(medicineIds);
}
