import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// Temizlendi: label stili InputFieldTheme'e bağlandı.
// Herkese açık API değişmedi.

/// Radio buton grubu, FormField desteği ile.
///
/// ```dart
/// RadioInputField<Gender>(
///   label: 'Cinsiyet',
///   options: [
///     MedRadioOption(value: Gender.male, label: 'Erkek'),
///     MedRadioOption(value: Gender.female, label: 'Kadın'),
///   ],
///   onChanged: (g) { ... },
/// )
/// ```
class RadioInputField<T> extends StatelessWidget {
  const RadioInputField({
    super.key,
    this.label,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.options,
    required this.onChanged,
  });

  final String? label;
  final T? initialValue;
  final String? Function(T?)? validator;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final List<MedRadioOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);

    return FormField<T>(
      initialValue: initialValue,
      validator: validator,
      autovalidateMode: autovalidateMode,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: MedSpacing.xs),
                child: Text(
                  style.labelUpperCase ? label!.toUpperCase() : label!,
                  style: TextStyle(
                    fontFamily: MedFonts.mono,
                    fontSize: style.labelFontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: style.labelLetterSpacing,
                    color: field.hasError ? MedColors.red : MedColors.text3,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: options.map((opt) {
                return MedRadio<T>(
                  value: opt.value,
                  groupValue: field.value,
                  enabled: enabled && opt.enabled,
                  label: opt.label,
                  onChanged: (selected) {
                    field.didChange(selected);
                    onChanged(selected);
                  },
                );
              }).toList(),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: MedSpacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 11, color: MedColors.red),
                    const SizedBox(width: MedSpacing.xs),
                    Text(field.errorText!, style: MedTextStyles.monoXs(color: MedColors.red)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
