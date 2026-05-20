import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// [SWREQ-CLI-CABIN-OP-010] [IEC 62304 §5.5]
// Reçete bazlı kabin işlem kartı.
//
// Dolum, alım, iade ve fire gibi reçete item'ı içeren tüm kabin
// işlemlerinde ortak kullanılır. RFID durum gösterimi [RxOperationCardMode]
// ile işlem tipine, [RfidPresenceStatus] ile fiziksel etiket durumuna göre
// özelleştirilir.
//
// Sınıf: Class B

// ---------------------------------------------------------------------------
// Enum — RFID fiziksel varlık durumu
// ---------------------------------------------------------------------------

/// RFID etiketinin fiziksel varlık durumu.
///
/// İşlem semantiğinden bağımsız olarak etiketin kabindeki durumunu tanımlar.
/// Görsel label ve renk [RxOperationCardMode] ile birlikte belirlenir.
///
/// ## Dolum modunda ([RxOperationCardMode.refill])
/// - [absent]  → 🟡 Bekleniyor (ilaç henüz kabine konulmadı)
/// - [present] → 🟢 Okundu (ilaç kabine yerleştirildi)
///
/// ## Alım modunda ([RxOperationCardMode.intake])
/// - [present] → 🔵 Kabinde (EPC okunuyor, ilaç henüz alınmadı)
/// - [absent]  → 🔴 Kabinde değil (EPC okunmuyor, ilaç bulunamadı)
/// - [removed] → 🟢 Alındı (EPC kayboldu, ilaç kasıtlı çıkarıldı)
enum RfidPresenceStatus {
  /// EPC okunuyor — ilaç fiziksel olarak kapsama alanında.
  present,

  /// EPC okunmuyor — ilaç kapsama alanında değil.
  /// Dolumda: henüz konulmadı. Alımda: bulunamadı (uyarı).
  absent,

  /// EPC kayboldu — ilaç kasıtlı olarak çıkarıldı.
  /// Alımda: alındı. Boşaltmada: boşaltıldı.
  removed,
}

// ---------------------------------------------------------------------------
// Enum — Kart modu
// ---------------------------------------------------------------------------

/// [RxOperationCard] için işlem modu.
///
/// [RfidPresenceStatus] ile birlikte RFID durum gösteriminin
/// görsel ve metinsel içeriğini belirler.
enum RxOperationCardMode {
  /// Dolum modu.
  ///
  /// - [RfidPresenceStatus.absent]  → 🟡 Bekleniyor
  /// - [RfidPresenceStatus.present] → 🟢 Okundu
  refill,

  /// Alım modu.
  ///
  /// - [RfidPresenceStatus.present] → 🔵 Kabinde
  /// - [RfidPresenceStatus.absent]  → 🔴 Kabinde değil
  /// - [RfidPresenceStatus.removed] → 🟢 Alındı
  intake,

  census,
}

class RxOperationCard extends StatelessWidget {
  const RxOperationCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.rfidStatus,
    required this.isEligible,
    required this.mode,
    required this.onTap,
  });

  final PrescriptionItem item;
  final bool isSelected;

  /// RFID etiketinin fiziksel varlık durumu.
  ///
  /// `null` verilirse RFID session başlamamış demektir;
  /// satır gösterilir ama live status gizlenir.
  final RfidPresenceStatus? rfidStatus;

  final bool isEligible;

  /// RFID durum gösteriminin semantiğini belirler.
  final RxOperationCardMode mode;

  /// `null` ise kart tıklanamaz (süreç aktif veya item.id yok).
  final VoidCallback? onTap;

  bool get _needsRfid {
    if (item.medicine == null || !item.medicine!.isDrug) return false;
    return (item.medicine as Drug).isRfidEnable;
  }

  bool get _hasRfidTag => item.rfidTag != null;
  bool get _isLocked => onTap == null;
  bool get _showRfidLiveStatus => _isLocked && isSelected && _needsRfid && _hasRfidTag;
  bool get _isActive => isSelected && _isLocked;

  Color get _borderColor {
    if (mode == RxOperationCardMode.intake && isSelected && _hasRfidTag && rfidStatus == RfidPresenceStatus.absent) {
      return MedColors.red;
    }
    return isSelected ? MedColors.blue : MedColors.border;
  }

  String get _doseText {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? 'Adet';
    return '$piece $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: isEligible ? onTap : null,
        borderRadius: MedRadius.mdAll,
        child: AnimatedContainer(
          padding: MedSpacing.insetLg,
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: MedColors.surface,
            borderRadius: MedRadius.lgAll,
            border: Border.all(color: _borderColor, width: isSelected ? 1.5 : 1),
            boxShadow: MedShadows.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// İlaç ismi ve Doz
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.medicine?.name ?? 'İsimsiz',
                      style: MedTextStyles.titleSm(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _doseText,
                    style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w600),
                  ),
                ],
              ),

              /// Barkod
              if (item.medicine?.barcode != null) ...[
                Text(item.medicine!.barcode!, style: MedTextStyles.bodySm(color: MedColors.text4)),
              ],

              SizedBox(height: 16.0),

              if (_needsRfid && _hasRfidTag)
                _RfidRow(
                  rfidStatus: rfidStatus,
                  showLiveStatus: _showRfidLiveStatus,
                  tag: item.rfidTag!,
                  mode: mode,
                  isActive: _isActive,
                ),

              SizedBox(height: 12.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.status != null) RxStatusChip(status: item.status!),
                  if (item.time != null) TimeChip(time: item.time!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RfidRow extends StatelessWidget {
  const _RfidRow({
    required this.rfidStatus,
    required this.showLiveStatus,
    required this.tag,
    required this.mode,
    required this.isActive, // 🆕
  });

  final RfidPresenceStatus? rfidStatus;
  final bool showLiveStatus;
  final String tag;
  final RxOperationCardMode mode;

  /// Çekmece açık ve RFID session aktif mi?
  ///
  /// `false` → kart seçili değil veya çekmece kapandı → her zaman gri.
  /// `true` + `rfidStatus == null` → session henüz başlamadı → gri placeholder.
  /// `true` + `rfidStatus != null` → normal renk matrisi.
  final bool isActive;

  Color get _tagColor {
    if (!isActive || rfidStatus == null) return MedColors.text3;
    return switch ((mode, rfidStatus!)) {
      // Dolum: okundu → yeşil, bekleniyor → mavi
      (RxOperationCardMode.refill, RfidPresenceStatus.present) => MedColors.green,
      (RxOperationCardMode.refill, _) => MedColors.blue,
      // Alım: kabinde → mavi, kabinde değil → kırmızı, alındı → yeşil
      (RxOperationCardMode.intake, RfidPresenceStatus.present) => MedColors.blue,
      (RxOperationCardMode.intake, RfidPresenceStatus.absent) => MedColors.red,
      (RxOperationCardMode.intake, RfidPresenceStatus.removed) => MedColors.green,
      // Sayım: kabinde → yeşil, eksik → kırmızı
      (RxOperationCardMode.census, RfidPresenceStatus.present) => MedColors.green,
      (RxOperationCardMode.census, _) => MedColors.red,
    };
  }

  Color get _rowBg {
    if (!isActive || rfidStatus == null) return MedColors.surface2;
    return switch ((mode, rfidStatus!)) {
      // Dolum
      (RxOperationCardMode.refill, RfidPresenceStatus.present) => MedColors.greenLight,
      (RxOperationCardMode.refill, _) => MedColors.blueLight,
      // Alım
      (RxOperationCardMode.intake, RfidPresenceStatus.present) => MedColors.blueLight,
      (RxOperationCardMode.intake, RfidPresenceStatus.absent) => MedColors.redLight,
      (RxOperationCardMode.intake, RfidPresenceStatus.removed) => MedColors.greenLight,
      // Sayım
      (RxOperationCardMode.census, RfidPresenceStatus.present) => MedColors.greenLight,
      (RxOperationCardMode.census, _) => MedColors.redLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: _rowBg, borderRadius: BorderRadius.circular(6.0)),
      child: Row(
        children: [
          Icon(PhosphorIcons.tag(), size: 14, color: _tagColor),
          const SizedBox(width: 5),
          Text(tag, style: MedTextStyles.monoXs(color: _tagColor)),
          const Spacer(),
          if (showLiveStatus && isActive && rfidStatus != null) _RfidInlineStatus(status: rfidStatus!, mode: mode),
        ],
      ),
    );
  }
}

class _RfidInlineStatus extends StatelessWidget {
  const _RfidInlineStatus({required this.status, required this.mode});

  final RfidPresenceStatus status;
  final RxOperationCardMode mode;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      RxOperationCardMode.refill => _buildRefillStatus(),
      RxOperationCardMode.intake => _buildIntakeStatus(),
      RxOperationCardMode.census => _buildCensusStatus(),
    };
  }

  Widget _buildRefillStatus() => switch (status) {
    RfidPresenceStatus.present => _StatusChip.check(label: 'Okundu', color: MedColors.green),
    _ => _StatusChip.spinner(label: 'Bekleniyor', color: MedColors.blue),
  };

  Widget _buildIntakeStatus() => switch (status) {
    RfidPresenceStatus.present => _StatusChip.spinner(label: 'Kabinde', color: MedColors.blue),
    RfidPresenceStatus.absent => _StatusChip.warning(label: 'Kabinde değil', color: MedColors.red),
    RfidPresenceStatus.removed => _StatusChip.check(label: 'Alındı', color: MedColors.green),
  };

  /// Sayım semantiği:
  /// - present → ilaç kabinde fiziksel olarak mevcut → sayım geçerli
  /// - absent  → ilaç okunmuyor → eksik
  /// - removed → sayım ekranında bu durum oluşmaz (alım semantiğine özgü)
  Widget _buildCensusStatus() => switch (status) {
    RfidPresenceStatus.present => _StatusChip.check(label: 'Kabinde', color: MedColors.green),
    RfidPresenceStatus.absent => _StatusChip.warning(label: 'Eksik', color: MedColors.red),
    RfidPresenceStatus.removed => _StatusChip.warning(label: 'Eksik', color: MedColors.red),
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip.check({required this.label, required this.color}) : _type = _ChipType.check;
  const _StatusChip.spinner({required this.label, required this.color}) : _type = _ChipType.spinner;
  const _StatusChip.warning({required this.label, required this.color}) : _type = _ChipType.warning;

  final String label;
  final Color color;
  final _ChipType _type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLeading(),
        const SizedBox(width: 4),
        Text(label, style: MedTextStyles.monoSm(color: color)),
      ],
    );
  }

  Widget _buildLeading() => switch (_type) {
    _ChipType.check => Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 14, color: color),
    _ChipType.warning => Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), size: 14, color: color),
    _ChipType.spinner => SizedBox(
      width: 10,
      height: 10,
      child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
    ),
  };
}

enum _ChipType { check, warning, spinner }
