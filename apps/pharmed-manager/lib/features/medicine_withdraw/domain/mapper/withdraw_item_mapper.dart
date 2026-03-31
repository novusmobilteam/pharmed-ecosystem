import 'package:pharmed_core/pharmed_core.dart';

import '../../../medicine_management/domain/entity/cabin_operation_item.dart';

/// WithdrawItem → CabinOperationItem dönüşümü.
/// Alım akışında kullanılır.
extension WithdrawItemMapper on WithdrawItem {
  CabinOperationItem toCabinOperationItem() {
    return CabinOperationItem(
      id: id,
      operationType: CabinOperationType.withdraw,
      medicine: medicine,
      dosePiece: dosePiece,
      assignment: assignment,
      prescriptionItem: prescriptionItem,
      prescriptionDose: prescriptionDose,
      withdrawType: type,
      witnesses: witnesses,
      stations: stations,
      witness: witness,
      // Alımda geçmiş işlem bilgisi yoktur
      applicationDate: null,
      applicationUser: null,
      status: prescriptionItem?.status,
    );
  }
}
