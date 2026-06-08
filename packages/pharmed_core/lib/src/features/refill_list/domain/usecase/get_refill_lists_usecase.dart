import 'package:pharmed_core/pharmed_core.dart';

class GetRefillListsUseCase {
  final IRefillListRepository _repository;

  GetRefillListsUseCase(this._repository);

  Future<Result<List<RefillList>>> call(int stationId) async {
    return _repository.getFillingLists(stationId);
  }
}
