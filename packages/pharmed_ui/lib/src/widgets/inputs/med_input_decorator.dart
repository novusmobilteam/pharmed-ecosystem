import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'input_field_style.dart';

// ─────────────────────────────────────────────────────────────────
// MedFieldState — Input durumu enum'u
// ─────────────────────────────────────────────────────────────────

/// Input alanının anlık görsel durumu.
///
/// - [normal]: Varsayılan, pasif durum.
/// - [error]: Doğrulama hatası — kırmızı kenarlık ve gölge.
/// - [success]: Başarılı doğrulama — yeşil kenarlık.
enum MedFieldState { normal, error, success }

// ─────────────────────────────────────────────────────────────────
// MedInputDecorator — Görsel kabuk widget'ı
//
// [SWREQ-UI-INPUT-DEC-001]
// Tüm input widget'larının paylaştığı görsel kabuk.
// Yalnızca görsel sorumluluk taşır: label, kenarlık, padding,
// hata/yardımcı metin. State yönetimi yoktur, FormField değildir.
//
// Tüm görsel değerleri [InputFieldTheme.of(context)] üzerinden okur —
// sıfır hardcoded tasarım değeri.
// ─────────────────────────────────────────────────────────────────

/// Input alanları için paylaşılan görsel kabuk.
///
/// Doğrudan kullanılmaz; her input widget'ı bunu içsel olarak
/// kendi `build` metodunda oluşturur.
///
/// ```dart
/// // MedTextField.build içinde:
/// return MedInputDecorator(
///   label: widget.label,
///   errorText: widget.errorText,
///   isFocused: _focused,
///   fieldState: widget.fieldState,
///   child: TextField(...),
/// );
/// ```
class MedInputDecorator extends StatelessWidget {
  const MedInputDecorator({
    super.key,
    this.label,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.isFocused = false,
    this.fieldState = MedFieldState.normal,
    required this.child,
  });

  /// Input üzerinde gösterilen etiket metni.
  final String? label;

  /// Hata mesajı — varsa [fieldState]'i [MedFieldState.error]'a zorlar.
  final String? errorText;

  /// Hata yokken gösterilen yardımcı metin.
  final String? helperText;

  /// Input'un etkin olup olmadığı. Devre dışıysa soluk renk uygulanır.
  final bool enabled;

  /// Focus durumu — mavi kenarlık ve gölge için dışarıdan iletilir.
  final bool isFocused;

  /// Görsel durum — hata veya başarı rengi için.
  final MedFieldState fieldState;

  /// Gerçek input içeriği (TextField, GestureDetector sarmalı görünüm vb.).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);

    final effectiveState =
        errorText != null ? MedFieldState.error : fieldState;
    final borderColor = _resolveBorderColor(effectiveState);
    final bgColor = _resolveBgColor(effectiveState);
    final shadow = _resolveShadow(effectiveState);

    final labelText = label == null
        ? null
        : style.labelUpperCase
            ? label!.toUpperCase()
            : label!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText,
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: style.labelFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: style.labelLetterSpacing,
              color: enabled ? MedColors.text3 : MedColors.text4,
            ),
          ),
          const SizedBox(height: MedSpacing.xs),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(minHeight: style.minHeight),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: style.borderRadius,
            border: Border.all(
              color: borderColor,
              width: style.borderWidth,
            ),
            boxShadow: shadow,
          ),
          padding: style.contentPadding,
          child: child,
        ),
        if (effectiveState == MedFieldState.error && errorText != null) ...[
          const SizedBox(height: MedSpacing.xs),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: style.labelFontSize + 1,
              color: MedColors.red,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: MedSpacing.xs),
          Text(
            helperText!,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: style.labelFontSize + 1,
              color: MedColors.text3,
            ),
          ),
        ],
      ],
    );
  }

  Color _resolveBorderColor(MedFieldState state) {
    if (!enabled) return MedColors.border2;
    return switch (state) {
      MedFieldState.error   => MedColors.red,
      MedFieldState.success => MedColors.green,
      MedFieldState.normal  => isFocused ? MedColors.blue : MedColors.border,
    };
  }

  Color _resolveBgColor(MedFieldState state) {
    if (!enabled) return MedColors.surface3;
    return switch (state) {
      MedFieldState.error  => MedColors.redLight,
      _                    => isFocused ? MedColors.surface : MedColors.surface2,
    };
  }

  List<BoxShadow>? _resolveShadow(MedFieldState state) {
    if (!enabled || !isFocused) return null;
    final color = state == MedFieldState.error
        ? MedColors.shadowRed
        : MedColors.shadowBlue;
    return [BoxShadow(color: color, blurRadius: 0, spreadRadius: 3)];
  }
}
