// [SWREQ-CLI-MREFUND-010] [IEC 62304 §5.5]
// Tek bir iade hedefi — CheckMasterRefundStatusUseCase tamamlanmış (returnType
// seçilmiş, resolvedTarget çözülmüş — toPharmacy hariç) bir RefundableItem'ı
// sarar. Dolumdaki CabinOperationTarget'ın iade karşılığı, ama miad/adet
// girişi yok — kullanıcı zaten miktarı Selection fazında belirledi
// (RefundableItem.returnQuantity), burada sadece çekmece hedefine gidilir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RefundTarget {
  const RefundTarget({required this.item, this.isReturnDrawerTarget = false});

  final RefundableItem item;
  final bool isReturnDrawerTarget;

  MedicineAssignment get assignment => item.resolvedTarget ?? MedicineAssignment.empty(cabinId: 0, cabinDrawerId: 0);

  bool get isKubik =>
      !isReturnDrawerTarget && (assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false);

  bool get isValid => item.isReadyForExecution;
}
