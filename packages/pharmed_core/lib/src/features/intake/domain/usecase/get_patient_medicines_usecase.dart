import 'package:pharmed_core/pharmed_core.dart';

class GetPatientMedicinesUseCase {
  final IIntakeRepository _repository;

  GetPatientMedicinesUseCase(this._repository);

  Future<Result<List<IntakeItem>>> call(int hospitalizationId) async {
    List<IntakeItem> items = [];
    final result = await _repository.getPatientMedicines(hospitalizationId: hospitalizationId);
    return result.when(
      error: Result.error,
      ok: (data) {
        for (var d in data) {
          items.add(
            IntakeItem(
              id: d.id,
              type: IntakeType.free,
              assignment: d.assignment,
              dosePiece: d.dosePiece.toDouble(),
              prescriptionItem: PrescriptionItem(time: d.time, description: d.description),
              medicine: Drug(name: d.medicineName, dose: d.dosePiece, barcode: d.barcode),
            ),
          );
        }
        return Result.ok(items);
      },
    );
  }
}
