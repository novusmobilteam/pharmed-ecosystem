import 'package:pharmed_core/pharmed_core.dart';

/// MedicineWithdrawItem → CabinOperationItem dönüşümü.
/// İade akışında kullanılır.
extension MedicineWithdrawItemMapper on MedicineIntakeItem {
  CabinOperationItem toCabinOperationItem() {
    return CabinOperationItem(
      id: id,
      operationType: CabinOperationType.refund,
      medicine: medicine,
      dosePiece: dosePiece.toDouble(),
      assignment: cabinAssignment,

      // İade'de reçete bağlamı taşınmaz
      prescriptionItem: null,
      prescriptionDose: null,
      withdrawType: null,
      // İade'de şahit yoktur
      witnesses: const [],
      stations: const [],
      witness: null,
    );
  }
}
