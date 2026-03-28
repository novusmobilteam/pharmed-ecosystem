import '../../../../core/core.dart';

import '../repository/i_cabin_stock_repository.dart';

class CountMedicineParams {
  final int materialId;
  final int cabinDrawerDetailId;
  final double countQuantity;
  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  CountMedicineParams(
    this.materialId,
    this.cabinDrawerDetailId,
    this.countQuantity,
    this.miadDate,
    this.shelfNo,
    this.compartmentNo,
  );

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "censusQuantity": countQuantity,
      "miadDate": miadDate?.toIso8601String(),
      "shelfNo": shelfNo,
      "corpartmentNo": compartmentNo,
    };
  }
}

class CountMedicineUseCase implements UseCase<void, List<CountMedicineParams>> {
  final ICabinStockRepository _repository;

  CountMedicineUseCase(this._repository);

  @override
  Future<Result<void>> call(List<CountMedicineParams> params) {
    return _repository.count(params);
  }
}
