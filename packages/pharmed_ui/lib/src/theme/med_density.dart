import 'package:flutter/material.dart';

import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedDensity — client (dokunmatik) ↔ manager (masaüstü) yoğunluk farkı
//
// TEK GERÇEK KAYNAK. Client/manager arasındaki tüm yoğunluk kararları
// burada. Widget'lar Theme.of(context).extension<MedDensity>() ile okur.
//
// İki katman:
//   • Kontrol yoğunluğu (buton/chip/selectable): controlMinHeight, controlPaddingX
//   • Input yoğunluğu (text field/dropdown/date...): input* + label* alanları
//
// InputFieldStyle artık kendi manager/client sabitlerini TANIMLAMAZ;
// bu extension'dan türer (InputFieldStyle.fromDensity). Böylece
// "input InputFieldTheme'e, buton MedDensity'ye bakıyor" tutarsızlığı
// kökten biter — iki sistem tek kaynağa indi.
// ─────────────────────────────────────────────────────────────────
@immutable
class MedDensity extends ThemeExtension<MedDensity> {
  const MedDensity({
    required this.isCompact,
    required this.controlMinHeight,
    required this.controlPaddingX,
    required this.inputPaddingX,
    required this.inputMinHeight,
    required this.inputBorderRadius,
    required this.inputBorderWidth,
    required this.inputFontSize,
    required this.labelFontSize,
    required this.labelLetterSpacing,
    required this.labelUpperCase,
  });

  /// Manager (masaüstü) mı? false ise client (dokunmatik).
  final bool isCompact;

  // ── Kontrol yoğunluğu (buton/chip/selectable) ──────────────────
  /// Buton / toggle / chip gibi kontrollerin varsayılan minimum yüksekliği.
  final double controlMinHeight;

  /// Kontrollerin yatay iç boşluğu.
  final double controlPaddingX;

  // ── Input yoğunluğu (text field/dropdown/date/time...) ─────────
  /// Input alanı yatay iç boşluğu.
  final double inputPaddingX;

  /// Input alanı minimum yüksekliği.
  final double inputMinHeight;

  /// Input kutusu köşe yarıçapı.
  final BorderRadius inputBorderRadius;

  /// Input kenarlık kalınlığı.
  final double inputBorderWidth;

  /// Input metni font boyutu.
  final double inputFontSize;

  /// Label font boyutu.
  final double labelFontSize;

  /// Label harf aralığı.
  final double labelLetterSpacing;

  /// Label büyük harfe çevrilsin mi (manager: true, client: false).
  final bool labelUpperCase;

  /// Dokunmatik kiosk (pharmed-client) — geniş hedefler (WCAG 2.5.5).
  static const MedDensity touch = MedDensity(
    isCompact: false,
    controlMinHeight: 48,
    controlPaddingX: 16,
    inputPaddingX: 14,
    inputMinHeight: 48,
    inputBorderRadius: MedRadius.mdAll,
    inputBorderWidth: 1,
    inputFontSize: 12,
    labelFontSize: 11,
    labelLetterSpacing: 0.5,
    labelUpperCase: false,
  );

  /// Masaüstü yönetim (pharmed-manager) — sıkı, fare dostu.
  static const MedDensity compact = MedDensity(
    isCompact: true,
    controlMinHeight: 40,
    controlPaddingX: 12,
    inputPaddingX: 9,
    inputMinHeight: 35,
    inputBorderRadius: MedRadius.smAll,
    inputBorderWidth: 1.5,
    inputFontSize: 13,
    labelFontSize: 9,
    labelLetterSpacing: 0.8,
    labelUpperCase: true,
  );

  /// Context'ten güvenli okuma. Extension kayıtlı değilse touch varsayar
  /// (client, en geniş hedef — güvenli varsayılan).
  static MedDensity of(BuildContext context) {
    return Theme.of(context).extension<MedDensity>() ?? touch;
  }

  @override
  MedDensity copyWith({
    bool? isCompact,
    double? controlMinHeight,
    double? controlPaddingX,
    double? inputPaddingX,
    double? inputMinHeight,
    BorderRadius? inputBorderRadius,
    double? inputBorderWidth,
    double? inputFontSize,
    double? labelFontSize,
    double? labelLetterSpacing,
    bool? labelUpperCase,
  }) {
    return MedDensity(
      isCompact: isCompact ?? this.isCompact,
      controlMinHeight: controlMinHeight ?? this.controlMinHeight,
      controlPaddingX: controlPaddingX ?? this.controlPaddingX,
      inputPaddingX: inputPaddingX ?? this.inputPaddingX,
      inputMinHeight: inputMinHeight ?? this.inputMinHeight,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      inputBorderWidth: inputBorderWidth ?? this.inputBorderWidth,
      inputFontSize: inputFontSize ?? this.inputFontSize,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelLetterSpacing: labelLetterSpacing ?? this.labelLetterSpacing,
      labelUpperCase: labelUpperCase ?? this.labelUpperCase,
    );
  }

  @override
  MedDensity lerp(covariant MedDensity? other, double t) {
    if (other == null) return this;
    return MedDensity(
      isCompact: t < 0.5 ? isCompact : other.isCompact,
      controlMinHeight: _lerp(controlMinHeight, other.controlMinHeight, t),
      controlPaddingX: _lerp(controlPaddingX, other.controlPaddingX, t),
      inputPaddingX: _lerp(inputPaddingX, other.inputPaddingX, t),
      inputMinHeight: _lerp(inputMinHeight, other.inputMinHeight, t),
      inputBorderRadius: BorderRadius.lerp(inputBorderRadius, other.inputBorderRadius, t)!,
      inputBorderWidth: _lerp(inputBorderWidth, other.inputBorderWidth, t),
      inputFontSize: _lerp(inputFontSize, other.inputFontSize, t),
      labelFontSize: _lerp(labelFontSize, other.labelFontSize, t),
      labelLetterSpacing: _lerp(labelLetterSpacing, other.labelLetterSpacing, t),
      labelUpperCase: t < 0.5 ? labelUpperCase : other.labelUpperCase,
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
