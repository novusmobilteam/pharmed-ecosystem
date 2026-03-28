// lib/features/setup_wizard/presentation/screen/steps/step1_cabinet_type.dart
//
// [SWREQ-SETUP-UI-010]
// Adım 1 — Kabin tipi seçimi.
// Standart veya Mobil kabin seçim kartı.
// Sınıf: Class A

import 'package:flutter/material.dart';
import '../../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../../shared/widgets/atoms/med_button.dart';
import '../../../domain/model/cabin_setup_config.dart';

class Step1CabinetType extends StatelessWidget {
  const Step1CabinetType({super.key, required this.selectedType, required this.onTypeSelected, required this.onNext});

  final CabinetType? selectedType;
  final ValueChanged<CabinetType> onTypeSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Başlık ──
        _StepHeader(
          badge: 'Adım 1 / 5',
          title: 'Kabin Tipini Seçin',
          subtitle: 'Yönetmek istediğiniz kabin türünü belirleyin. Bu seçim sonraki adımları şekillendirecektir.',
        ),

        // ── İçerik ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Standart Kabin
                Expanded(
                  child: _CabinetTypeCard(
                    type: CabinetType.standard,
                    isSelected: selectedType == CabinetType.standard,
                    onTap: () => onTypeSelected(CabinetType.standard),
                    visual: const _StandardCabinVisual(),
                    specs: const ['5 Bölüm', 'Kübik / Birim Doz', 'Servis Bazlı'],
                    description:
                        'Sabit duvara monte veya bağımsız duran, kübik ve birim doz çekmece kombinasyonuna sahip kabin.',
                  ),
                ),
                const SizedBox(width: 20),
                // Mobil Kabin
                Expanded(
                  child: _CabinetTypeCard(
                    type: CabinetType.mobile,
                    isSelected: selectedType == CabinetType.mobile,
                    onTap: () => onTypeSelected(CabinetType.mobile),
                    visual: const _MobileCabinVisual(),
                    specs: const ['4 Sıra', 'Tekerlekli', 'Oda Bazlı'],
                    description: 'Tekerlekli, koğuş dolaşımı için tasarlanmış 4 sıralı taşınabilir ilaç ünitesi.',
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Alt buton ──
        _StepFooter(note: 'Kabin tipi sonradan değiştirilemez.', onNext: () => selectedType != null ? onNext : null),
      ],
    );
  }
}

// ── Kabin tipi seçim kartı ────────────────────────────────────────

class _CabinetTypeCard extends StatelessWidget {
  const _CabinetTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.visual,
    required this.specs,
    required this.description,
  });

  final CabinetType type;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget visual;
  final List<String> specs;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF4FF) : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x1F1A6FD8), blurRadius: 0, spreadRadius: 3),
                  BoxShadow(color: Color(0x171E3259), blurRadius: 12, offset: Offset(0, 4)),
                ]
              : MedShadows.sm,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                visual,
                const SizedBox(height: 16),
                Text(
                  type.label,
                  style: TextStyle(
                    fontFamily: MedFonts.title,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? MedColors.blue : MedColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: specs.map((s) => _SpecPill(label: s, highlighted: isSelected)).toList(),
                ),
              ],
            ),
            // Checkmark rozeti
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecPill extends StatelessWidget {
  const _SpecPill({required this.label, required this.highlighted});
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0x1A1A6FD8) : MedColors.surface3,
        border: Border.all(color: highlighted ? const Color(0x401A6FD8) : MedColors.border2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: highlighted ? MedColors.blue : MedColors.text2,
        ),
      ),
    );
  }
}

// ── Kabini SVG görselleri ─────────────────────────────────────────

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

class _MobileCabinVisual extends StatelessWidget {
  const _MobileCabinVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 60, height: 92, child: CustomPaint(painter: _MobileCabinetPainter()));
  }
}

class _MobileCabinetPainter extends CustomPainter {
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

// ── Ortak step bileşenleri ────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.badge, required this.title, required this.subtitle});

  final String badge;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(20)),
            child: Text(
              badge,
              style: const TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: MedColors.blue,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: MedFonts.title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: MedColors.text,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
          ),
        ],
      ),
    );
  }
}

class _StepFooter extends StatelessWidget {
  const _StepFooter({this.note, this.onBack, this.onNext, this.nextLabel = 'Devam Et', this.nextIcon});

  final String? note;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final Widget? nextIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            MedButton(
              label: 'Geri',
              variant: MedButtonVariant.ghost,
              prefixIcon: const Icon(Icons.arrow_back_rounded, size: 16),
              onPressed: onBack,
            ),
          if (note != null) ...[
            const SizedBox(width: 12),
            Text(
              note!,
              style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
            ),
          ],
          const Spacer(),
          if (onNext != null)
            MedButton(label: nextLabel, size: MedButtonSize.lg, onPressed: onNext, prefixIcon: nextIcon),
        ],
      ),
    );
  }
}
