import 'package:flutter/material.dart';

class InputFieldStyle {
  const InputFieldStyle({
    this.labelFontSize = 9,
    this.labelLetterSpacing = 0.8,
    this.labelUpperCase = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    this.minHeight = 36,
    this.borderWidth = 1.5,
    this.inputFontSize = 13,
    this.inputFontWeight = FontWeight.w500,
    this.inputTextAlign = TextAlign.start,
  });

  final double labelFontSize;
  final double labelLetterSpacing;
  final bool labelUpperCase;
  final BorderRadius borderRadius;
  final EdgeInsets contentPadding;
  final double minHeight;
  final double borderWidth;
  final double inputFontSize;
  final FontWeight inputFontWeight;
  final TextAlign inputTextAlign;

  /// Manager varsayılanı — küçük, keskin köşe, uppercase label
  static const manager = InputFieldStyle();

  /// Client varsayılanı — daha büyük, yuvarlak köşe, normal label
  static const client = InputFieldStyle(
    labelFontSize: 11,
    labelLetterSpacing: 0,
    labelUpperCase: false,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    contentPadding: EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    minHeight: 44,
    borderWidth: 1.5,
    inputFontSize: 14,
    inputFontWeight: FontWeight.w600,
    inputTextAlign: TextAlign.center,
  );

  InputFieldStyle copyWith({
    double? labelFontSize,
    double? labelLetterSpacing,
    bool? labelUpperCase,
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
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
}

class InputFieldTheme extends InheritedWidget {
  const InputFieldTheme({super.key, required this.style, required super.child});

  final InputFieldStyle style;

  /// Context'ten en yakın [InputFieldTheme]'i okur.
  /// Bulunamazsa manager varsayılanını döner.
  static InputFieldStyle of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InputFieldTheme>()?.style ?? InputFieldStyle.manager;
  }

  @override
  bool updateShouldNotify(InputFieldTheme oldWidget) => oldWidget.style != style;
}
