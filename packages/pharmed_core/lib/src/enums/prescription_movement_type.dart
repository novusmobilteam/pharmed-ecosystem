import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// DURUMLAR
// ────────
// pendingApproval         (1)  Onay Bekliyor
// purchasePending         (2)  Alım Bekliyor
// applied                 (3)  Uygulandı
// returned                (4)  İade Edildi              [terminal]
// wastaged                (5)  Fire Edildi              [terminal]
// destructed              (6)  İmha Edildi              [terminal]
// cancelled               (7)  İptal Edildi             [terminal]
// rejected                (8)  Reddedildi               [terminal]
// filledWaiting           (9)  Dolum Bekliyor
// returnPending          (10)  İade Onayı Bekliyor
// unloaded               (11)  Boşaltıldı               [terminal]
// shortageReported       (12)  Eksik Bildirildi
// replenishmentPending   (13)  İkmal Bekliyor

// GEÇİŞLER
// ─────────
// pendingApproval     ──[onayla]──────────►  purchasePending
// pendingApproval     ──[reddet]──────────►  rejected
// pendingApproval     ──[iptal]───────────►  cancelled

// purchasePending     ──[al]──────────────►  applied
// purchasePending     ──[iptal]───────────►  cancelled
// purchasePending     ──[boşalt]──────────►  unloaded
// purchasePending     ──[eksik bildir]────►  shortageReported

// shortageReported    ──[onayla / manager]►  replenishmentPending
// shortageReported    ──[reddet  / manager]►  ??? (aşağıdaki nota bak)

// replenishmentPending──[doldur]──────────►  purchasePending

// filledWaiting       ──[doldur]──────────►  purchasePending

// applied             ──[iade et]─────────►  returnPending
// applied             ──[fire et]─────────►  wastaged
// applied             ──[imha et]─────────►  destructed

// returnPending       ──[iade onayla]─────►  returned   [manager]

// TERMINAL DURUMLAR
// ─────────────────
// returned, wastaged, destructed, cancelled, rejected, unloaded
// → Bu durumlardan hiçbir geçiş yapılamaz (şimdilik).

// AKSİYON MATRİSİ
// ────────────────
// canApprove          →  pendingApproval
// canReject           →  pendingApproval
// canCancel           →  pendingApproval | purchasePending
// canFill             →  filledWaiting | replenishmentPending
// canPurchase         →  purchasePending
// canReportShortage   →  purchasePending
// canReturn           →  applied
// canWastage          →  applied
// canDestruct         →  applied
// canUnload           →  purchasePending
// canApproveReturn    →  returnPending
//
// shortageReported    →  HİÇBİR client aksiyonu yok (manager onayı bekleniyor)

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
  unloaded(11),

  /// Eksik Bildirildi — kullanıcı eksik stok bildirdi, manager onayı bekleniyor.
  shortageReported(12),

  /// İkmal Bekliyor — eksik onaylandı, dolum yapılabilir.
  replenishmentPending(13),

  /// Order Yönlendirildi — bu kalem, kabinde ve muadilinde stok bulunamadığı
  /// için başka bir istasyona yönlendirildi. Bu kabinde artık hiçbir aksiyon
  /// alınamaz (terminal-benzeri).
  redirected(14);

  final int id;

  const PrescriptionMovementType(this.id);

  static PrescriptionMovementType fromId(int? id) {
    return PrescriptionMovementType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PrescriptionMovementType.pendingApproval,
    );
  }

  String label(BuildContext context) {
    final l = context.l10n;

    return switch (this) {
      PrescriptionMovementType.pendingApproval => l.enumCore_prescriptionMovementPendingApprovalLabel,
      PrescriptionMovementType.purchasePending => l.enumCore_prescriptionMovementPurchasePendingLabel,
      PrescriptionMovementType.applied => l.enumCore_prescriptionMovementAppliedLabel,
      PrescriptionMovementType.returned => l.enumCore_prescriptionMovementReturnedLabel,
      PrescriptionMovementType.wastaged => l.enumCore_prescriptionMovementWastagedLabel,
      PrescriptionMovementType.destructed => l.enumCore_prescriptionMovementDestructedLabel,
      PrescriptionMovementType.cancelled => l.enumCore_prescriptionMovementCancelledLabel,
      PrescriptionMovementType.rejected => l.enumCore_prescriptionMovementRejectedLabel,
      PrescriptionMovementType.filledWaiting => l.enumCore_prescriptionMovementFilledWaitingLabel,
      PrescriptionMovementType.returnPending => l.enumCore_prescriptionMovementReturnPendingLabel,
      PrescriptionMovementType.unloaded => l.enumCore_prescriptionMovementUnloadedLabel,
      PrescriptionMovementType.shortageReported => l.enumCore_prescriptionMovementShortageReportedLabel,
      PrescriptionMovementType.replenishmentPending => l.enumCore_prescriptionMovementReplenishmentPendingLabel,
      PrescriptionMovementType.redirected => l.enumCore_prescriptionMovementRedirectedLabel,
    };
  }

  /// Hareketi gerçekleştiren kişiyi betimleyen etiket.
  /// UI'da "Oluşturan", "Onaylayan" gibi gösterilir.
  String actorLabel(BuildContext context, {bool isMobile = true}) {
    final l = context.l10n;
    return switch (this) {
      PrescriptionMovementType.pendingApproval => l.enumCore_prescriptionMovementPendingApprovalActorLabel,
      PrescriptionMovementType.purchasePending =>
        isMobile
            ? l.enumCore_prescriptionMovementPurchasePendingActorLabel
            : l.enumCore_prescriptionMovementPendingApprovalActorLabel,
      PrescriptionMovementType.applied => l.enumCore_prescriptionMovementAppliedActorLabel,
      PrescriptionMovementType.returned => l.enumCore_prescriptionMovementReturnedActorLabel,
      PrescriptionMovementType.wastaged => l.enumCore_prescriptionMovementWastagedActorLabel,
      PrescriptionMovementType.destructed => l.enumCore_prescriptionMovementDestructedActorLabel,
      PrescriptionMovementType.cancelled => l.enumCore_prescriptionMovementCancelledActorLabel,
      PrescriptionMovementType.rejected => l.enumCore_prescriptionMovementRejectedActorLabel,
      PrescriptionMovementType.filledWaiting => l.enumCore_prescriptionMovementFilledWaitingActorLabel,
      PrescriptionMovementType.returnPending => l.enumCore_prescriptionMovementReturnPendingActorLabel,
      PrescriptionMovementType.unloaded => l.enumCore_prescriptionMovementUnloadedActorLabel,
      PrescriptionMovementType.shortageReported => l.enumCore_prescriptionMovementShortageReportedActorLabel,
      PrescriptionMovementType.replenishmentPending => l.enumCore_prescriptionMovementReplenishmentPendingActorLabel,
      PrescriptionMovementType.redirected => l.enumCore_prescriptionMovementRedirectedActorLabel,
    };
  }

  /// Bu duruma **geçişi sağlayan eylem**i betimler.
  ///
  /// [label] o anki durumu ("Alım Bekliyor") gösterir; aktivite/hareket
  /// geçmişinde ise "ne yapıldığı" anlamlıdır. Bu getter o eylemi verir.
  ///
  /// Not: Bazı durumlara birden fazla eylemle gelinebilir (ör. purchasePending
  /// hem onaylama hem dolum ile). Burada iş akışındaki **baskın/temsili** eylem
  /// seçilmiştir; actorLabel ile tutarlıdır.
  String actionLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      PrescriptionMovementType.pendingApproval => l.enumCore_prescriptionMovementPendingApprovalActionLabel,
      PrescriptionMovementType.purchasePending => l.enumCore_prescriptionMovementPurchasePendingActionLabel,
      PrescriptionMovementType.applied => l.enumCore_prescriptionMovementAppliedActionLabel,
      PrescriptionMovementType.returned => l.enumCore_prescriptionMovementReturnedActionLabel,
      PrescriptionMovementType.wastaged => l.enumCore_prescriptionMovementWastagedActionLabel,
      PrescriptionMovementType.destructed => l.enumCore_prescriptionMovementDestructedActionLabel,
      PrescriptionMovementType.cancelled => l.enumCore_prescriptionMovementCancelledActionLabel,
      PrescriptionMovementType.rejected => l.enumCore_prescriptionMovementRejectedActionLabel,
      PrescriptionMovementType.filledWaiting => l.enumCore_prescriptionMovementFilledWaitingActionLabel,
      PrescriptionMovementType.returnPending => l.enumCore_prescriptionMovementReturnPendingActionLabel,
      PrescriptionMovementType.unloaded => l.enumCore_prescriptionMovementUnloadedActionLabel,
      PrescriptionMovementType.shortageReported => l.enumCore_prescriptionMovementShortageReportedActionLabel,
      PrescriptionMovementType.replenishmentPending => l.enumCore_prescriptionMovementReplenishmentPendingActionLabel,
      PrescriptionMovementType.redirected => l.enumCore_prescriptionMovementRedirectedActionLabel,
    };
  }

  static List<PrescriptionMovementType> get refillableTypes => const [
    PrescriptionMovementType.filledWaiting,
    PrescriptionMovementType.pendingApproval,
    PrescriptionMovementType.purchasePending,
    PrescriptionMovementType.applied,
    PrescriptionMovementType.returned,
    PrescriptionMovementType.wastaged,
    PrescriptionMovementType.destructed,
    PrescriptionMovementType.cancelled,
    PrescriptionMovementType.rejected,
    PrescriptionMovementType.filledWaiting,
    PrescriptionMovementType.returnPending,
    PrescriptionMovementType.unloaded,
    PrescriptionMovementType.shortageReported,
    PrescriptionMovementType.replenishmentPending,
  ];

  static List<PrescriptionMovementType> get intakeableTypes => const [
    PrescriptionMovementType.purchasePending,
    PrescriptionMovementType.applied,
    PrescriptionMovementType.filledWaiting,
    PrescriptionMovementType.pendingApproval,
    PrescriptionMovementType.returned,
    PrescriptionMovementType.wastaged,
    PrescriptionMovementType.destructed,
    PrescriptionMovementType.cancelled,
    PrescriptionMovementType.rejected,
    PrescriptionMovementType.filledWaiting,
    PrescriptionMovementType.returnPending,
    PrescriptionMovementType.unloaded,
    PrescriptionMovementType.shortageReported,
    PrescriptionMovementType.replenishmentPending,
    PrescriptionMovementType.redirected,
  ];
}

extension PrescriptionMovementTypeStyle on PrescriptionMovementType {
  Color get backgroundColor => switch (this) {
    PrescriptionMovementType.pendingApproval => MedColors.amber,
    PrescriptionMovementType.purchasePending || PrescriptionMovementType.filledWaiting => MedColors.blue,
    PrescriptionMovementType.applied => MedColors.green,
    PrescriptionMovementType.returned => MedColors.blue,
    PrescriptionMovementType.wastaged => MedColors.amber,
    PrescriptionMovementType.destructed => MedColors.red,
    PrescriptionMovementType.cancelled => MedColors.red,
    PrescriptionMovementType.rejected => MedColors.red,
    PrescriptionMovementType.returnPending => MedColors.amber,
    PrescriptionMovementType.unloaded => MedColors.text3,
    PrescriptionMovementType.shortageReported => MedColors.amber,
    PrescriptionMovementType.replenishmentPending => MedColors.blue,
    PrescriptionMovementType.redirected => MedColors.text3,
  };

  Color get foregroundColor => switch (this) {
    PrescriptionMovementType.pendingApproval => MedColors.amberLight,
    PrescriptionMovementType.purchasePending => MedColors.blueLight,
    PrescriptionMovementType.applied => MedColors.greenLight,
    PrescriptionMovementType.returned => MedColors.blueLight,
    PrescriptionMovementType.wastaged => MedColors.amberLight,
    PrescriptionMovementType.destructed => MedColors.redLight,
    PrescriptionMovementType.cancelled => MedColors.redLight,
    PrescriptionMovementType.rejected => MedColors.redLight,
    PrescriptionMovementType.filledWaiting => MedColors.amberLight,
    PrescriptionMovementType.returnPending => MedColors.amberLight,
    PrescriptionMovementType.unloaded => MedColors.surface3,
    PrescriptionMovementType.shortageReported => MedColors.amberLight,
    PrescriptionMovementType.replenishmentPending => MedColors.blueLight,
    PrescriptionMovementType.redirected => MedColors.surface3,
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
    PrescriptionMovementType.shortageReported => PhosphorIcons.warningOctagon(PhosphorIconsStyle.fill),
    PrescriptionMovementType.replenishmentPending => PhosphorIcons.package(PhosphorIconsStyle.fill),
    PrescriptionMovementType.redirected => PhosphorIcons.arrowBendUpRight(PhosphorIconsStyle.fill),
  };

  MedTone get movementTone => switch (this) {
    // TODO: enum değerlerini kendi tipine göre eşle
    PrescriptionMovementType.purchasePending => MedTone.success, // alım
    PrescriptionMovementType.filledWaiting => MedTone.info, // dolum
    PrescriptionMovementType.wastaged => MedTone.warning, // iade
    PrescriptionMovementType.returned => MedTone.error, // fire/imha
    PrescriptionMovementType.redirected => MedTone.info,
    _ => MedTone.info,
  };
}

extension PrescriptionMovementTypeActions on PrescriptionMovementType {
  bool get canApprove => this == PrescriptionMovementType.pendingApproval;

  bool get canReject => this == PrescriptionMovementType.pendingApproval;

  bool get canCancel =>
      this == PrescriptionMovementType.pendingApproval || this == PrescriptionMovementType.purchasePending;

  // shortageReported iptal edilebilsin istersen yukarıdaki canCancel'a
  // `|| this == PrescriptionMovementType.shortageReported` ekle.

  bool get canFill =>
      this == PrescriptionMovementType.filledWaiting || this == PrescriptionMovementType.replenishmentPending;

  bool get canPurchase => this == PrescriptionMovementType.purchasePending;

  /// Eksik stok bildirme — yalnızca "Alım Bekliyor" durumunda.
  bool get canReportShortage => this == PrescriptionMovementType.purchasePending;

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
      this == PrescriptionMovementType.unloaded ||
      this == PrescriptionMovementType.redirected;

  /// Eğer durumu "Onay Bekliyor" ise hareket geçmişi olamaz.
  bool get canShowHistory => this != PrescriptionMovementType.pendingApproval;

  /// RFID etiketi silinebilir/değiştirilebilir mi.
  /// Sadece ilacın hayat döngüsünün ilk evrelerinde (alım öncesi) izinlidir.
  /// Admin rolü bu kuralı UI tarafında bypass eder.
  bool get canModifyRfid =>
      this == PrescriptionMovementType.pendingApproval ||
      this == PrescriptionMovementType.filledWaiting ||
      this == PrescriptionMovementType.purchasePending;
}
