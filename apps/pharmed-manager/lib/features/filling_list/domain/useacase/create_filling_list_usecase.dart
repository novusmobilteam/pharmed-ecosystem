import '../../../../core/core.dart';

import '../repository/i_filling_list_repository.dart';

class SubmitFillingListParams {
  final int userId;
  final int stationId;
  final int medicineId;
  final num quantity;
  final int? fillingListId;

  SubmitFillingListParams({
    required this.userId,
    required this.stationId,
    required this.medicineId,
    required this.quantity,
    this.fillingListId,
  });

  Map<String, dynamic> toJson() {
    return {"userId": userId, "materialId": medicineId, "quantity": quantity};
  }
}

class CreateFillingListUseCase implements UseCase<void, List<SubmitFillingListParams>> {
  final IFillingListRepository _repository;

  CreateFillingListUseCase(this._repository);

  @override
  Future<Result<void>> call(List<SubmitFillingListParams> params) async {
    final data = params.map((p) => p.toJson()).toList();
    final stationId = params.first.stationId;
    return _repository.createFillingList(data, stationId: stationId);
  }
}
