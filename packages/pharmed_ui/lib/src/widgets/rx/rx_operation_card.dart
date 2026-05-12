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
}

// ---------------------------------------------------------------------------
// RxOperationCard
// ---------------------------------------------------------------------------

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

  Color get _borderColor {
    if (mode == RxOperationCardMode.intake && isSelected && _hasRfidTag && rfidStatus == RfidPresenceStatus.absent) {
      return MedColors.red;
    }
    return isSelected ? MedColors.blue : MedColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: MedRadius.mdAll,
        child: InkWell(
          onTap: isEligible ? onTap : null,
          borderRadius: MedRadius.mdAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: MedColors.surface,
              borderRadius: MedRadius.mdAll,
              border: Border.all(color: _borderColor, width: isSelected ? 1.5 : 1),
              boxShadow: MedShadows.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardBody(
                  item: item,
                  isSelected: isSelected,
                  needsRfid: _needsRfid,
                  showRfidLiveStatus: _showRfidLiveStatus,
                  isEligible: isEligible,
                ),
                if (_needsRfid && _hasRfidTag) ...[
                  Divider(height: 1, thickness: 1, color: MedColors.border2),
                  _RfidRow(rfidStatus: rfidStatus, showLiveStatus: _showRfidLiveStatus, tag: item.rfidTag!, mode: mode),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CardBody
// ---------------------------------------------------------------------------

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.item,
    required this.isSelected,
    required this.needsRfid,
    required this.showRfidLiveStatus,
    required this.isEligible,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final bool needsRfid;
  final bool showRfidLiveStatus;
  final bool isEligible;

  String get _doseText {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? 'Adet';
    return '$piece $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.medicine?.name ?? 'İsimsiz',
                        style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _doseText,
                      style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.medicine?.barcode != null) ...[
                      Text(item.medicine!.barcode!, style: MedTextStyles.monoXs()),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    if (item.time != null) TimeChip(time: item.time!),
                  ],
                ),
                const SizedBox(height: 10),
                RxStatusChip(status: item.status!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RfidRow
// ---------------------------------------------------------------------------

class _RfidRow extends StatelessWidget {
  const _RfidRow({required this.rfidStatus, required this.showLiveStatus, required this.tag, required this.mode});

  final RfidPresenceStatus? rfidStatus;
  final bool showLiveStatus;
  final String tag;
  final RxOperationCardMode mode;

  Color get _tagColor {
    if (rfidStatus == null) return MedColors.text3;
    return switch ((mode, rfidStatus!)) {
      (RxOperationCardMode.refill, RfidPresenceStatus.present) => MedColors.green,
      (RxOperationCardMode.refill, _) => MedColors.text3,
      (RxOperationCardMode.intake, RfidPresenceStatus.present) => MedColors.blue,
      (RxOperationCardMode.intake, RfidPresenceStatus.absent) => MedColors.red,
      (RxOperationCardMode.intake, RfidPresenceStatus.removed) => MedColors.green,
    };
  }

  Color get _rowBg {
    if (rfidStatus == null) return MedColors.surface2;
    return switch ((mode, rfidStatus!)) {
      (RxOperationCardMode.refill, RfidPresenceStatus.present) => MedColors.greenLight,
      (RxOperationCardMode.refill, _) => MedColors.surface2,
      (RxOperationCardMode.intake, RfidPresenceStatus.present) => MedColors.blueLight,
      (RxOperationCardMode.intake, RfidPresenceStatus.absent) => MedColors.redLight,
      (RxOperationCardMode.intake, RfidPresenceStatus.removed) => MedColors.greenLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _rowBg,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.tag(PhosphorIconsStyle.fill), size: 11, color: _tagColor),
          const SizedBox(width: 5),
          Text(tag, style: MedTextStyles.monoXs(color: _tagColor)),
          const Spacer(),
          if (showLiveStatus && rfidStatus != null)
            _RfidInlineStatus(status: rfidStatus!, mode: mode)
          else
            Text('RFID', style: MedTextStyles.monoXs(color: MedColors.text4)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RfidInlineStatus
// ---------------------------------------------------------------------------

class _RfidInlineStatus extends StatelessWidget {
  const _RfidInlineStatus({required this.status, required this.mode});

  final RfidPresenceStatus status;
  final RxOperationCardMode mode;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      RxOperationCardMode.refill => _buildRefillStatus(),
      RxOperationCardMode.intake => _buildIntakeStatus(),
    };
  }

  Widget _buildRefillStatus() => switch (status) {
    RfidPresenceStatus.present => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 12, color: MedColors.green),
        const SizedBox(width: 4),
        Text('Okundu', style: MedTextStyles.monoSm(color: MedColors.green)),
      ],
    ),
    _ => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: MedColors.amber)),
        const SizedBox(width: 4),
        Text('Bekleniyor', style: MedTextStyles.monoSm(color: MedColors.amber)),
      ],
    ),
  };

  Widget _buildIntakeStatus() => switch (status) {
    RfidPresenceStatus.present => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: MedColors.blue)),
        const SizedBox(width: 4),
        Text('Kabinde', style: MedTextStyles.monoSm(color: MedColors.blue)),
      ],
    ),
    RfidPresenceStatus.absent => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), size: 12, color: MedColors.red),
        const SizedBox(width: 4),
        Text('Kabinde değil', style: MedTextStyles.monoSm(color: MedColors.red)),
      ],
    ),
    RfidPresenceStatus.removed => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 12, color: MedColors.green),
        const SizedBox(width: 4),
        Text('Alındı', style: MedTextStyles.monoSm(color: MedColors.green)),
      ],
    ),
  };
}
