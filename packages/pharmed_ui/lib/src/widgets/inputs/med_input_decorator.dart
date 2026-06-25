// [SWREQ-UI-INPUT-DEC-001]
// Sınıf : Class A
//
// applyPadding parametresi:
//   true  (default) → Padding(style.contentPadding) uygulanır.
//                     PopupMenuButton, DatePicker gibi widget'lar için.
//   false           → Padding uygulanmaz; child kendi padding'ini yönetir.
//                     TextFormField için — contentPadding TextField'a verilir,
//                     textAlignVertical:center ile doğru ortalama sağlanır.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum MedFieldState { normal, error, success }

class MedInputDecorator extends StatelessWidget {
  const MedInputDecorator({
    super.key,
    this.label,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.isFocused = false,
    this.fieldState = MedFieldState.normal,
    this.applyPadding = true,
    required this.child,
  });

  final String? label;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool isFocused;
  final MedFieldState fieldState;

  /// false geçilirse Padding uygulanmaz — child kendi padding'ini yönetir.
  /// [MedTextInputField] bunu false geçer; contentPadding TextField'a verilir.
  final bool applyPadding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);
    final effectiveState = errorText != null ? MedFieldState.error : fieldState;

    final labelText = label == null
        ? null
        : style.labelUpperCase
        ? label!
        : label!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText,
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          const SizedBox(height: MedSpacing.xs),
        ],
        Container(
          constraints: BoxConstraints(minHeight: style.minHeight),
          decoration: BoxDecoration(
            color: _resolveBgColor(effectiveState),
            borderRadius: style.borderRadius,
            border: Border.all(color: _resolveBorderColor(effectiveState)),
          ),
          child: applyPadding
              ? Padding(padding: style.contentPadding, child: child)
              : Align(alignment: Alignment.center, child: child),
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
