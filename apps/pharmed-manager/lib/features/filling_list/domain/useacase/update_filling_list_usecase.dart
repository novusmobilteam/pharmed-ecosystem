import '../../../../core/core.dart';

import '../repository/i_filling_list_repository.dart';
import 'create_filling_list_usecase.dart';

class UpdateFillingListUseCase implements UseCase<void, List<SubmitFillingListParams>> {
  final IFillingListRepository _repository;

  UpdateFillingListUseCase(this._repository);

  @override
  Future<Result<void>> call(List<SubmitFillingListParams> params) async {
    final data = params.map((p) => p.toJson()).toList();
    final stationId = params.first.stationId;
    final fillingListId = params.first.fillingListId;

    return _repository.updateFillingList(data, stationId: stationId, fillingListId: fillingListId!);
  }
}
