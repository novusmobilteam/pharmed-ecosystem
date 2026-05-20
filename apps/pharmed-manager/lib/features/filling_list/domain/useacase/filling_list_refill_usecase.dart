import '../../../../core/core.dart';

import '../../../../old_features/cabin/domain/entity/cabin_filling_request.dart';
import '../repository/i_filling_list_repository.dart';

class FillingListRefillParams extends CabinFillingRequest {
  final int id;

  FillingListRefillParams({
    required this.id,
    required super.cabinDrawerDetailId,
    required super.quantity,
    required super.censusQuantity,
    required super.miadDate,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "quantity": quantity,
      "censusQuantity": censusQuantity,
      "miadDate": miadDate?.toIso8601String(),
    };
  }
}

class FillingListRefillUseCase {
  final IFillingListRepository _repository;

  FillingListRefillUseCase(this._repository);

  Future<Result<void>> call(List<CabinFillingRequest> params) {
    return _repository.fill(params);
  }
}
