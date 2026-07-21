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
  late final TextEditingController _controller;
  bool _focused = false;
  bool _hasText = false;

  bool get _isMultiline => (widget.maxLines ?? 1) > 1;
  bool get _isExternalController => widget.controller != null;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);

  void _onTextChanged() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.removeListener(_onTextChanged);
    if (!_isExternalController) _controller.dispose();
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
          child: _buildInner(style, field),
        );
      },
    );
  }

  Widget _buildInner(InputFieldStyle style, FormFieldState<String> field) {
    final hPad = style.contentPadding.horizontal / 2;

    return SizedBox(
      height: !_isMultiline ? style.minHeight : null,
      child: Row(
        crossAxisAlignment: _isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Prefix icon
          if (widget.prefixIcon != null)
            Padding(
              padding: EdgeInsets.only(left: hPad, right: hPad / 2),
              child: IconTheme(
                data: IconThemeData(size: 16, color: _focused ? MedColors.blue : MedColors.text3),
                child: widget.prefixIcon!,
              ),
            )
          else
            SizedBox(width: hPad),

          // EditableText + hint stack
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.enabled
                  ? () {
                      if (!_focus.hasFocus) {
                        _focus.requestFocus();
                      }
                      widget.onTap?.call();
                    }
                  : null,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Hint
                  if (!_hasText && widget.hintText != null)
                    Text(
                      widget.hintText!,
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: style.inputFontSize,
                        color: MedColors.text4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Input
                  EditableText(
                    controller: _controller,
                    focusNode: _focus,
                    readOnly: widget.readOnly,
                    autofocus: widget.autoFocus,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    minLines: widget.obscureText ? 1 : widget.minLines,
                    obscureText: widget.obscureText,
                    inputFormatters: widget.inputFormatters,
                    onChanged: (v) {
                      field.didChange(v);
                      widget.onChanged?.call(v);
                    },
                    onSubmitted: widget.onFieldSubmitted,
                    style: MedTextStyles.bodyMd(color: widget.enabled ? MedColors.text : MedColors.text3),
                    cursorColor: MedColors.blue,
                    backgroundCursorColor: MedColors.border,
                  ),
                ],
              ),
            ),
          ),

          // Suffix / suffix icon
          if (widget.suffix != null)
            Padding(
              padding: EdgeInsets.only(right: hPad),
              child: widget.suffix!,
            )
          else if (widget.suffixIcon != null)
            Padding(
              padding: EdgeInsets.only(right: hPad / 2),
              child: SizedBox(width: 32, child: widget.suffixIcon!),
            )
          else
            SizedBox(width: hPad),
        ],
      ),
    );
  }
}
