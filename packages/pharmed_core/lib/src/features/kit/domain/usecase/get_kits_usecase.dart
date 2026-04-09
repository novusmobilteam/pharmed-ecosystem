import 'package:pharmed_core/pharmed_core.dart';

class GetKitsUseCase {
  final IKitRepository _repository;

  GetKitsUseCase(this._repository);

  Future<Result<List<Kit>>> call() {
    return _repository.getKits();
  }
}
