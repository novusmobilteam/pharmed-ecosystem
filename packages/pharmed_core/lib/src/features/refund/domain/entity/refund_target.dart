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
  const RefundTarget({required this.item});

  /// Check tamamlanmış RefundableItem — returnType/returnQuantity/
  /// resolvedTarget dolu (toPharmacy dışında).
  final RefundableItem item;

  /// Çekmece açma için kullanılacak hedef adres. toPharmacy'de bu targetın
  /// hiç job'a girmemesi gerekir (bkz. requiresCabinTarget) — burada null
  /// gelirse çağıran hata sayar.
  MedicineAssignment get assignment => item.resolvedTarget ?? MedicineAssignment.empty(cabinId: 0, cabinDrawerId: 0);

  bool get isKubik => assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

  bool get isValid => item.isReadyForExecution;
}
