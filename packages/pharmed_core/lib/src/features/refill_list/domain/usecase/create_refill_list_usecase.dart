import 'package:pharmed_core/pharmed_core.dart';

class SubmitRefillListParams {
  final int userId;
  final int stationId;
  final int medicineId;
  final num quantity;
  final int? fillingListId;

  SubmitRefillListParams({
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

class CreateRefillListUseCase {
  final IRefillListRepository _repository;

  CreateRefillListUseCase(this._repository);

  Future<Result<void>> call(List<SubmitRefillListParams> params) async {
    final data = params.map((p) => p.toJson()).toList();
    final stationId = params.first.stationId;
    return _repository.createFillingList(data, stationId: stationId);
  }
}
