import '../../../../core/core.dart';

import '../entity/filling_list.dart';
import '../repository/i_filling_list_repository.dart';

class GetCurrentStationFillingListsUseCase {
  final IFillingListRepository _repository;

  GetCurrentStationFillingListsUseCase(this._repository);

  Future<Result<List<FillingList>>> call() async {
    return _repository.getCurrentStationFillingLists();
  }
}
