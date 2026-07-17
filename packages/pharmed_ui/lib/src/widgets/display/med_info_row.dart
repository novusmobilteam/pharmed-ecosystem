import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedInfoRow
// [SWREQ-UI-ATOM-ROW-001]
// Etiket + değer satırı. Sabit genişlikli label, esnek value.
// Kart içi bilgi listeleri için (hasta, servis, doktor vb.).
// Sınıf : Class A
// ─────────────────────────────────────────────────────────────────

/// Etiketli bilgi satırı.
///
/// ```dart
/// MedInfoRow(label: 'HASTA', value: patient.fullName)
/// ```
class MedInfoRow extends StatelessWidget {
  const MedInfoRow({super.key, required this.label, required this.value, this.labelWidth = 100, this.trailing});

  final String label;
  final String value;
  final double labelWidth;

  /// Değerin sağında opsiyonel widget (ör. protokol no).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(label, style: MedTextStyles.monoXs(color: MedColors.text3).copyWith(letterSpacing: 0.5)),
        ),
        Text(
          value,
          style: MedTextStyles.bodyMd(color: MedColors.text2, weight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
