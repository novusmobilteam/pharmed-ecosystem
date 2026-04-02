import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// MedColors — Tüm renk sabitleri
// Hiçbir widget bu dosya dışında renk tanımlamaz.
// ─────────────────────────────────────────────────────────────────
abstract final class MedColors {
  // Surface
  static const Color bg = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF7F9FC);
  static const Color surface3 = Color(0xFFF0F3F8);

  // Border
  static const Color border = Color(0xFFDDE3EC);
  static const Color border2 = Color(0xFFE8ECF3);

  // Semantic — ana tон
  static const Color blue = Color(0xFF1A6FD8);
  static const Color blueLight = Color(0xFFE8F1FC);
  static const Color green = Color(0xFF0D9E6C);
  static const Color greenLight = Color(0xFFE6F7F2);
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFEF3E2);
  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color redDark = Color(0xFF991B1B);

  // Text
  static const Color text = Color(0xFF1A2332);
  static const Color text2 = Color(0xFF3D4F66);
  static const Color text3 = Color(0xFF7A8FA8);
  static const Color text4 = Color(0xFFB0BFCC);

  // LED renkleri (native CSS'ten türetildi)
  static const Color ledGreen = Color(0xFF22C55E);
  static const Color ledAmber = Color(0xFFF59E0B);
  static const Color ledRed = Color(0xFFEF4444);
}

// ─────────────────────────────────────────────────────────────────
// MedFonts — Tipografi sabitleri
// ─────────────────────────────────────────────────────────────────
abstract final class MedFonts {
  /// Başlık, büyük sayısal değer (KPI, istatistik)
  static const String title = 'Sora';

  /// Genel UI metni
  static const String sans = 'DM Sans';

  /// Teknik değer: ID, tarih, lot no, badge içi
  static const String mono = 'JetBrains Mono';
}

// ─────────────────────────────────────────────────────────────────
// MedRadius — Border radius sabitleri
// ─────────────────────────────────────────────────────────────────
abstract final class MedRadius {
  static const Radius sm = Radius.circular(4);
  static const Radius md = Radius.circular(8);
  static const Radius lg = Radius.circular(12);
  static const Radius xl = Radius.circular(20); // badge, chip

  static const BorderRadius smAll = BorderRadius.all(sm);
  static const BorderRadius mdAll = BorderRadius.all(md);
  static const BorderRadius lgAll = BorderRadius.all(lg);
  static const BorderRadius xlAll = BorderRadius.all(xl);
}

// ─────────────────────────────────────────────────────────────────
// MedShadows — Gölge sabitleri
// ─────────────────────────────────────────────────────────────────
abstract final class MedShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x121E3259), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A1E3259), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x171E3259), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A1E3259), blurRadius: 4, offset: Offset(0, 2)),
  ];
}

// ─────────────────────────────────────────────────────────────────
// MedTextStyles — TextStyle fabrikası
// ─────────────────────────────────────────────────────────────────
abstract final class MedTextStyles {
  // Title ailesi
  static TextStyle titleXl({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? MedColors.text,
  );

  static TextStyle titleLg({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? MedColors.text,
  );

  static TextStyle titleMd({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? MedColors.text,
  );

  static TextStyle titleSm({Color? color}) => TextStyle(
    fontFamily: MedFonts.title,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    color: color ?? MedColors.text2,
  );

  // Sans ailesi
  static TextStyle bodyMd({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.sans,
    fontSize: 12,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? MedColors.text,
  );

  static TextStyle bodySm({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.sans,
    fontSize: 11,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? MedColors.text2,
  );

  // Mono ailesi
  static TextStyle monoMd({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.mono,
    fontSize: 11,
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? MedColors.text2,
  );

  static TextStyle monoSm({Color? color, FontWeight? weight}) => TextStyle(
    fontFamily: MedFonts.mono,
    fontSize: 10,
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? MedColors.text3,
  );

  static TextStyle monoXs({Color? color}) =>
      TextStyle(fontFamily: MedFonts.mono, fontSize: 9, fontWeight: FontWeight.w400, color: color ?? MedColors.text3);
}
