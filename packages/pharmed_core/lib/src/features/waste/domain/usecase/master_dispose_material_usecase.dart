import 'package:pharmed_core/pharmed_core.dart';

class DisposeMaterialParams {
  final int stockId;
  final double dosePiece;

  DisposeMaterialParams({required this.stockId, required this.dosePiece});

  Map<String, dynamic> toJson() {
    return {"cabinDrawrStockId": stockId, "dosePiece": dosePiece};
  }
}

class MasterDisposeMaterialUseCase {
  final IWasteRepository _repository;

  MasterDisposeMaterialUseCase(this._repository);

  Future<Result<void>> call(List<DisposeMaterialParams> params) async {
    final data = params.map((p) => p.toJson()).toList();
    return _repository.masterDisposeMaterial(data);
  }
}
