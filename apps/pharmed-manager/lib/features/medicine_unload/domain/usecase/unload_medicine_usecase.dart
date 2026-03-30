import '../../../../core/core.dart';

class UnloadMedicineParams {
  final int materialId;
  final int cabinDrawerDetailId;
  final double countQuantity;
  final double quantity;
  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  UnloadMedicineParams({
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

class UnloadMedicineUseCase implements UseCase<void, List<UnloadMedicineParams>> {
  final ICabinStockRepository _cabinStockRepository;

  UnloadMedicineUseCase(this._cabinStockRepository);

  @override
  Future<Result<void>> call(List<UnloadMedicineParams> params) {
    final data = params.map((p) => p.toJson()).toList();
    return _cabinStockRepository.unload(data);
  }
}
