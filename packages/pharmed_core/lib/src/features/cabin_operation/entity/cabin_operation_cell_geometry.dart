// pharmed_core/features/cabin_operation/cabin_operation_cell_geometry.dart
// [SWREQ-CORE-CABINOP-006] [IEC 62304 §5.5]
//
// Bir hücrenin (kübik göz ya da birim doz gözü) backend'e kayıt atılırken
// hangi fiziksel adrese yazılacağını belirler: `cabinDrawerDetailId`
// (DrawerCell kaydının id'si), `shelfNo` ve `compartmentNo`. Bu üç değer,
// hangi miktarın (sayım/dolum/boşaltma) gönderileceğiyle hiç ilgili değildir
// — yalnızca "bu hücre backend'de hangi satır/adres" sorusuna cevap verir.
//
// Kübik ve birim doz çekmecede adres şu şekilde çözülür:
//   - Kübik: tek göz olduğu için assignment'ın İLK DrawerCell kaydı kullanılır;
//     shelfNo çekmecenin sırası (drawerUnit.orderNo), compartmentNo
//     çekmecenin kademesidir (drawerUnit.compartmentNo).
//   - Birim doz: her göz kendi index'indeki DrawerCell kaydına karşılık
//     gelir; shelfNo çekmecenin kademesidir (drawerUnit.compartmentNo),
//     compartmentNo o DrawerCell kaydının kendi adım numarasıdır (stepNo).
//
// İlgili bir DrawerCell kaydı bulunamazsa (liste kısa/eksikse) 0 döner —
// backend'e eksik ama tutarlı bir değer gider, exception fırlatılmaz.
//
// Kullanım: `CabinOperationParamsMapper`, her hücre için `forKubik` ya da
// `forStep` çağırıp dönen değeri doğrudan kayıt DTO'suna (`CabinOperationMedicineParams`)
// yerleştirir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CabinOperationCellGeometry {
  const CabinOperationCellGeometry({required this.detailId, required this.shelfNo, required this.compartmentNo});

  /// DrawerCell kaydının backend id'si — bu hücrenin fiziksel karşılığı.
  final int detailId;

  final int shelfNo;
  final int compartmentNo;

  /// Kübik çekmecenin tek gözü için adresi çözer.
  static CabinOperationCellGeometry forKubik(MedicineAssignment assignment) {
    final unit = assignment.drawerUnit;
    return CabinOperationCellGeometry(
      detailId: assignment.cabinDrawerDetail?.firstOrNull?.id ?? 0,
      shelfNo: unit?.orderNo ?? 1,
      compartmentNo: unit?.compartmentNo ?? 0,
    );
  }

  /// Birim doz çekmecesinin [index]'inci gözü için adresi çözer.
  static CabinOperationCellGeometry forStep(MedicineAssignment assignment, int index) {
    final unit = assignment.drawerUnit;
    final details = assignment.cabinDrawerDetail;
    final hasDetail = details != null && index < details.length;
    return CabinOperationCellGeometry(
      detailId: hasDetail ? (details[index].id ?? 0) : 0,
      shelfNo: unit?.compartmentNo ?? 0,
      compartmentNo: hasDetail ? (details[index].stepNo ?? 0) : 0,
    );
  }
}
