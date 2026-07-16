import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedFilterChip  (EMEKLİ / DEPRECATED)
// [SWREQ-UI-CHIP-FILTER-001]
//
// Bu widget MedSelectable'a taşındı. Geriye uyumluluk için imza korundu
// ve gövde MedSelectable(shape: pill)'e delege ediliyor.
//
// YENİ KOD İÇİN: doğrudan MedSelectable kullanın —
//   MedSelectable(
//     label: 'Uygulandı', count: 5, selected: isActive,
//     shape: MedSelectableShape.pill, onTap: ...,
//   )
//
// NOT: Eski MedFilterChip serbest renk (activeBackgroundColor/
//   activeForegroundColor) alıyordu. MedSelectable accent tabanlıdır
//   (blue/amber/green/red). Serbest renk verilen çağrılar en yakın
//   accent'e eşlenir; tam serbest renk gerekiyorsa MedChip(onTap:)
//   kullanın.
// ─────────────────────────────────────────────────────────────────

@Deprecated('MedSelectable(shape: pill) kullanın. Migrasyon için chip skill notlarına bakın.')
class MedFilterChip extends StatelessWidget {
  const MedFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.count,
    this.activeBackgroundColor,
    this.activeForegroundColor,
  });

  final String label;
  final int? count;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeBackgroundColor;
  final Color? activeForegroundColor;

  @override
  Widget build(BuildContext context) {
    // Serbest renk verilmişse MedChip ile birebir eşle (tıklanabilir).
    if (isActive && (activeBackgroundColor != null || activeForegroundColor != null)) {
      return MedChip(
        label: label,
        count: count,
        background: activeBackgroundColor ?? MedColors.blueLight,
        foreground: activeForegroundColor ?? MedColors.blue,
        mono: false,
        onTap: onTap,
      );
    }

    return MedSelectable(
      label: label,
      count: count,
      selected: isActive,
      shape: MedSelectableShape.pill,
      accent: MedAccent.blue,
      onTap: onTap,
    );
  }
}
