// [SWREQ-CORE-FIRM-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteFirmUseCase {
  final IFirmRepository repository;

  DeleteFirmUseCase(this.repository);

  Future<Result<void>> call(Firm firm) {
    return repository.deleteFirm(firm);
  }
}
