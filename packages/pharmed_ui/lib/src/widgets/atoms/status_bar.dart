import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// StatusBar
// [SWREQ-UI-ATOM-003]
// Kullanım: SKT listesi ve TreatmentRow soldaki dikey renkli çubuk
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.color, this.height = 38, this.width = 4});

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
