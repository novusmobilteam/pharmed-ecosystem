// [SWREQ-CORE-REFUND-001] [IEC 62304 §5.5]
//
// İade işlemi sırasında kullanıcıya gösterilen bir kalem. Kaynağı her zaman
// bir CabinTargetedPrescriptionItem (source) — id/medicine/hospitalization/
// stock/lastMovement gibi sabit reçete-satırı bilgisi hep oradan okunur.
//
// IntakeItem'ın simetriği: IntakeItem'da "prescriptionDose sabit, dosePiece
// kullanıcı tarafından düşürülebilir" neyse, burada "appliedQuantity sabit,
// returnQuantity kullanıcı tarafından kısmi iadeye düşürülebilir" odur.
//
// returnType/resolvedTarget, CheckMasterRefundStatusUseCase tarafından
// doldurulur — bu use case çağrılana kadar ikisi de null'dur. 4 iade tipinden
// (toPharmacy/toReturnBox/toDrawer/toOrigin) yalnızca toPharmacy kabin hedefi
// GEREKTİRMEZ; diğer üçü (kavramsal olarak aynı davranış — çekmece açılır,
// bir göze konur) resolvedTarget doldurulmadan tamamlanamaz.
//
// Şahitlik kavramı YOK — WitnessContext taşımaz (iade akışında şahit
// sorgusu hiç yapılmıyor).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RefundableItem {
  const RefundableItem({
    required this.source,
    required this.appliedQuantity,
    this.returnQuantity,
    this.returnType,
    this.resolvedTarget,
  });

  /// Ham servis satırı — id, medicine, hospitalization, orijinal
  /// cabinAssignment (toOrigin için kaynak), stock, lastMovement.
  final CabinTargetedPrescriptionItem source;

  /// Hastaya daha önce uygulanmış miktar — sabit, iadenin üst sınırı.
  final num appliedQuantity;

  /// Kullanıcının iade etmek üzere seçtiği miktar. null → henüz seçilmedi.
  final num? returnQuantity;

  /// Kullanıcının seçtiği iade yöntemi. null → henüz seçilmedi.
  final ReturnType? returnType;

  /// CheckMasterRefundStatusUseCase'in çözdüğü fiziksel hedef göz.
  /// requiresCabinTarget false ise (toPharmacy) anlamsızdır ve hiç
  /// sorulmaz. true ise ve hâlâ null'sa check henüz yapılmamış demektir.
  final MedicineAssignment? resolvedTarget;

  int get id => source.id;
  Medicine? get medicine => source.medicine;
  Hospitalization? get hospitalization => source.hospitalization;
  CabinStock? get stock => source.stock;
  PrescriptionItemMovement? get lastMovement => source.lastMovement;
  PrescriptionMovementType? get status => lastMovement?.type;
  DateTime? get time => source.time;

  bool get isPartialReturn => returnQuantity != null && returnQuantity! < appliedQuantity;

  /// toPharmacy dışındaki tüm iade tipleri kabin hedefi gerektirir.
  bool get requiresCabinTarget => returnType != null && returnType != ReturnType.toPharmacy;

  /// Check tamamlanmış ve (gerekiyorsa) hedef çözülmüş mü — execution'a
  /// geçmeye hazır mı.
  bool get isReadyForExecution {
    if (returnType == null || returnQuantity == null) return false;
    if (!requiresCabinTarget) return true;
    return resolvedTarget != null;
  }

  /// [clearResolvedTarget]: true verilirse resolvedTarget null'a döner
  /// (returnType değiştiğinde eski hedefin sessizce kalmasını önlemek için
  /// zorunlu — ör. toDrawer'dan toPharmacy'ye geçişte).
  RefundableItem copyWith({
    num? returnQuantity,
    ReturnType? returnType,
    MedicineAssignment? resolvedTarget,
    bool clearResolvedTarget = false,
  }) {
    return RefundableItem(
      source: source,
      appliedQuantity: appliedQuantity,
      returnQuantity: returnQuantity ?? this.returnQuantity,
      returnType: returnType ?? this.returnType,
      resolvedTarget: clearResolvedTarget ? null : (resolvedTarget ?? this.resolvedTarget),
    );
  }
}
