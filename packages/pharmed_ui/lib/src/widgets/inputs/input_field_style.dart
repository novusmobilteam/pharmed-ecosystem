import 'package:flutter/material.dart';

import '../../theme/med_density.dart';

// ─────────────────────────────────────────────────────────────────
// InputFieldStyle — Input görsel değerleri (MedDensity'den türer)
//
// ÖNEMLİ DEĞİŞİKLİK: Bu sınıf artık kendi manager/client sabitlerini
// TANIMLAMAZ. Değerler tek gerçek kaynak olan MedDensity'den gelir.
// Böylece client/manager farkı yalnızca bir yerde (MedDensity) yaşar.
//
// InputFieldTheme (InheritedWidget) artık gerekmiyor: InputFieldTheme.of
// geriye uyumluluk için korundu ama içten MedDensity.of(context)'e delege
// ediyor. Input widget'larının çağrıları (InputFieldTheme.of(context))
// değişmeden çalışır.
// ─────────────────────────────────────────────────────────────────

/// Input alanlarının görsel özelliklerini tutan immutable değer sınıfı.
/// MedDensity'den türetilir; elle sabit tanımlanmaz.
@immutable
class InputFieldStyle {
  const InputFieldStyle({
    required this.labelFontSize,
    required this.labelLetterSpacing,
    required this.labelUpperCase,
    required this.borderRadius,
    required this.contentPadding,
    required this.minHeight,
    required this.borderWidth,
    required this.inputFontSize,
    this.inputFontWeight = FontWeight.w500,
    this.inputTextAlign = TextAlign.center,
  });

  final double labelFontSize;
  final double labelLetterSpacing;
  final bool labelUpperCase;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final double minHeight;
  final double borderWidth;
  final double inputFontSize;
  final FontWeight inputFontWeight;
  final TextAlign inputTextAlign;

  /// MedDensity'den input görünümü türetir. TEK dönüşüm noktası.
  factory InputFieldStyle.fromDensity(MedDensity d) {
    return InputFieldStyle(
      labelFontSize: d.labelFontSize,
      labelLetterSpacing: d.labelLetterSpacing,
      labelUpperCase: d.labelUpperCase,
      borderRadius: d.inputBorderRadius,
      contentPadding: EdgeInsets.symmetric(horizontal: d.inputPaddingX),
      minHeight: d.inputMinHeight,
      borderWidth: d.inputBorderWidth,
      inputFontSize: d.inputFontSize,
    );
  }

  /// Context'ten okur — MedDensity üzerinden.
  factory InputFieldStyle.of(BuildContext context) => InputFieldStyle.fromDensity(MedDensity.of(context));

  /// Manager varsayılanı (geriye uyumluluk; MedDensity.compact'tan türer).
  static InputFieldStyle get manager => InputFieldStyle.fromDensity(MedDensity.compact);

  /// Client varsayılanı (geriye uyumluluk; MedDensity.touch'tan türer).
  static InputFieldStyle get client => InputFieldStyle.fromDensity(MedDensity.touch);

  InputFieldStyle copyWith({
    double? labelFontSize,
    double? labelLetterSpacing,
    bool? labelUpperCase,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    double? minHeight,
    double? borderWidth,
    double? inputFontSize,
    FontWeight? inputFontWeight,
    TextAlign? inputTextAlign,
  }) {
    return InputFieldStyle(
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelLetterSpacing: labelLetterSpacing ?? this.labelLetterSpacing,
      labelUpperCase: labelUpperCase ?? this.labelUpperCase,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      minHeight: minHeight ?? this.minHeight,
      borderWidth: borderWidth ?? this.borderWidth,
      inputFontSize: inputFontSize ?? this.inputFontSize,
      inputFontWeight: inputFontWeight ?? this.inputFontWeight,
      inputTextAlign: inputTextAlign ?? this.inputTextAlign,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputFieldStyle &&
          runtimeType == other.runtimeType &&
          labelFontSize == other.labelFontSize &&
          labelLetterSpacing == other.labelLetterSpacing &&
          labelUpperCase == other.labelUpperCase &&
          borderRadius == other.borderRadius &&
          contentPadding == other.contentPadding &&
          minHeight == other.minHeight &&
          borderWidth == other.borderWidth &&
          inputFontSize == other.inputFontSize &&
          inputFontWeight == other.inputFontWeight &&
          inputTextAlign == other.inputTextAlign;

  @override
  int get hashCode => Object.hash(
    labelFontSize,
    labelLetterSpacing,
    labelUpperCase,
    borderRadius,
    contentPadding,
    minHeight,
    borderWidth,
    inputFontSize,
    inputFontWeight,
    inputTextAlign,
  );
}

// ─────────────────────────────────────────────────────────────────
// InputFieldTheme — geriye uyumluluk kabuğu
//
// ARTIK GEREKMİYOR ama input widget'ları InputFieldTheme.of(context)
// çağırdığı için korundu. İçten MedDensity.of(context)'e delege eder.
//
// Eskiden pharmed-client kökünde InputFieldTheme(style: client) ile
// sarılıyordu. ARTIK GEREKMEZ — MedDensity zaten MedTheme.client()
// içinde extension olarak var. Sarmalayıcıyı main.dart'tan
// KALDIRABİLİRSİN (kalması da zararsız; manuel override görevi görür).
// ─────────────────────────────────────────────────────────────────
class InputFieldTheme extends InheritedWidget {
  const InputFieldTheme({super.key, required this.style, required super.child});

  /// Manuel override stili. Verilirse MedDensity yerine bu kullanılır.
  final InputFieldStyle style;

  /// Stili okur. Öncelik: ağaçta manuel InputFieldTheme override varsa onu,
  /// yoksa MedDensity'den türetilmiş stili döner.
  static InputFieldStyle of(BuildContext context) {
    final override = context.dependOnInheritedWidgetOfExactType<InputFieldTheme>();
    if (override != null) return override.style;
    return InputFieldStyle.fromDensity(MedDensity.of(context));
  }

  @override
  bool updateShouldNotify(InputFieldTheme old) => style != old.style;
}
