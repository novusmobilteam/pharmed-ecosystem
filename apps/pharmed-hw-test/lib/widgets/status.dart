// Test durumlarının görsel karşılığı. Renkler pharmed_ui'deki tek kaynaktan
// (MedTone → MedSemanticColors) gelir; uygulamada başka durum rengi
// tanımlanmaz.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../core/test_status.dart';

extension TestStatusStyle on TestStatus {
  MedTone get tone => switch (this) {
    TestStatus.passed => MedTone.success,
    TestStatus.failed => MedTone.error,
    TestStatus.warning => MedTone.warning,
    TestStatus.running => MedTone.info,
    TestStatus.pending || TestStatus.skipped || TestStatus.info => MedTone.neutral,
  };

  MedSemanticColors get colors => MedSemanticColors.of(tone);

  /// Metin / ikon rengi.
  Color get color => colors.foreground;

  IconData get icon => switch (this) {
    TestStatus.pending => Icons.radio_button_unchecked,
    TestStatus.running => Icons.sync,
    TestStatus.passed => Icons.check_circle,
    TestStatus.failed => Icons.cancel,
    TestStatus.warning => Icons.warning_amber_rounded,
    TestStatus.skipped => Icons.remove_circle_outline,
    TestStatus.info => Icons.info_outline,
  };

  MedChipStyle get chipStyle => switch (tone) {
    MedTone.success => MedChipStyle.success,
    MedTone.error => MedChipStyle.danger,
    MedTone.warning => MedChipStyle.warning,
    MedTone.info => MedChipStyle.info,
    MedTone.neutral => MedChipStyle.neutral,
  };
}

/// Durum rozeti: ikon + etiket. [label] verilmezse durumun kendi adı yazılır.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.label});

  final TestStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      label: label ?? status.label,
      icon: status.icon,
      style: status.chipStyle,
      shape: MedChipShape.pill,
      size: MedChipSize.sm,
      mono: false,
    );
  }
}

/// Liste satırları için yalnız ikon. Çalışan durumda dönen gösterge çizilir.
class StatusIcon extends StatelessWidget {
  const StatusIcon({super.key, required this.status, this.size = 18});

  final TestStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (status == TestStatus.running) {
      return SizedBox(
        width: size,
        height: size,
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: CircularProgressIndicator(strokeWidth: 2, color: status.color),
        ),
      );
    }
    return Icon(status.icon, size: size, color: status.color);
  }
}

/// Seri hat cevabı, adres, ham değer gibi teknik metinler için tek mono stil.
TextStyle monoStyle({double fontSize = 12, Color? color}) =>
    TextStyle(fontFamily: MedFonts.mono, fontSize: fontSize, color: color ?? MedColors.text2);

/// Açıklama / ipucu metni.
TextStyle hintStyle({double? fontSize}) => TextStyle(color: MedColors.text3, fontSize: fontSize);
