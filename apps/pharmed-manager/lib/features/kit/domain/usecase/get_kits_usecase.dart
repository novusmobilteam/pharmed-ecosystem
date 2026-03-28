import '../../../../core/core.dart';

import '../entity/kit.dart';
import '../repository/i_kit_repository.dart';

class GetKitsUseCase implements NoParamsUseCase<List<Kit>> {
  final IKitRepository _repository;

  GetKitsUseCase(this._repository);

  @override
  Future<Result<List<Kit>>> call() {
    return _repository.getKits();
  }
}
