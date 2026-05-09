import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─────────────────────────────────────────────────────────────────
// MedRemainingDayChip
// [SWREQ-UI-CHIP-RDC-001]
// Kullanım: SKT listesi ve stok tablosundaki kalan gün göstergesi.
// Sınıf  : Class B — SKT bilgisini temsil eder
// ─────────────────────────────────────────────────────────────────

enum _RdcStatus { expired, critical, warning, normal }

/// SKT kalan gün chip'i — expired/critical/warning/normal renk kodlaması.
///
/// ```dart
/// MedRemainingDayChip(days: remainingDays)
/// ```
class MedRemainingDayChip extends StatelessWidget {
  const MedRemainingDayChip({super.key, required this.days});

  final int days;

  _RdcStatus get _status {
    if (days < 0) return _RdcStatus.expired;
    if (days <= 7) return _RdcStatus.critical;
    if (days <= 30) return _RdcStatus.warning;
    return _RdcStatus.normal;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _RdcStatus.expired => _Badge(
        label: '${days.abs()}g geçti',
        icon: PhosphorIcons.warning(),
        color: MedColors.red,
        bgColor: MedColors.redLight,
        borderColor: const Color(0xFFFECACA),
      ),
      _RdcStatus.critical => _Badge(
        label: '$days gün',
        icon: PhosphorIcons.timer(),
        color: MedColors.red,
        bgColor: MedColors.redLight,
        borderColor: const Color(0xFFFECACA),
      ),
      _RdcStatus.warning => _Badge(
        label: '$days gün',
        icon: PhosphorIcons.hourglass(),
        color: MedColors.amber,
        bgColor: MedColors.amberLight,
        borderColor: const Color(0xFFFDE68A),
      ),
      _RdcStatus.normal => _Badge(
        label: '$days gün',
        icon: PhosphorIcons.checkCircle(),
        color: MedColors.green,
        bgColor: MedColors.greenLight,
        borderColor: const Color(0xFFA7F3D0),
      ),
    };
  }
}

/// Backward compat alias.
typedef RemainingDayChip = MedRemainingDayChip;

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color color, bgColor, borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
