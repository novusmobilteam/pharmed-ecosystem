import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// RingChart
// [SWREQ-UI-ATOM-010] [HAZ-008]
// Kullanım: SKT widget altındaki halka grafik
//   count  → dolgu değeri (örn: 2 kritik ilaç)
//   total  → maksimum (örn: toplam ilaç sayısı)
//   label  → alt açıklama (örn: "Kritik\n(<7 gün)")
// Sınıf: Class B — SKT sayısını görsel olarak temsil eder.
//         Yanlış değer yanlış karar tetikleyebilir.
// ─────────────────────────────────────────────────────────────────

class RingChart extends StatelessWidget {
  const RingChart({
    super.key,
    required this.count,
    required this.total,
    required this.color,
    required this.label,
    this.size = 48,
    this.strokeWidth = 4,
  });

  final int count;
  final int total;
  final Color color;
  final String label;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    // [HAZ-008] total sıfırsa ring boş gösterilir, crash olmaz
    final ratio = (total > 0) ? (count / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(ratio: ratio, color: color, strokeWidth: strokeWidth),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: MedFonts.title,
                  fontSize: size * 0.23,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: MedTextStyles.monoXs()),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.ratio, required this.color, required this.strokeWidth});

  final double ratio;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arka plan halkası
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Dolgu halkası — saat 12'den başlar, clockwise
    if (ratio > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // saat 12'den başla
        2 * math.pi * ratio, // ratio kadar dön
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio || old.color != color;
}
