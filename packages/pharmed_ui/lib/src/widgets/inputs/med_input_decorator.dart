import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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

  final String? label;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool isFocused;
  final MedFieldState fieldState;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);
    final effectiveState = errorText != null ? MedFieldState.error : fieldState;

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
              fontWeight: FontWeight.w400,
              letterSpacing: style.labelLetterSpacing,
              color: enabled ? MedColors.text3 : MedColors.text4,
            ),
          ),
          const SizedBox(height: MedSpacing.xs),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: _resolveBgColor(effectiveState),
            borderRadius: style.borderRadius,
            border: Border.all(color: _resolveBorderColor(effectiveState), width: style.borderWidth),
          ),
          child: Padding(padding: style.contentPadding, child: child),
        ),
        if (effectiveState == MedFieldState.error && errorText != null) ...[
          const SizedBox(height: MedSpacing.xs),
          Text(
            errorText!,
            style: TextStyle(fontFamily: MedFonts.sans, fontSize: style.labelFontSize + 1, color: MedColors.red),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: MedSpacing.xs),
          Text(
            helperText!,
            style: TextStyle(fontFamily: MedFonts.sans, fontSize: style.labelFontSize + 1, color: MedColors.text3),
          ),
        ],
      ],
    );
  }

  Color _resolveBorderColor(MedFieldState state) {
    if (!enabled) return MedColors.border2;
    return switch (state) {
      MedFieldState.error => MedColors.red,
      MedFieldState.success => MedColors.green,
      MedFieldState.normal => isFocused ? MedColors.blue : MedColors.border,
    };
  }

  Color _resolveBgColor(MedFieldState state) {
    if (!enabled) return MedColors.surface3;
    return switch (state) {
      MedFieldState.error => MedColors.redLight,
      _ => isFocused ? MedColors.surface : MedColors.surface2,
    };
  }
}
