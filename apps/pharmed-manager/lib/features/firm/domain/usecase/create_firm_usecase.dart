import '../../../../core/core.dart';

import '../entity/firm.dart';
import '../repository/i_firm_repository.dart';

class CreateFirmUseCase extends UseCase<Firm?, Firm> {
  final IFirmRepository repository;

  CreateFirmUseCase(this.repository);

  @override
  Future<Result<Firm?>> call(Firm firm) {
    return repository.createFirm(firm);
  }
}
