import '../../../../core/core.dart';

import '../entity/filling_list.dart';
import '../repository/i_filling_list_repository.dart';

class CancelFillingListUseCase implements UseCase<void, FillingList> {
  final IFillingListRepository _repository;

  CancelFillingListUseCase(this._repository);

  @override
  Future<Result<void>> call(FillingList fillingList) async {
    final fillingListId = fillingList.id ?? 0;
    final stationId = fillingList.station?.id ?? 0;

    return _repository.cancelFillingList(fillingListId, stationId);
  }
}
