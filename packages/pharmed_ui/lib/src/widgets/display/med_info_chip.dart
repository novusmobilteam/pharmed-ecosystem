import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedInfoChip
// [SWREQ-UI-CHIP-INFO-001]
// Kullanım: Genel amaçlı bilgi chip'i — dolum listesi, reçete paneli.
// Sınıf  : Class A
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? MedColors.blueLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        info!,
        textAlign: TextAlign.center,
        style: MedTextStyles.monoSm(color: foregroundColor ?? MedColors.blue).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Backward compat alias.
typedef InfoChip = MedInfoChip;
