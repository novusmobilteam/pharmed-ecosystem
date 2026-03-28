import '../../../../core/core.dart';

import '../../../cabin_stock/domain/repository/i_cabin_stock_repository.dart';

class RefillMedicineParams {
  final int materialId;
  final int cabinDrawerDetailId;
  final double countQuantity;
  final double quantity;
  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  RefillMedicineParams({
    required this.materialId,
    required this.cabinDrawerDetailId,
    required this.countQuantity,
    required this.quantity,
    required this.miadDate,
    required this.shelfNo,
    required this.compartmentNo,
  });

  Map<String, dynamic> toJson() {
    return {
      "materialId": materialId,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "censusQuantity": countQuantity,
      "quantity": quantity,
      "miadDate": miadDate?.toIso8601String(),
      "shelfNo": shelfNo,
      "corpartmentNo": compartmentNo,
    };
  }
}

class RefillMedicineUseCase implements UseCase<void, List<RefillMedicineParams>> {
  final ICabinStockRepository _cabinStockRepository;

  RefillMedicineUseCase(this._cabinStockRepository);

  @override
  Future<Result<void>> call(List<RefillMedicineParams> params) {
    return _cabinStockRepository.fill(params);
  }
}
