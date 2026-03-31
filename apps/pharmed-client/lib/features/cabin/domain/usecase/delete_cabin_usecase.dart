// [SWREQ-CORE-CABIN-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteCabinUseCase {
  final ICabinRepository _repository;

  DeleteCabinUseCase(this._repository);

  Future<Result<void>> call(Cabin cabin) => _repository.deleteCabin(cabin);
}
