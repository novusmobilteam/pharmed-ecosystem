import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Yatay noktalı ayraç çizgisi.
///
/// Yerleştirildiği satırın tüm genişliğini kaplar.
/// [CustomPainter] tabanlıdır; paket bağımlılığı yoktur.
///
/// ```dart
/// // Varsayılan kullanım
/// const DottedDivider()
///
/// // Özelleştirilmiş kullanım
/// DottedDivider(
///   color: MedColors.blue,
///   thickness: 2,
///   dashWidth: 8,
///   dashSpace: 5,
/// )
/// ```
class MedDottedDivider extends StatelessWidget {
  const MedDottedDivider({
    super.key,
    this.color,
    this.thickness = 1.5,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.height,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  /// Çizgi rengi. Verilmezse [MedColors.border] kullanılır.
  final Color? color;

  /// Çizgi kalınlığı (px). Varsayılan: `1.5`
  final double thickness;

  /// Tek bir tire uzunluğu (px). Varsayılan: `6`
  final double dashWidth;

  /// Tireler arası boşluk (px). Varsayılan: `4`
  final double dashSpace;

  /// Widget yüksekliği. Verilmezse `thickness` ile otomatik hesaplanır.
  final double? height;

  /// Sol kenar boşluğu (px).
  final double indent;

  /// Sağ kenar boşluğu (px).
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? MedColors.border;
    final effectiveHeight = height ?? (thickness + 8);

    return SizedBox(
      height: effectiveHeight,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: CustomPaint(
          size: Size(double.infinity, effectiveHeight),
          painter: _DottedLinePainter(
            color: effectiveColor,
            thickness: thickness,
            dashWidth: dashWidth,
            dashSpace: dashSpace,
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    double startX = 0;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
