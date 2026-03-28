import 'package:flutter/material.dart';

import 'base_input_field.dart';

class BaseDisplayField<T> extends BaseInputField<T> {
  BaseDisplayField({
    super.key,
    required super.label,
    required String displayText,
    super.initialValue,
    super.validator,
    super.enabled = true,
    super.hintText,
    super.prefixIcon,
    super.suffixIcon,
    super.autovalidateMode,
    VoidCallback? onTap, // Tıklama aksiyonu
  }) : super(
          buildInput: (context, value, field) {
            final theme = Theme.of(context);

            return InkWell(
              onTap: enabled ? onTap : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  displayText.isEmpty ? (hintText ?? "") : displayText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: displayText.isEmpty
                        ? theme.colorScheme.onSurfaceVariant.withAlpha(128)
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          },
        );
}
