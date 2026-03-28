import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// StatusDot
// [SWREQ-UI-ATOM-002]
// Kullanım: Widget header solundaki 8px renkli durum noktası
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
