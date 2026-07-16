import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedBadge  (EMEKLİ / DEPRECATED)
// [SWREQ-UI-ATOM-001]
//
// MedChip'e taşındı. Badge = MedChip(shape: pill, showBorder: false).
// Geriye uyumluluk için imza korundu.
//
// YENİ KOD İÇİN:
//   MedChip(label: '7 Bekliyor', style: MedChipStyle.warning,
//           shape: MedChipShape.pill, showBorder: false)
// ─────────────────────────────────────────────────────────────────

enum MedBadgeVariant { green, amber, red, blue, neutral }

enum MedBadgeSize { sm, md }

@Deprecated('MedChip(shape: pill, showBorder: false) kullanın.')
class MedBadge extends StatelessWidget {
  const MedBadge({super.key, required this.label, required this.variant, this.size = MedBadgeSize.md});

  final String label;
  final MedBadgeVariant variant;
  final MedBadgeSize size;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      label: label,
      style: _style(variant),
      shape: MedChipShape.pill,
      size: size == MedBadgeSize.sm ? MedChipSize.sm : MedChipSize.md,
      showBorder: false,
    );
  }

  MedChipStyle _style(MedBadgeVariant v) => switch (v) {
    MedBadgeVariant.green => MedChipStyle.success,
    MedBadgeVariant.amber => MedChipStyle.warning,
    MedBadgeVariant.red => MedChipStyle.danger,
    MedBadgeVariant.blue => MedChipStyle.info,
    MedBadgeVariant.neutral => MedChipStyle.neutral,
  };
}
