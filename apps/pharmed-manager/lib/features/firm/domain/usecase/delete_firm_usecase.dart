import '../../../../core/core.dart';

import '../repository/i_firm_repository.dart';

class DeleteFirmParams {
  final int id;
  DeleteFirmParams(this.id);
}

class DeleteFirmUseCase extends UseCase<void, DeleteFirmParams> {
  final IFirmRepository repository;

  DeleteFirmUseCase(this.repository);

  @override
  Future<Result<void>> call(DeleteFirmParams params) {
    return repository.deleteFirm(params.id);
  }
}
