import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedFilterChip
// [SWREQ-UI-CHIP-FILTER-001]
// Kullanım: Filtre satırları — reçete paneli, dolum listesi vb.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Filtre chip'i — aktif/pasif durumlu, opsiyonel sayaç.
///
/// Varsayılan aktif renk mavi; status bazlı renkler için
/// [activeBackgroundColor] / [activeForegroundColor] override edilir.
///
/// ```dart
/// // Sade
/// MedFilterChip(label: 'Tümü', isActive: true, onTap: () {})
///
/// // Sayaçlı
/// MedFilterChip(label: 'Uygulandı', count: 5, isActive: false, onTap: () {})
///
/// // Renkli (status bazlı)
/// MedFilterChip(
///   label: 'İade edildi',
///   count: 2,
///   isActive: true,
///   activeBackgroundColor: MedColors.blueLight,
///   activeForegroundColor: MedColors.blue,
///   onTap: () {},
/// )
/// ```
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

  /// Chip üzerinde gösterilecek sayaç; null ise gösterilmez.
  final int? count;

  final bool isActive;
  final VoidCallback onTap;

  /// Aktif durumdaki arka plan rengi; null → [MedColors.blueLight]
  final Color? activeBackgroundColor;

  /// Aktif durumdaki metin/sayaç rengi; null → [MedColors.blue]
  final Color? activeForegroundColor;

  Color get _activeBg => activeBackgroundColor ?? MedColors.blueLight;
  Color get _activeFg => activeForegroundColor ?? MedColors.blue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? _activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? Border.all(color: _activeFg.withAlpha(55), width: 1) : Border.all(color: MedColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: MedTextStyles.bodySm(
                color: isActive ? _activeFg : MedColors.text3,
              ).copyWith(fontWeight: isActive ? FontWeight.w600 : FontWeight.w400),
            ),
            if (count != null) ...[
              const SizedBox(width: MedSpacing.xs),
              Text(
                '$count',
                style: MedTextStyles.monoSm(
                  color: isActive ? _activeFg : MedColors.text4,
                ).copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
