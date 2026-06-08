import 'package:pharmed_core/pharmed_core.dart';

import 'create_refill_list_usecase.dart';

class UpdateRefillListUseCase {
  final IRefillListRepository _repository;

  UpdateRefillListUseCase(this._repository);

  Future<Result<void>> call(List<SubmitRefillListParams> params) async {
    final data = params.map((p) => p.toJson()).toList();
    final stationId = params.first.stationId;
    final fillingListId = params.first.fillingListId;

    return _repository.updateFillingList(data, stationId: stationId, fillingListId: fillingListId!);
  }
}
