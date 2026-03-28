import '../../../../core/core.dart';

import '../../../medicine/domain/entity/medicine.dart';
import '../../../prescription/domain/entity/prescription_item.dart';

import '../entity/withdraw_item.dart';
import '../repository/i_medicine_withdraw_repository.dart';

class GetPatientMedicinesUseCase extends UseCase<List<WithdrawItem>, int> {
  final IMedicineWithdrawRepository _repository;

  GetPatientMedicinesUseCase(this._repository);

  @override
  Future<Result<List<WithdrawItem>>> call(int hospitalizationId) async {
    List<WithdrawItem> items = [];
    final result = await _repository.getPatientMedicines(hospitalizationId: hospitalizationId);
    return result.when(
      error: Result.error,
      ok: (data) {
        for (var d in data) {
          items.add(
            WithdrawItem(
              id: d.id,
              type: WithdrawType.free,
              assignment: d.assignment,
              dosePiece: d.dosePiece.toDouble(),
              prescriptionItem: PrescriptionItem(
                time: d.time,
                applicationDate: d.applicationDate,
                applicationUser: d.applicationUser,
                description: d.description,
              ),
              medicine: Drug(name: d.medicineName, dose: d.dosePiece, barcode: d.barcode),
            ),
          );
        }
        return Result.ok(items);
      },
    );
  }
}
