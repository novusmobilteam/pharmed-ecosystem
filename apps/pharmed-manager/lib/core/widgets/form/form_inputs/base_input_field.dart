import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

abstract class BaseInputField<T> extends FormField<T> {
  BaseInputField({
    super.key,
    super.initialValue,
    super.validator,
    super.enabled = true,
    String? label,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? dialogTitle,
    required Widget Function(BuildContext context, T? value, FormFieldState<T> field) buildInput,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          builder: (field) {
            final context = field.context;
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final hasError = field.hasError;
            final isEnabled = enabled && field.widget.enabled;

            // Label Stili
            final labelStyle = theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: hasError ? colorScheme.error : colorScheme.onSurface,
            );

            // Hint text stili
            final hintStyle = theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withAlpha(128), // withValues yerine withAlpha
            );

            // Arka Plan Rengi
            final backgroundColor = isEnabled
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surfaceContainerHighest.withAlpha(30); // %12 opacity ~ Alpha 30

            return SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input Kutusu
                  AnimatedContainer(
                    alignment: Alignment.centerLeft,
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    constraints: const BoxConstraints(minHeight: 50),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: hasError
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant.withAlpha(77), // %30 opacity ~ Alpha 77
                        width: hasError ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label != null)
                          // Label ve Kilit İkonu Satırı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(label, style: labelStyle),
                              if (!isEnabled)
                                Icon(
                                  PhosphorIcons.lock(),
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant.withAlpha(128), // %50 opacity
                                ),
                            ],
                          ),

                        // Hint Text (isteğe bağlı)
                        if (hintText != null && hintText.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            hintText,
                            style: hintStyle,
                          ),
                        ],

                        // Prefix Icon, Input ve Suffix Icon
                        Row(
                          children: [
                            if (prefixIcon != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconTheme(
                                  data: IconThemeData(
                                    color: isEnabled
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurfaceVariant.withAlpha(128),
                                  ),
                                  child: prefixIcon,
                                ),
                              ),
                            ],
                            Expanded(
                              child: IgnorePointer(
                                ignoring: !isEnabled,
                                child: Opacity(
                                  opacity: isEnabled ? 1.0 : 0.5,
                                  child: buildInput(context, field.value, field),
                                ),
                              ),
                            ),
                            if (suffixIcon != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: IconTheme(
                                  data: IconThemeData(
                                    color: isEnabled
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurfaceVariant.withAlpha(128),
                                  ),
                                  child: suffixIcon,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Hata Mesajı
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.warningCircle(),
                            size: 14,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              field.errorText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
}
