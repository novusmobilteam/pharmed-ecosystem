import 'package:flutter/material.dart';

import 'med_tokens.dart'; // MedColors, MedFonts, MedRadius, MedTextStyles, MedSpacing

// ─────────────────────────────────────────────────────────────────
// MedTheme — Token'lardan türeyen ortak tema fabrikası
//
// Tek gerçek kaynak: MedColors / MedTextStyles / MedRadius / MedSpacing.
// ThemeData bu token'ların Material dünyasına yansımasıdır; bağımsız
// bir ikinci renk/ölçü seti TANIMLAMAZ.
//
// İki flavor:
//   • MedTheme.client()  → dokunmatik kiosk (geniş padding, büyük hedef)
//   • MedTheme.manager() → Windows masaüstü (sıkı, fare dostu yerleşim)
//
// Aradaki TEK fark yoğunluktur (_Density). Renk, tipografi ve radius
// her ikisinde de birebir aynı token'dan gelir.
// ─────────────────────────────────────────────────────────────────
abstract final class MedTheme {
  /// Dokunmatik HMI (pharmed-client) teması.
  static ThemeData client() => _base(const _Density.touch());

  /// Masaüstü yönetim (pharmed-manager) teması.
  static ThemeData manager() => _base(const _Density.compact());

  // ── Ortak ColorScheme (token'lardan türetildi) ─────────────────
  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,

    // Birincil
    primary: MedColors.blue,
    onPrimary: MedColors.surface,
    primaryContainer: MedColors.blueLight,
    onPrimaryContainer: MedColors.blueDark,

    // İkincil
    secondary: MedColors.text2,
    onSecondary: MedColors.surface,
    secondaryContainer: MedColors.surface3,
    onSecondaryContainer: MedColors.text,

    // Yüzeyler
    surface: MedColors.surface,
    onSurface: MedColors.text,
    onSurfaceVariant: MedColors.text2,
    surfaceContainerLowest: MedColors.surface,
    surfaceContainerLow: MedColors.surface2,
    surfaceContainer: MedColors.surface3,
    surfaceContainerHigh: MedColors.bg,

    // Hata
    error: MedColors.red,
    onError: MedColors.surface,
    errorContainer: MedColors.redLight,
    onErrorContainer: MedColors.redDark,

    // Kenarlıklar
    outline: MedColors.border,
    outlineVariant: MedColors.border2,

    // Diğer
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: MedColors.text,
    onInverseSurface: MedColors.surface,
    inversePrimary: MedColors.blueLight2,
  );

  // ── Ortak metin teması (MedTextStyles'tan) ─────────────────────
  static const TextTheme _textTheme = TextTheme(
    // Başlıklar — Sora
    displayLarge: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w800),
    displayMedium: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w800),
    displaySmall: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontFamily: MedFonts.title, fontWeight: FontWeight.w600),

    // Gövde — DM Sans
    bodyLarge: TextStyle(fontFamily: MedFonts.sans, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: MedFonts.sans, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: MedFonts.sans, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: MedFonts.sans, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: MedFonts.sans, fontWeight: FontWeight.w500),

    // Mono etiket — JetBrains Mono
    labelSmall: TextStyle(fontFamily: MedFonts.mono, fontWeight: FontWeight.w500),
  );

  // ── Ana fabrika ────────────────────────────────────────────────
  static ThemeData _base(_Density d) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _scheme,
      scaffoldBackgroundColor: MedColors.bg,
      dividerColor: MedColors.border,
      fontFamily: MedFonts.sans,
      textTheme: _textTheme,

      // AppBar — beyaz, ince alt çizgi
      appBarTheme: const AppBarTheme(
        backgroundColor: MedColors.surface,
        foregroundColor: MedColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: MedColors.border)),
        iconTheme: IconThemeData(size: 24, color: MedColors.text2),
      ),

      // Kart — beyaz, ince kenar, flat
      cardTheme: CardThemeData(
        color: MedColors.surface,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: MedSpacing.md),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: MedColors.border),
          borderRadius: MedRadius.lgAll,
        ),
      ),

      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: MedColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: MedRadius.xl2All),
      ),

      // Input — yoğunluğa göre padding & yükseklik
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MedColors.surface,
        //contentPadding: d.inputPadding,
        //constraints: BoxConstraints(minHeight: d.inputMinHeight),
        labelStyle: MedTextStyles.bodyMd(color: MedColors.text2),
        hintStyle: MedTextStyles.bodyMd(color: MedColors.text3),
        border: _inputBorder(MedColors.border),
        enabledBorder: _inputBorder(MedColors.border),
        focusedBorder: _inputBorder(MedColors.blue, width: 2),
        errorBorder: _inputBorder(MedColors.red),
        focusedErrorBorder: _inputBorder(MedColors.red, width: 2),
      ),

      // Elevated (primary) buton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MedColors.blue,
          foregroundColor: MedColors.surface,
          elevation: 0,
          minimumSize: Size(0, d.buttonMinHeight),
          padding: d.buttonPadding,
          shape: const RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
          textStyle: MedTextStyles.bodyLg(weight: FontWeight.w600),
        ),
      ),

      // Outlined (secondary) buton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MedColors.blue,
          side: const BorderSide(color: MedColors.blue, width: 1.5),
          minimumSize: Size(0, d.buttonMinHeight),
          padding: d.buttonPadding,
          shape: const RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
          textStyle: MedTextStyles.bodyLg(weight: FontWeight.w600),
        ),
      ),

      // Text buton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MedColors.blue,
          minimumSize: Size(0, d.buttonMinHeight),
          padding: d.buttonPadding,
          shape: const RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
          textStyle: MedTextStyles.bodyLg(weight: FontWeight.w600),
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: MedRadius.smAll),
        side: const BorderSide(color: MedColors.text4, width: 2),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return MedColors.blue;
          return null;
        }),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return MedColors.surface;
          return MedColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return MedColors.blue;
          return MedColors.text4;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: MedRadius.mdAll,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _Density — client (dokunmatik) ile manager (masaüstü) arasındaki
// TEK fark. Renk/tipografi/radius bu sınıfa girmez.
// ─────────────────────────────────────────────────────────────────
class _Density {
  final EdgeInsets inputPadding;
  final double inputMinHeight;
  final EdgeInsets buttonPadding;
  final double buttonMinHeight;

  const _Density({
    required this.inputPadding,
    required this.inputMinHeight,
    required this.buttonPadding,
    required this.buttonMinHeight,
  });

  /// Dokunmatik kiosk — geniş hedefler (WCAG 2.5.5 / 44-48px).
  const _Density.touch()
    : inputPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      inputMinHeight = 48,
      buttonPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      buttonMinHeight = 48;

  /// Masaüstü — sıkı, fare dostu yerleşim.
  const _Density.compact()
    : inputPadding = const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      inputMinHeight = 44,
      buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      buttonMinHeight = 40;
}
