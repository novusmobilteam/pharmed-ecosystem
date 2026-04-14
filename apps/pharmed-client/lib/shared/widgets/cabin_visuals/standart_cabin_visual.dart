part of 'cabin_visuals.dart';

class _StandardCabinVisual extends StatelessWidget {
  const _StandardCabinVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 72, height: 86, child: CustomPaint(painter: _StandardCabinetPainter()));
  }
}

class _StandardCabinetPainter extends CustomPainter {
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
      ..color = const Color(0xFFF59E0B).withOpacity(0.7);

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
