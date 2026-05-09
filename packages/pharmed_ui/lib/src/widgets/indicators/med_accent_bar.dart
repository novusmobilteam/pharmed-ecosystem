import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedAccentBar
// [SWREQ-UI-ATOM-004]
// Kullanım: KPI kartı ve benzeri kartların üst kenar vurgu şeridi.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Kartların üst kenarına konan yatay renk vurgu şeridi.
///
/// ```dart
/// MedAccentBar(color: MedColors.blue, height: 5)
/// ```
/// Backward compat alias.
typedef AccentBar = MedAccentBar;

class MedAccentBar extends StatelessWidget {
  const MedAccentBar({super.key, required this.color, this.height = 5});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: MedRadius.lg,
          topRight: MedRadius.lg,
        ),
      ),
    );
  }
}
