import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedMedInfoChip
// [SWREQ-UI-CHIP-INFO-001]
// Kullanım: Genel amaçlı bilgi chip'i — dolum listesi, reçete paneli.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Genel bilgi chip'i — null info ise gizlenir.
///
/// ```dart
/// MedMedInfoChip(info: 'Acil', backgroundColor: MedColors.redLight, foregroundColor: MedColors.red)
/// ```
class MedInfoChip extends StatelessWidget {
  const MedInfoChip({super.key, this.info, this.backgroundColor, this.foregroundColor});

  final String? info;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (info == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? MedColors.blueLight,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: foregroundColor?.withAlpha(55) ?? Colors.transparent),
      ),
      child: Text(
        info!,
        textAlign: TextAlign.center,
        style: MedTextStyles.monoSm(color: foregroundColor ?? MedColors.blue),
      ),
    );
  }
}
