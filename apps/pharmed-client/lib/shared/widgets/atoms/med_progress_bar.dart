import 'package:flutter/material.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedProgressBar
// [SWREQ-UI-ATOM-009]
// Kullanım: KPI kartı altındaki ince yatay doluluk çubuğu
// value: 0.0 – 1.0 arası, dışarıdan clamp edilmiş olmalıdır.
// Sınıf: Class A
// ─────────────────────────────────────────────────────────────────

class MedProgressBar extends StatelessWidget {
  const MedProgressBar({super.key, required this.value, required this.color, this.height = 3, this.backgroundColor});

  /// 0.0 – 1.0. Dışarıdan clamp edilmeli; bu widget assert ile kontrol eder.
  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    assert(value >= 0.0 && value <= 1.0, 'MedProgressBar.value $value dışında aralık [0.0, 1.0]');

    return ClipRRect(
      borderRadius: MedRadius.smAll,
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor ?? MedColors.surface3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: height,
        ),
      ),
    );
  }
}
