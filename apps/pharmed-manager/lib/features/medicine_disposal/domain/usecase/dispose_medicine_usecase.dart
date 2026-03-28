import '../../../../core/core.dart';

import '../../../medicine_management/domain/repository/i_medicine_management_repository.dart';
import '../../presentation/notifier/disposal_notifier.dart';

class DisposeMedicineParams {
  final DisposeType type;
  final int prescriptionDetailId;
  final int? witnessId;
  final double dosePiece;

  DisposeMedicineParams({
    required this.type,
    required this.prescriptionDetailId,
    this.witnessId,
    required this.dosePiece,
  });

  Map<String, dynamic> toJson() {
    return {"prescriptionDetailId": prescriptionDetailId, "userId": witnessId, "dosePiece": dosePiece};
  }
}

class DisposeMedicineUseCase implements UseCase<void, DisposeMedicineParams> {
  final IMedicineManagementRepository _repository;

  DisposeMedicineUseCase(this._repository);

  @override
  Future<Result<void>> call(DisposeMedicineParams params) async {
    final type = params.type;
    switch (type) {
      case DisposeType.wastage:
        return await _wastage(params);
      case DisposeType.destruction:
        return await _destruction(params);
    }
  }

  Future<Result<void>> _wastage(DisposeMedicineParams params) async {
    return _repository.wastage(params.toJson());
  }

  Future<Result<void>> _destruction(DisposeMedicineParams params) async {
    return _repository.destruction(params.toJson());
  }
}
