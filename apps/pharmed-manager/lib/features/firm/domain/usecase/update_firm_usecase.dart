import '../../../../core/core.dart';

import '../entity/firm.dart';
import '../repository/i_firm_repository.dart';

class UpdateFirmUseCase extends UseCase<void, Firm> {
  final IFirmRepository repository;

  UpdateFirmUseCase(this.repository);

  @override
  Future<Result<void>> call(Firm firm) {
    return repository.updateFirm(firm);
  }
}
