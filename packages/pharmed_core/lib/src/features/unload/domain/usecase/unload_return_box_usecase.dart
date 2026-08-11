import 'package:pharmed_core/pharmed_core.dart';

class UnloadReturnBoxUseCase {
  const UnloadReturnBoxUseCase(this._repository);

  final IUnloadRepository _repository;

  Future<Result<void>> call(List<int> medicineIds) => _repository.unloadReturnBox(medicineIds);
}
