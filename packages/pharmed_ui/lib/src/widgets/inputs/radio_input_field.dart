import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class RadioInputField<T> extends StatelessWidget {
  const RadioInputField({
    super.key,
    this.label,
    this.initialValue,
    this.validator,
    this.enabled = true,
    required this.options,
    required this.onChanged,
  });

  final String? label;
  final T? initialValue;
  final String? Function(T?)? validator;
  final bool enabled;
  final List<MedRadioOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  label!.toUpperCase(),
                  style: MedTextStyles.monoXs(color: MedColors.text3).copyWith(letterSpacing: 0.8),
                ),
              ),

            // Seçenekler yan yana
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
                padding: const EdgeInsets.only(top: 4, left: 0),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 11, color: MedColors.red),
                    const SizedBox(width: 4),
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
