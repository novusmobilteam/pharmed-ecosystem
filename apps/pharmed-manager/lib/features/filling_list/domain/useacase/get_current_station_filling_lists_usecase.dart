import '../../../../core/core.dart';

import '../entity/filling_list.dart';
import '../repository/i_filling_list_repository.dart';

class GetCurrentStationFillingListsUseCase implements NoParamsUseCase<List<FillingList>> {
  final IFillingListRepository _repository;

  GetCurrentStationFillingListsUseCase(this._repository);

  @override
  Future<Result<List<FillingList>>> call() async {
    return _repository.getCurrentStationFillingLists();
  }
}
