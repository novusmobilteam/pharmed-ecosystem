// [SWREQ-CORE-CABIN-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateCabinUseCase {
  final ICabinRepository _repository;

  UpdateCabinUseCase(this._repository);

  Future<Result<void>> call(Cabin cabin) async {
    return await _repository.updateCabin(cabin.copyWith());
  }
}
