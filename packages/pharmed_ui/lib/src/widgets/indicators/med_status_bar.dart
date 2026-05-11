import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedStatusBar
// [SWREQ-UI-ATOM-003]
// Kullanım: SKT listesi ve TreatmentRow soldaki dikey renkli çubuk.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Dikey renkli durum çubuğu — liste öğelerinin sol kenarında kullanılır.
///
/// ```dart
/// MedStatusBar(color: MedColors.red, height: 44)
/// ```
/// Backward compat alias.
typedef StatusBar = MedStatusBar;

class MedStatusBar extends StatelessWidget {
  const MedStatusBar({
    super.key,
    required this.color,
    this.height = 38,
    this.width = 4,
  });

  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: MedRadius.smAll),
    );
  }
}
