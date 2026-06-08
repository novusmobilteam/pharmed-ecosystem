import 'package:pharmed_core/pharmed_core.dart';

class GetCurrentStationRefillListsUseCase {
  final IRefillListRepository _repository;

  GetCurrentStationRefillListsUseCase(this._repository);

  Future<Result<List<RefillList>>> call() async {
    return _repository.getCurrentStationFillingLists();
  }
}
