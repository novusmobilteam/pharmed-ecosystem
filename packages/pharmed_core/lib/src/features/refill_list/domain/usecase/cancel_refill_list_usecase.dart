import 'package:pharmed_core/pharmed_core.dart';

class CancelRefillListUseCase {
  final IRefillListRepository _repository;

  CancelRefillListUseCase(this._repository);

  Future<Result<void>> call(RefillList fillingList) async {
    final fillingListId = fillingList.id ?? 0;
    final stationId = fillingList.station?.id ?? 0;

    return _repository.cancelFillingList(fillingListId, stationId);
  }
}
