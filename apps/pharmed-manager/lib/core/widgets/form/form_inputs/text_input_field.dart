import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_input_field.dart';

class TextInputField extends BaseInputField<String> {
  TextInputField({
    super.key,
    required super.label,
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
    bool? readOnly,
    TextEditingController? controller,
    required ValueChanged<String?> onChanged,
    Widget? suffixIcon,
    Widget? suffix,
    VoidCallback? onTap,
  }) : super(
          buildInput: (context, value, field) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return TextFormField(
              readOnly: readOnly ?? false,
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
              onChanged: (String? newValue) {
                field.didChange(newValue);
                onChanged(newValue);
              },
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
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
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(120),
                ),
                suffix: suffix,
                suffixIcon: suffixIcon,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            );
          },
        );
}
