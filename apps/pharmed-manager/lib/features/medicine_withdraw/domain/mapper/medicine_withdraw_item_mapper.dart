import 'package:pharmed_core/pharmed_core.dart';

import '../../../medicine_management/domain/entity/cabin_operation_item.dart';

/// MedicineWithdrawItem → CabinOperationItem dönüşümü.
/// İade akışında kullanılır.
extension MedicineWithdrawItemMapper on MedicineWithdrawItem {
  CabinOperationItem toCabinOperationItem() {
    return CabinOperationItem(
      id: id,
      operationType: CabinOperationType.refund,
      medicine: medicine,
      dosePiece: dosePiece.toDouble(),
      assignment: cabinAssignment,
      applicationDate: applicationDate,
      applicationUser: applicationUser,
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
