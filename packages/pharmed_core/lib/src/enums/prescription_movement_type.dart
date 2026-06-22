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
  replenishmentPending(13);

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
    PrescriptionMovementType.shortageReported => 'Eksik Bildirildi',
    PrescriptionMovementType.replenishmentPending => 'Dolum Bekliyor',
  };

  /// Hareketi gerçekleştiren kişiyi betimleyen etiket.
  /// UI'da "Oluşturan", "Onaylayan" gibi gösterilir.
  String get actorLabel => switch (this) {
    PrescriptionMovementType.pendingApproval => 'Oluşturan',
    PrescriptionMovementType.filledWaiting => 'Onaylayan',
    PrescriptionMovementType.purchasePending => 'Dolum Yapan',
    PrescriptionMovementType.applied => 'Uygulayan',
    PrescriptionMovementType.returned => 'İade Eden',
    PrescriptionMovementType.wastaged => 'Fire Eden',
    PrescriptionMovementType.destructed => 'İmha Eden',
    PrescriptionMovementType.cancelled => 'İptal Eden',
    PrescriptionMovementType.rejected => 'Reddeden',
    PrescriptionMovementType.returnPending => 'İade Talep Eden',
    PrescriptionMovementType.unloaded => 'Boşaltan',
    PrescriptionMovementType.shortageReported => 'Eksik Bildiren',
    PrescriptionMovementType.replenishmentPending => 'İkmal Onaylayan',
  };

  /// Bu duruma **geçişi sağlayan eylem**i betimler.
  ///
  /// [label] o anki durumu ("Alım Bekliyor") gösterir; aktivite/hareket
  /// geçmişinde ise "ne yapıldığı" anlamlıdır. Bu getter o eylemi verir.
  ///
  /// Not: Bazı durumlara birden fazla eylemle gelinebilir (ör. purchasePending
  /// hem onaylama hem dolum ile). Burada iş akışındaki **baskın/temsili** eylem
  /// seçilmiştir; actorLabel ile tutarlıdır.
  String get actionLabel => switch (this) {
    PrescriptionMovementType.pendingApproval => 'Oluşturuldu',
    PrescriptionMovementType.purchasePending => 'Dolum Yapıldı',
    PrescriptionMovementType.applied => 'Uygulandı',
    PrescriptionMovementType.returned => 'İade Edildi',
    PrescriptionMovementType.wastaged => 'Fire Edildi',
    PrescriptionMovementType.destructed => 'İmha Edildi',
    PrescriptionMovementType.cancelled => 'İptal Edildi',
    PrescriptionMovementType.rejected => 'Reddedildi',
    PrescriptionMovementType.filledWaiting => 'Onaylandı',
    PrescriptionMovementType.returnPending => 'İade Talep Edildi',
    PrescriptionMovementType.unloaded => 'Boşaltıldı',
    PrescriptionMovementType.shortageReported => 'Eksik Bildirildi',
    PrescriptionMovementType.replenishmentPending => 'İkmal Onaylandı',
  };
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
      this == PrescriptionMovementType.unloaded;

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
