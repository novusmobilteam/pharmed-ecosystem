// [SWREQ-CORE-FIRM-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateFirmUseCase {
  final IFirmRepository repository;

  UpdateFirmUseCase(this.repository);

  Future<Result<void>> call(Firm firm) {
    return repository.updateFirm(firm);
  }
}
