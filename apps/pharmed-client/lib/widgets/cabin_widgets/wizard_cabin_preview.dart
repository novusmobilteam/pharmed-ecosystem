import 'package:flutter/material.dart';

enum WizardCabinPreviewType { standard, mobile }

// Factory widget — tip'e göre doğru visual döndür
class WizardCabinPreview extends StatelessWidget {
  final WizardCabinPreviewType type;

  const WizardCabinPreview({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      WizardCabinPreviewType.standard => const _MasterCabinPreview(),
      WizardCabinPreviewType.mobile => const _MobileCabinPreview(),
    };
  }
}

class _MasterCabinPreview extends StatelessWidget {
  const _MasterCabinPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 72, height: 86, child: CustomPaint(painter: _MasterCabinPainter()));
  }
}

class _MasterCabinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()
      ..color = const Color(0xFFDCE2ED)
      ..style = PaintingStyle.fill;
    final bodyBorder = Paint()
      ..color = const Color(0xFFB8C6D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final topPanel = Paint()..color = const Color(0xFFC8D4E4);
    final drawer = Paint()..color = const Color(0xFFEDF1F8);
    final drawerBorder = Paint()
      ..color = const Color(0xFFC8D2E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final handle = Paint()..color = const Color(0xFF9AADC0);
    final ledGreen = Paint()..color = const Color(0xFF22C55E);
    final ledAmber = Paint()
      ..color = const Color(0xFFF59E0B)
      ..color = const Color(0xFFF59E0B).withAlpha(120);

    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(6, 4, 60, 72), const Radius.circular(9));
    canvas.drawRRect(rr, body);
    canvas.drawRRect(rr, bodyBorder);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, 8, 52, 10), const Radius.circular(4)), topPanel);

    canvas.drawCircle(const Offset(14, 13), 3, ledGreen);
    canvas.drawCircle(const Offset(22, 13), 3, ledAmber);

    for (final y in [22.0, 34.0, 46.0]) {
      final dr = RRect.fromRectAndRadius(Rect.fromLTWH(13, y, 46, 9), const Radius.circular(4));
      canvas.drawRRect(dr, drawer);
      canvas.drawRRect(dr, drawerBorder);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(28, y + 3, 16, 3), const Radius.circular(1.5)), handle);
    }
    for (final x in [13.0, 39.0]) {
      final dr = RRect.fromRectAndRadius(Rect.fromLTWH(x, 58, 20, 9), const Radius.circular(4));
      canvas.drawRRect(dr, drawer);
      canvas.drawRRect(dr, drawerBorder);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 9, 61, 8, 3), const Radius.circular(1.5)), handle);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MobileCabinPreview extends StatelessWidget {
  const _MobileCabinPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 60, height: 92, child: CustomPaint(painter: _MobileCabinPainter()));
  }
}

class _MobileCabinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFFD4DCEA);
    final bodyBorder = Paint()
      ..color = const Color(0xFFB8C6D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final topPanel = Paint()..color = const Color(0xFFBCCAD8);
    final drawer = Paint()..color = const Color(0xFFEDF1F8);
    final drawerBorder = Paint()
      ..color = const Color(0xFFC8D2E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final handle = Paint()..color = const Color(0xFF9AADC0);
    final wheel = Paint()..color = const Color(0xFF8090A8);
    final wheelInner = Paint()..color = const Color(0xFF6A7A90);
    final ledGreen = Paint()..color = const Color(0xFF22C55E);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5, 4, 50, 70), const Radius.circular(9)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5, 4, 50, 70), const Radius.circular(9)), bodyBorder);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(9, 8, 42, 9), const Radius.circular(4)), topPanel);
    canvas.drawCircle(const Offset(13, 12.5), 2.5, ledGreen);

    for (var row = 0; row < 4; row++) {
      final y = 21.0 + row * 13;
      for (var col = 0; col < 2; col++) {
        final x = col == 0 ? 11.0 : 32.0;
        final dr = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 17, 10), const Radius.circular(4));
        canvas.drawRRect(dr, drawer);
        canvas.drawRRect(dr, drawerBorder);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x + 6, y + 7.5, 5, 1.5), const Radius.circular(1)),
          handle,
        );
      }
    }

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5, 74, 50, 6), const Radius.circular(2)), wheel);

    for (final cx in [17.0, 43.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 86), width: 16, height: 10), wheel);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 86), width: 8, height: 5), wheelInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
