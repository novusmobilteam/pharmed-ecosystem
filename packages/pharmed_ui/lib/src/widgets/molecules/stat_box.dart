import 'package:flutter/material.dart';
import 'package:pharmed_ui/src/widgets/atoms/med_label.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// StatBox
// [SWREQ-UI-MOL-003] [HAZ-007]
// Kullanım: Kabin widget'ındaki 4'lü istatistik kutularından biri
//   Çekmece, Kritik Stok, Bugün İşlem, Son Açılış
// Atomlar : MedLabel (cardLabel + cardSub) + değer metni
// Sınıf  : Class B — isStale durumunda soluk gösterilmeli
// ─────────────────────────────────────────────────────────────────

class StatBox extends StatelessWidget {
  const StatBox({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.subLabel,
    this.isStale = false,
  });

  final String label;
  final String value;
  final Color valueColor;

  /// Örn: "12 dolu · 3 boş", "son 8 saat"
  final String? subLabel;

  /// [HAZ-007] stale → opacity düşer
  final bool isStale;

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
        child: Column(
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
        ),
      ),
    );
  }
}
