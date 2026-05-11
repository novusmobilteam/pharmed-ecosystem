import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedStatBox
// [SWREQ-UI-MOL-003] [HAZ-007]
// Kullanım: Kabin widget'ındaki 4'lü istatistik kutularından biri
//   Çekmece, Kritik Stok, Bugün İşlem, Son Açılış
// Atomlar : MedLabel (cardLabel + cardSub) + değer metni
// Sınıf  : Class B — isStale durumunda soluk gösterilmeli
// ─────────────────────────────────────────────────────────────────

enum MedStatBoxLayout { vertical, horizontal }

/// İstatistik kutusu — label, değer, opsiyonel alt etiket.
///
/// ```dart
/// MedStatBox(label: 'Kritik Stok', value: '3', valueColor: MedColors.red)
/// MedStatBox(..., layout: MedStatBoxLayout.horizontal)  // label solda, değer sağda
/// ```
class MedStatBox extends StatelessWidget {
  const MedStatBox({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.subLabel,
    this.isStale = false,
    this.layout = MedStatBoxLayout.vertical,
  });

  final String label;
  final String value;
  final Color valueColor;

  /// Örn: "12 dolu · 3 boş", "son 8 saat"
  final String? subLabel;

  /// [HAZ-007] stale → opacity düşer
  final bool isStale;

  /// vertical: label üstte, değer altta. horizontal: label solda, değer sağda.
  final MedStatBoxLayout layout;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isStale ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border2),
          borderRadius: MedRadius.mdAll,
        ),
        child: layout == MedStatBoxLayout.horizontal ? _buildHorizontal() : _buildVertical(),
      ),
    );
  }

  Widget _buildVertical() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedLabel(text: label, variant: MedLabelVariant.cardLabel),
        const SizedBox(height: 4),
        Text(value, style: MedTextStyles.titleLg(color: valueColor)),
        if (subLabel != null) ...[
          const SizedBox(height: 2),
          MedLabel(text: subLabel!, variant: MedLabelVariant.cardSub),
        ],
      ],
    );
  }

  Widget _buildHorizontal() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedLabel(text: label, variant: MedLabelVariant.cardLabel),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                MedLabel(text: subLabel!, variant: MedLabelVariant.cardSub),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: MedTextStyles.titleLg(color: valueColor)),
      ],
    );
  }
}

/// Backward compat alias.
typedef StatBox = MedStatBox;
