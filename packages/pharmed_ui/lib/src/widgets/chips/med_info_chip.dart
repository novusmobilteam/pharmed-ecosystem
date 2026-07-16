import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedInfoChip
// [SWREQ-UI-CHIP-INFO-001]
// Genel amaçlı bilgi chip'i. Artık MedChip primitive'ine delege eder;
// çağrı imzası korunur (geriye uyumlu). info null ise gizlenir.
// ─────────────────────────────────────────────────────────────────

/// Genel bilgi chip'i — null info ise gizlenir.
///
/// ```dart
/// MedInfoChip(info: 'Acil', backgroundColor: MedColors.redLight, foregroundColor: MedColors.red)
/// ```
class MedInfoChip extends StatelessWidget {
  const MedInfoChip({super.key, this.info, this.backgroundColor, this.foregroundColor});

  final String? info;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (info == null) return const SizedBox.shrink();
    return MedChip(
      label: info!,
      background: backgroundColor ?? MedColors.blueLight,
      foreground: foregroundColor ?? MedColors.blue,
    );
  }
}
