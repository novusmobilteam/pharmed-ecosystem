import '../../../../core/core.dart';

import '../entity/filling_list.dart';
import '../repository/i_filling_list_repository.dart';

class GetFillingListsUseCase implements UseCase<List<FillingList>, int> {
  final IFillingListRepository _repository;

  GetFillingListsUseCase(this._repository);

  @override
  Future<Result<List<FillingList>>> call(int stationId) async {
    return _repository.getFillingLists(stationId);
  }
}
