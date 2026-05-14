import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// InputFieldStyle — Input görsel tokenları için değer sınıfı
//
// Tüm input widget'ları görsel değerlerini doğrudan sabitlemez;
// bu sınıftan okur. InputFieldTheme aracılığıyla widget ağacından
// alınır. Bulunamazsa InputFieldStyle.manager varsayılanı döner.
//
// Kullanım:
//   final style = InputFieldTheme.of(context);
//   BorderRadius r = style.borderRadius;
// ─────────────────────────────────────────────────────────────────

/// Input alanlarının görsel özelliklerini tutan immutable değer sınıfı.
///
/// İki hazır sabit sunar:
/// - [InputFieldStyle.manager]: Sıkı, fare dostu, uppercase mono etiket.
/// - [InputFieldStyle.client]: Geniş, dokunmatik dostu, normal Sora etiket.
///
/// Farklı bir görünüm için [copyWith] kullanarak türetme yapılabilir.
@immutable
class InputFieldStyle {
  const InputFieldStyle({
    this.labelFontSize = MedSpacing.labelFontSizeManager,
    this.labelLetterSpacing = MedSpacing.labelLetterSpacingManager,
    this.labelUpperCase = true,
    this.borderRadius = MedRadius.smAll,
    this.contentPadding = MedSpacing.inputPaddingManager,
    this.minHeight = MedSpacing.inputMinHeightManager,
    this.borderWidth = 1.5,
    this.inputFontSize = 13,
    this.inputFontWeight = FontWeight.w500,
    this.inputTextAlign = TextAlign.start,
  });

  /// Label metninin font boyutu (pt).
  final double labelFontSize;

  /// Label metninin harf aralığı.
  final double labelLetterSpacing;

  /// Label metninin büyük harfe dönüştürülüp dönüştürülmeyeceği.
  final bool labelUpperCase;

  /// Input kutusunun köşe yarıçapı.
  final BorderRadius borderRadius;

  /// Input kutusunun iç boşluğu.
  final EdgeInsetsGeometry contentPadding;

  /// Input kutusunun minimum yüksekliği.
  final double minHeight;

  /// Kenarlık kalınlığı (px).
  final double borderWidth;

  /// Input metninin font boyutu (pt).
  final double inputFontSize;

  /// Input metninin font ağırlığı.
  final FontWeight inputFontWeight;

  /// Input metninin hizalaması.
  final TextAlign inputTextAlign;

  /// Manager varsayılanı — sıkı yerleşim, fare dostu, uppercase mono etiket.
  ///
  /// pharmed-manager bu presetı otomatik alır; [InputFieldTheme] enjeksiyonu
  /// gerekmez çünkü [InputFieldTheme.of] bu preseti fallback olarak döner.
  static const InputFieldStyle manager = InputFieldStyle();

  /// Client varsayılanı — geniş dokunmatik alan, yumuşak köşe, Sora etiket.
  ///
  /// pharmed-client uygulama kökünde [InputFieldTheme] ile enjekte edilir:
  /// ```dart
  /// InputFieldTheme(style: InputFieldStyle.client, child: MaterialApp(...))
  /// ```
  static const InputFieldStyle client = InputFieldStyle(
    labelFontSize: MedSpacing.labelFontSizeClient,
    labelLetterSpacing: MedSpacing.labelLetterSpacingClient,
    labelUpperCase: false,
    borderRadius: MedRadius.mdAll,
    contentPadding: MedSpacing.inputPaddingClient,
    minHeight: MedSpacing.inputMinHeightClient,
    borderWidth: 1,
    inputFontSize: 12,
    inputFontWeight: FontWeight.w500,
    inputTextAlign: TextAlign.center,
  );

  /// Mevcut style'dan türetilmiş yeni bir style döner.
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
// InputFieldTheme — InheritedWidget ile stil yayımı
// ─────────────────────────────────────────────────────────────────

/// Widget ağacına [InputFieldStyle] enjekte eder.
///
/// pharmed-client kök widget'ında [InputFieldStyle.client] ile sarılır.
/// pharmed-manager hiç sarmaz; [of] metodu [InputFieldStyle.manager] döner.
///
/// ```dart
/// // pharmed-client main.dart
/// InputFieldTheme(
///   style: InputFieldStyle.client,
///   child: MaterialApp(...),
/// )
/// ```
class InputFieldTheme extends InheritedWidget {
  const InputFieldTheme({super.key, required this.style, required super.child});

  final InputFieldStyle style;

  /// En yakın [InputFieldTheme]'den stili okur.
  ///
  /// Ağaçta [InputFieldTheme] bulunamazsa [InputFieldStyle.manager] döner.
  static InputFieldStyle of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InputFieldTheme>()?.style ?? InputFieldStyle.manager;
  }

  @override
  bool updateShouldNotify(InputFieldTheme old) => style != old.style;
}
