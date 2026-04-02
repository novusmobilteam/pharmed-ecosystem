import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// AccentBar
// [SWREQ-UI-ATOM-004]
// Kullanım: KPI kartı üst kenar vurgu çizgisi (3px yatay)
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

class AccentBar extends StatelessWidget {
  const AccentBar({super.key, required this.color, this.height = 5});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
      ),
    );
  }
}
