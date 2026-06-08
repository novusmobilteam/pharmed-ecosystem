import 'package:pharmed_core/pharmed_core.dart';

class FillingListRefillParams extends CabinRefillParams {
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

class RefillListRefillUseCase {
  final IRefillListRepository _repository;

  RefillListRefillUseCase(this._repository);

  Future<Result<void>> call(List<CabinRefillParams> params) {
    return _repository.fill(params);
  }
}
