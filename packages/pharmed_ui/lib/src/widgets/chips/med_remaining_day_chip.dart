import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// TODO : Localization

// ─────────────────────────────────────────────────────────────────
// MedRemainingDayChip
// [SWREQ-UI-CHIP-RDC-001]
// SKT kalan gün göstergesi — expired/critical/warning/normal renk
// kodlaması. Eşik→durum mantığı burada; görsel iskelet MedChip'te.
// Sınıf: Class B (SKT bilgisini temsil eder)
// ─────────────────────────────────────────────────────────────────

enum _RdcStatus { expired, critical, warning, normal }

/// SKT kalan gün chip'i.
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
      _RdcStatus.expired => MedChip(
        label: '${days.abs()}g geçti',
        icon: PhosphorIcons.warning(),
        style: MedChipStyle.danger,
        mono: false,
      ),
      _RdcStatus.critical => MedChip(
        label: '$days gün',
        icon: PhosphorIcons.timer(),
        style: MedChipStyle.danger,
        mono: false,
      ),
      _RdcStatus.warning => MedChip(
        label: '$days gün',
        icon: PhosphorIcons.hourglass(),
        style: MedChipStyle.warning,
        mono: false,
      ),
      _RdcStatus.normal => MedChip(
        label: '$days gün',
        icon: PhosphorIcons.checkCircle(),
        style: MedChipStyle.success,
        mono: false,
      ),
    };
  }
}

/// Backward compat alias.
typedef RemainingDayChip = MedRemainingDayChip;
