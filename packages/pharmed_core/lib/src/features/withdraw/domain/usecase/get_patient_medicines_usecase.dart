import 'package:pharmed_core/pharmed_core.dart';

class GetPatientMedicinesUseCase {
  final IWithdrawRepository _repository;

  GetPatientMedicinesUseCase(this._repository);

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
