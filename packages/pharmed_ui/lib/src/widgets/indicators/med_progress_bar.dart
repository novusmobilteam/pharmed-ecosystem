import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedProgressBar
// [SWREQ-UI-ATOM-009]
// Kullanım: KPI kartı altındaki ince yatay doluluk çubuğu.
// value: 0.0 – 1.0 arası, dışarıdan clamp edilmiş olmalıdır.
// Sınıf: Class A
// ─────────────────────────────────────────────────────────────────

/// İnce yatay ilerleme çubuğu — KPI kartı altında kullanılır.
///
/// ```dart
/// MedProgressBar(value: 0.65, color: MedColors.blue)
/// MedProgressBar(value: 0, color: MedColors.blue, animated: true)  // yükleniyor
/// ```
class MedProgressBar extends StatelessWidget {
  const MedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 3,
    this.backgroundColor,
    this.animated = false,
  });

  /// 0.0 – 1.0. Dışarıdan clamp edilmeli; bu widget assert ile kontrol eder.
  /// animated: true olduğunda kullanılmaz.
  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;

  /// true → belirsiz (indeterminate) mod; veri yüklenirken kullanılır.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    assert(
      animated || (value >= 0.0 && value <= 1.0),
      'MedProgressBar.value $value aralık dışında [0.0, 1.0]',
    );
    return ClipRRect(
      borderRadius: MedRadius.smAll,
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: animated ? null : value,
          backgroundColor: backgroundColor ?? MedColors.surface3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: height,
        ),
      ),
    );
  }
}
