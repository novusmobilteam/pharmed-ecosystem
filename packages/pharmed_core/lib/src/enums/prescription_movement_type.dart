import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// DURUMLAR
// ────────
// pendingApproval  (1)  Onay Bekliyor
// purchasePending  (2)  Alım Bekliyor
// applied          (3)  Uygulandı
// returned         (4)  İade Edildi        [terminal]
// wastaged         (5)  Fire Edildi        [terminal]
// destructed       (6)  İmha Edildi        [terminal]
// cancelled        (7)  İptal Edildi       [terminal]
// rejected         (8)  Reddedildi         [terminal]
// filledWaiting    (9)  Dolum Bekliyor
// returnPending   (10)  İade Onayı Bekliyor
// unloaded        (11)  Boşaltıldı         [terminal]

// GEÇİŞLER
// ─────────
// pendingApproval  ──[onayla]──►  purchasePending
// pendingApproval  ──[reddet]──►  rejected
// pendingApproval  ──[iptal]───►  cancelled

// purchasePending  ──[al]──────►  applied
// purchasePending  ──[iptal]───►  cancelled
// purchasePending  ──[boşalt]──►  unloaded

// filledWaiting    ──[doldur]──►  purchasePending

// applied          ──[iade et]──►  returnPending
// applied          ──[fire et]──►  wastaged
// applied          ──[imha et]──►  destructed

// returnPending    ──[iade onayla]──►  returned   [manager]

// TERMINAL DURUMLAR
// ─────────────────
// returned, wastaged, destructed, cancelled, rejected, unloaded
// → Bu durumlardan hiçbir geçiş yapılamaz (şimdilik).

// AKSİYON MATRİSİ
// ────────────────
// canApprove      →  pendingApproval
// canReject       →  pendingApproval
// canCancel       →  pendingApproval | purchasePending
// canFill         →  filledWaiting
// canPurchase     →  purchasePending
// canReturn       →  applied
// canWastage      →  applied
// canDestruct     →  applied
// canUnload       →  purchasePending
// canApproveReturn→  returnPending

enum PrescriptionMovementType {
  /// Onay Bekliyor
  pendingApproval(1),

  /// Alım Bekliyor
  purchasePending(2),

  /// Uygulandı
  applied(3),

  /// İade Edildi
  returned(4),

  /// Fire Edildi
  wastaged(5),

  /// İmha Edildi
  destructed(6),

  /// İptal Edildi
  cancelled(7),

  /// Reddedildi
  rejected(8),

  /// Dolum Bekliyor
  filledWaiting(9),

  /// İade Onay Bekliyor
  returnPending(10),

  /// Boşaltıldı
  unloaded(11);

  final int id;

  const PrescriptionMovementType(this.id);

  static PrescriptionMovementType fromId(int? id) {
    return PrescriptionMovementType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PrescriptionMovementType.pendingApproval,
    );
  }

  String get label => switch (this) {
    PrescriptionMovementType.pendingApproval => 'Onay Bekliyor',
    PrescriptionMovementType.purchasePending => 'Alım Bekliyor',
    PrescriptionMovementType.applied => 'Uygulandı',
    PrescriptionMovementType.returned => 'İade Edildi',
    PrescriptionMovementType.wastaged => 'Fire Edildi',
    PrescriptionMovementType.destructed => 'İmha Edildi',
    PrescriptionMovementType.cancelled => 'İptal Edildi',
    PrescriptionMovementType.rejected => 'Reddedildi',
    PrescriptionMovementType.filledWaiting => 'Dolum Bekliyor',
    PrescriptionMovementType.returnPending => 'İade Onayı Bekliyor',
    PrescriptionMovementType.unloaded => 'Boşaltıldı',
  };
}

extension PrescriptionMovementTypeStyle on PrescriptionMovementType {
  Color get backgroundColor => switch (this) {
    PrescriptionMovementType.applied => MedColors.green,
    PrescriptionMovementType.returned => MedColors.blue,
    PrescriptionMovementType.purchasePending => MedColors.amber,
    PrescriptionMovementType.pendingApproval => MedColors.amber,
    PrescriptionMovementType.filledWaiting => MedColors.amber,
    PrescriptionMovementType.returnPending => MedColors.amber,
    PrescriptionMovementType.wastaged => MedColors.red,
    PrescriptionMovementType.destructed => MedColors.red,
    PrescriptionMovementType.cancelled => MedColors.red,
    PrescriptionMovementType.rejected => MedColors.red,
    PrescriptionMovementType.unloaded => MedColors.red,
  };

  Color get foregroundColor => switch (this) {
    PrescriptionMovementType.applied => MedColors.greenLight,
    PrescriptionMovementType.returned => MedColors.blueLight,
    PrescriptionMovementType.purchasePending => MedColors.amberLight,
    PrescriptionMovementType.pendingApproval => MedColors.amberLight,
    PrescriptionMovementType.filledWaiting => MedColors.amberLight,
    PrescriptionMovementType.returnPending => MedColors.amberLight,
    PrescriptionMovementType.wastaged => MedColors.redLight,
    PrescriptionMovementType.destructed => MedColors.redLight,
    PrescriptionMovementType.cancelled => MedColors.redLight,
    PrescriptionMovementType.rejected => MedColors.redLight,
    PrescriptionMovementType.unloaded => MedColors.redLight,
  };

  IconData get icon => switch (this) {
    PrescriptionMovementType.pendingApproval => PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
    PrescriptionMovementType.purchasePending => PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill),
    PrescriptionMovementType.applied => PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
    PrescriptionMovementType.returned => PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.fill),
    PrescriptionMovementType.wastaged => PhosphorIcons.warning(PhosphorIconsStyle.fill),
    PrescriptionMovementType.destructed => PhosphorIcons.trash(PhosphorIconsStyle.fill),
    PrescriptionMovementType.cancelled => PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
    PrescriptionMovementType.rejected => PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
    PrescriptionMovementType.filledWaiting => PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
    PrescriptionMovementType.returnPending => PhosphorIcons.arrowUUpLeft(PhosphorIconsStyle.fill),
    PrescriptionMovementType.unloaded => PhosphorIcons.tray(PhosphorIconsStyle.fill),
  };
}

extension PrescriptionMovementTypeActions on PrescriptionMovementType {
  bool get canApprove => this == PrescriptionMovementType.pendingApproval;

  bool get canReject => this == PrescriptionMovementType.pendingApproval;

  bool get canCancel =>
      this == PrescriptionMovementType.pendingApproval || this == PrescriptionMovementType.purchasePending;

  bool get canFill => this == PrescriptionMovementType.filledWaiting;

  bool get canPurchase => this == PrescriptionMovementType.purchasePending;

  bool get canReturn => this == PrescriptionMovementType.applied;

  bool get canWastage => this == PrescriptionMovementType.applied;

  bool get canDestruct => this == PrescriptionMovementType.applied;

  bool get canUnload => this == PrescriptionMovementType.purchasePending;

  bool get canApproveReturn => this == PrescriptionMovementType.returnPending;

  bool get isTerminal =>
      this == PrescriptionMovementType.returned ||
      this == PrescriptionMovementType.wastaged ||
      this == PrescriptionMovementType.destructed ||
      this == PrescriptionMovementType.cancelled ||
      this == PrescriptionMovementType.rejected ||
      this == PrescriptionMovementType.unloaded;
}
