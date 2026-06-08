import 'package:pharmed_core/pharmed_core.dart';

class UpdateRefillListStatusUseCase {
  final IRefillListRepository _repository;

  UpdateRefillListStatusUseCase(this._repository);

  Future<Result<void>> call(RefillList fillingList) async {
    final fillingListId = fillingList.id ?? 0;
    final stationId = fillingList.station?.id ?? 0;
    return _repository.updateFillingListStatus(fillingListId, stationId);
  }
}
