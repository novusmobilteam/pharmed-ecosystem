import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// MedLabel
// [SWREQ-UI-ATOM-005]
// Kullanım: Tekrarlayan küçük metin varyasyonları
//   - cardLabel   → "Aktif Hasta", "Kritik Stok" (11px, text3)
//   - cardSub     → "12 dolu · 3 boş" (9px, mono, text4)
//   - sectionTitle→ "KABİN DURUMU" (12px, Sora, bold, uppercase)
//   - monoValue   → teknik değer, lot no, ID
// Sınıf: Class A

enum MedLabelVariant { cardLabel, cardSub, sectionTitle, monoValue, monoDetail }

class MedLabel extends StatelessWidget {
  const MedLabel({super.key, required this.text, required this.variant, this.color, this.overflow});

  final String text;
  final MedLabelVariant variant;
  final Color? color;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: resolveStyle(variant, color: color),
      overflow: overflow,
    );
  }

  static TextStyle resolveStyle(MedLabelVariant variant, {Color? color}) {
    return switch (variant) {
      MedLabelVariant.cardLabel => TextStyle(
        fontFamily: MedFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color ?? MedColors.text3,
      ),
      MedLabelVariant.cardSub => TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 9,
        fontWeight: FontWeight.w400,
        color: color ?? MedColors.text4,
      ),
      MedLabelVariant.sectionTitle => TextStyle(
        fontFamily: MedFonts.title,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: color ?? MedColors.text2,
      ),
      MedLabelVariant.monoValue => TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color ?? MedColors.text2,
      ),
      MedLabelVariant.monoDetail => TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 9,
        fontWeight: FontWeight.w400,
        color: color ?? MedColors.text3,
      ),
    };
  }
}
