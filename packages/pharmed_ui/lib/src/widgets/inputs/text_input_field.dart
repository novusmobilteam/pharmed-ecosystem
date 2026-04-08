import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class TextInputField extends BaseInputField<String> {
  TextInputField({
    super.key,
    super.label,
    super.hint,
    super.initialValue,
    super.validator,
    super.enabled,
    bool autoFocus = false,
    TextInputType? keyboardType,
    int? maxLines = 1,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    bool readOnly = false,
    TextEditingController? controller,
    required ValueChanged<String?> onChanged,
    Widget? suffixIcon,
    VoidCallback? onTap,
    Widget? suffix,
  }) : super(
         buildInput: (context, value, field) {
           return TextFormField(
             readOnly: readOnly,
             autofocus: autoFocus,
             initialValue: controller == null ? initialValue : null,
             enabled: enabled,
             keyboardType: keyboardType,
             maxLines: obscureText ? 1 : maxLines,
             maxLength: maxLength,
             obscureText: obscureText,
             inputFormatters: inputFormatters,
             controller: controller,
             onTap: onTap,

             onChanged: (newValue) {
               field.didChange(newValue);
               onChanged(newValue);
             },
             style: MedTextStyles.bodyMd(color: MedColors.text),
             decoration: InputDecoration(
               suffix: suffix,
               border: InputBorder.none,
               enabledBorder: InputBorder.none,
               focusedBorder: InputBorder.none,
               errorBorder: InputBorder.none,
               disabledBorder: InputBorder.none,
               isDense: true,
               filled: false,
               contentPadding: EdgeInsets.zero,
               counterText: '',
               hintText: hintText,
               hintStyle: MedTextStyles.bodyMd(color: MedColors.text4),
               suffixIcon: suffixIcon,
               suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
             ),
           );
         },
       );
}
