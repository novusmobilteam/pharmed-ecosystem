import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'med_input_decorator.dart';
import 'input_field_style.dart';

// Yeniden yazıldı: BaseInputField kalıtımı kaldırıldı, MedInputDecorator
// kompozisyon modeline geçildi. Herkese açık API değişmedi.

/// Manager form alanı — tek satır metin girişi, FormField desteği ile.
///
/// [MedTextField] aynı görsel kabuğu dokunmatik olmayan formlar için
/// FormField sarmalıyla sunar. Doğrulama ve autovalidate destekler.
///
/// pharmed-manager formlarında doğrulama gereken alanlar için kullanılır:
/// ```dart
/// TextInputField(
///   label: 'E-posta',
///   validator: (v) => v!.isEmpty ? 'Boş olamaz' : null,
///   onChanged: (v) { ... },
/// )
/// ```
class TextInputField extends StatefulWidget {
  const TextInputField({
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
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.hintText,
    this.readOnly = false,
    this.controller,
    required this.onChanged,
    this.suffixIcon,
    this.onTap,
    this.suffix,
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
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String?> onChanged;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late final FocusNode _focus;
  bool _focused = false;

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
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: TextFormField(
              focusNode: _focus,
              readOnly: widget.readOnly,
              autofocus: widget.autoFocus,
              initialValue: widget.controller == null ? widget.initialValue : null,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              maxLength: widget.maxLength,
              obscureText: widget.obscureText,
              inputFormatters: widget.inputFormatters,
              controller: widget.controller,
              onTap: widget.onTap,
              onChanged: (v) {
                field.didChange(v);
                widget.onChanged(v);
              },
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: style.inputFontSize,
                fontWeight: style.inputFontWeight,
                color: MedColors.text,
              ),
              decoration: InputDecoration(
                suffix: widget.suffix,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                counterText: '',
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: style.inputFontSize,
                  color: MedColors.text4,
                ),
                suffixIcon: widget.suffixIcon,
                suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}
