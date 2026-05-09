import '../../../../core/core.dart';

import '../../../medicine_management/domain/repository/i_medicine_management_repository.dart';

class DisposeMaterialParams {
  final int stockId;
  final double dosePiece;

  DisposeMaterialParams({required this.stockId, required this.dosePiece});

  Map<String, dynamic> toJson() {
    return {"cabinDrawrStockId": stockId, "dosePiece": dosePiece};
  }
}

class DisposeMaterialUseCase {
  final IMedicineManagementRepository _repository;

  DisposeMaterialUseCase(this._repository);

  Future<Result<void>> call(List<DisposeMaterialParams> params) async {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.disposeMaterial(data);
  }
}
