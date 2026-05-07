import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// [SWREQ-CLI-REFILL-001] [IEC 62304 §5.5]
// Mobil kabin dolum ekranı — ilaç kartı bileşeni.
// Kullanıcı dolum başlamadan önce hangi ilaçları yerleştireceğini bu kartlardan
// seçer (toggle). Süreç başladıktan sonra (isProcessActive=true) seçim kilitli
// hale gelir; kart hâlâ RFID okuma durumunu gösterir.
//
// Sınıf: Class B

class RefillRxCard extends StatelessWidget {
  const RefillRxCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isRfidRead,
    required this.onTap,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final bool isRfidRead;

  /// `null` ise kart tıklanamaz (süreç başladı veya item.id yok).
  final VoidCallback? onTap;

  bool get _needsRfid {
    if (item.medicine == null || !item.medicine!.isDrug) return false;
    return (item.medicine as Drug).isRfidEnable;
  }

  bool get _hasRfidTag => item.rfidTag != null;

  /// Seçim kilitli mi? (onTap null → süreç aktif veya item geçersiz)
  bool get _isLocked => onTap == null;

  /// RFID inline durum gösterilsin mi?
  /// Kilitliyken (=süreç aktif) ve seçili + RFID etiketi olan kartlarda gösterilir.
  bool get _showRfidLiveStatus => _isLocked && isSelected && _needsRfid && _hasRfidTag;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? MedColors.blue : MedColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: MedRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: MedRadius.mdAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: MedColors.surface,
              borderRadius: MedRadius.mdAll,
              border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
              boxShadow: MedShadows.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardBody(
                  item: item,
                  isSelected: isSelected,
                  isRfidRead: isRfidRead,
                  needsRfid: _needsRfid,
                  showRfidLiveStatus: _showRfidLiveStatus,
                ),
                if (_needsRfid && _hasRfidTag) ...[
                  Divider(height: 1, thickness: 1, color: MedColors.border2),
                  _RfidRow(isRead: isRfidRead, showLiveStatus: _showRfidLiveStatus, tag: item.rfidTag!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Kart gövdesi ─────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.item,
    required this.isSelected,
    required this.isRfidRead,
    required this.needsRfid,
    required this.showRfidLiveStatus,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final bool isRfidRead;
  final bool needsRfid;
  final bool showRfidLiveStatus;

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
          // Selection indicator (checkbox)
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 10),
            child: _SelectionIndicator(isSelected: isSelected),
          ),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır: ilaç adı + miktar
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

                // Alt satır: barkod + saat chip
                Row(
                  children: [
                    if (item.medicine?.barcode != null) ...[
                      Text(item.medicine!.barcode!, style: MedTextStyles.monoXs()),
                      const SizedBox(width: 8),
                    ],
                    if (item.time != null) _TimeChip(time: item.time!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Selection indicator (checkbox tarzı) ─────────────────────────────────────

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isSelected ? MedColors.blue : Colors.transparent,
        border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isSelected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
    );
  }
}

// ── RFID şerit (kart altında) ────────────────────────────────────────────────

class _RfidRow extends StatelessWidget {
  const _RfidRow({required this.isRead, required this.showLiveStatus, required this.tag});

  final bool isRead;
  final bool showLiveStatus;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final color = isRead ? MedColors.green : MedColors.text3;
    final bg = isRead ? MedColors.greenLight : MedColors.surface2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.tag(PhosphorIconsStyle.fill), size: 11, color: color),
          const SizedBox(width: 5),
          Text(tag, style: MedTextStyles.monoXs(color: color)),
          const Spacer(),
          if (showLiveStatus)
            _RfidInlineStatus(isRead: isRead)
          else
            Text('RFID', style: MedTextStyles.monoXs(color: MedColors.text4)),
        ],
      ),
    );
  }
}

// ── RFID inline durum ────────────────────────────────────────────────────────

class _RfidInlineStatus extends StatelessWidget {
  const _RfidInlineStatus({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    if (isRead) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 12, color: MedColors.green),
          const SizedBox(width: 4),
          Text('Okundu', style: MedTextStyles.monoSm(color: MedColors.green)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: MedColors.amber)),
        const SizedBox(width: 4),
        Text('Bekleniyor', style: MedTextStyles.monoSm(color: MedColors.amber)),
      ],
    );
  }
}

// ── Saat chip ────────────────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});

  final DateTime time;

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final timeDay = DateTime(time.year, time.month, time.day);
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';
    if (timeDay == today) return timeStr;
    if (timeDay == tomorrow) return 'Yarın $timeStr';
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${days[time.weekday - 1]} $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: MedColors.amberLight,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.amber.withValues(alpha: 0.3)),
      ),
      child: Text(_label, style: MedTextStyles.monoXs(color: MedColors.amber)),
    );
  }
}
