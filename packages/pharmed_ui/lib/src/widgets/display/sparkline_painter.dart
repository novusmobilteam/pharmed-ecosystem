import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Tek renkli, eksensiz mini trend çizgisi.
/// Nokta sayısı 2'nin altındaysa hiçbir şey çizmez.
class SparklinePainter extends CustomPainter {
  const SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    var min = points.first;
    var max = points.first;
    for (final p in points) {
      if (p < min) min = p;
      if (p > max) max = p;
    }

    // Sabit değerde bölme sıfıra düşer → çizgi kaybolur
    final span = (max - min) < 0.01 ? 1.0 : max - min;

    // Üst/alt 2px pay — çizgi kenara yapışmasın
    const pad = 2.0;
    final h = size.height - pad * 2;
    final dx = size.width / (points.length - 1);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final y = pad + h - ((points[i] - min) / span) * h;
      if (i == 0) {
        path.moveTo(0, y);
      } else {
        path.lineTo(i * dx, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(SparklinePainter old) => !listEquals(old.points, points) || old.color != color;
}
