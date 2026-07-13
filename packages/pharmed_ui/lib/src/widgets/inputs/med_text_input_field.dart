// [SWREQ-UI-INPUT-TEXT-001]
// Sınıf : Class A
//
// applyPadding: false → decorator padding uygulamaz.
// contentPadding: style.contentPadding → TextField'a verilir.
// textAlignVertical: center → Flutter kendi mekanizmasıyla
//                             contentPadding alanı içinde ortalar.
// isDense: true → 48px floor kaldırılır.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MedTextInputField extends StatefulWidget {
  const MedTextInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.autoFocus = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.hintText,
    this.readOnly = false,
    this.controller,
    required this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.suffix,
    this.onFieldSubmitted,
  });

  final String? label;
  final String? hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final bool autoFocus;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Widget? suffix;
  final Function(String? value)? onFieldSubmitted;

  @override
  State<MedTextInputField> createState() => _MedTextInputFieldState();
}

class _MedTextInputFieldState extends State<MedTextInputField> {
  late final FocusNode _focus;
  bool _focused = false;

  bool get _isMultiline => (widget.maxLines ?? 1) > 1;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);

    return FormField<String>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        return MedInputDecorator(
          label: widget.label,
          helperText: widget.hint,
          errorText: field.errorText,
          enabled: widget.enabled,
          isFocused: _focused,
          applyPadding: false,
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: Align(
              alignment: _isMultiline ? Alignment.topLeft : Alignment.center,
              child: TextFormField(
                focusNode: _focus,
                readOnly: widget.readOnly,
                autofocus: widget.autoFocus,
                initialValue: widget.controller == null ? widget.initialValue : null,
                enabled: widget.enabled,
                //textAlignVertical: _isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
                keyboardType: widget.keyboardType,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.obscureText ? 1 : widget.minLines,
                maxLength: widget.maxLength,
                obscureText: widget.obscureText,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                onTap: widget.onTap,
                onFieldSubmitted: widget.onFieldSubmitted,
                onChanged: (v) {
                  field.didChange(v);
                  widget.onChanged?.call(v);
                },
                style: MedTextStyles.bodyMd(color: MedColors.text),
                decoration: InputDecoration(
                  suffix: widget.suffix,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: style.contentPadding,
                  counterText: '',
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: style.inputFontSize,
                    color: MedColors.text4,
                  ),

                  prefixIcon: widget.prefixIcon != null
                      ? IconTheme(
                          data: IconThemeData(size: 16, color: _focused ? MedColors.blue : MedColors.text3),
                          child: widget.prefixIcon!,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
