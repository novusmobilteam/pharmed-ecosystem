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
class MedRadioInputField<T> extends StatelessWidget {
  const MedRadioInputField({
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

class MedRadio<T> extends StatelessWidget {
  const MedRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(value) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RadioDot(selected: _selected),
              if (label != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label!,
                    style: const TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 14,
                      color: MedColors.text,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? MedColors.blue : MedColors.surface2,
        border: Border.all(color: selected ? MedColors.blue : MedColors.border, width: 2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: selected ? 8 : 0,
          height: selected ? 8 : 0,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ── Grup yardımcısı ───────────────────────────────────────────────

/// Radyo seçeneklerini dikey olarak listeleyen yardımcı widget.
class MedRadioGroup<T> extends StatelessWidget {
  const MedRadioGroup({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
  });

  final List<MedRadioOption<T>> options;
  final T? groupValue;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options
          .map(
            (opt) => MedRadio<T>(
              value: opt.value,
              groupValue: groupValue,
              onChanged: onChanged,
              label: opt.label,
              enabled: enabled && opt.enabled,
            ),
          )
          .toList(),
    );
  }
}

class MedRadioOption<T> {
  const MedRadioOption({required this.value, required this.label, this.enabled = true});
  final T value;
  final String label;
  final bool enabled;
}
