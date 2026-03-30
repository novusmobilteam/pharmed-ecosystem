// [SWREQ-CORE-FIRM-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateFirmUseCase {
  final IFirmRepository repository;

  CreateFirmUseCase(this.repository);

  Future<Result<void>> call(Firm firm) {
    return repository.createFirm(firm);
  }
}
