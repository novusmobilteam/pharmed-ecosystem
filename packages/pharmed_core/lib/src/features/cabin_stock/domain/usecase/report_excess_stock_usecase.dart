import 'package:pharmed_core/pharmed_core.dart';

class ReportExcessStockParams {
  final int? hospitalizationId;
  final int? medicineId;
  final num? quantity;

  ReportExcessStockParams({this.hospitalizationId, this.medicineId, this.quantity});

  Map<String, dynamic> toJson() {
    return {'patientHospitalizationId': hospitalizationId, 'materialId': medicineId, 'quantity': quantity};
  }
}

class ReportExcessStockUseCase {
  final ICabinStockRepository _repository;

  ReportExcessStockUseCase(this._repository);

  Future<Result<void>> call({required ReportExcessStockParams params, required CabinInventoryType type}) {
    return _repository.reportExcessStock(data: params.toJson(), cabinInventoryTypeId: type.id);
  }
}
