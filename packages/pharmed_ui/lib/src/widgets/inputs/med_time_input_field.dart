import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// Yeniden yazıldı: BaseInputField kalıtımı kaldırıldı, MedInputDecorator
// kompozisyon modeline geçildi. Herkese açık API değişmedi.

/// Manager form alanı — sistem saat seçici ile FormField destekli saat girişi.
///
/// Dokunulduğunda Material TimePicker açılır. İsteğe bağlı [dayHint]
/// ile hangi güne ait olduğu belirtilebilir. X butonu ile seçim temizlenir.
///
/// ```dart
/// TimeInputField(
///   label: 'Doz Saati',
///   dayHint: 'Pazartesi',
///   onTimeSelected: (time) { ... },
/// )
/// ```
class MedTimeInputField extends StatefulWidget {
  const MedTimeInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.dayHint,
    this.onTimeSelected,
  });

  final String? label;
  final String? hint;
  final TimeOfDay? initialValue;
  final String? Function(TimeOfDay?)? validator;
  final bool enabled;
  final AutovalidateMode autovalidateMode;

  /// Hangi güne ait olduğunu belirtir — TimePicker başlığında gösterilir.
  final String? dayHint;
  final void Function(TimeOfDay? time)? onTimeSelected;

  @override
  State<MedTimeInputField> createState() => _MedTimeInputFieldState();
}

class _MedTimeInputFieldState extends State<MedTimeInputField> {
  @override
  Widget build(BuildContext context) {
    return FormField<TimeOfDay>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final value = field.value;

        return MedInputDecorator(
          label: widget.label,
          helperText: widget.hint,
          errorText: field.errorText,
          enabled: widget.enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled
                ? () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: value ?? TimeOfDay.now(),
                      helpText: widget.dayHint != null
                          ? context.l10n.timeField_helpTextWithDay(widget.dayHint!)
                          : context.l10n.timeField_helpText,
                      builder: (context, child) => Theme(data: Theme.of(context), child: child!),
                    );
                    if (selected != null && context.mounted) {
                      field.didChange(selected);
                      widget.onTimeSelected?.call(selected);
                    }
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? value.format(context) : context.l10n.timeField_placeholder,
                  style: MedTextStyles.bodyMd(color: value != null ? MedColors.text : MedColors.text4),
                ),
                if (value != null && widget.enabled)
                  GestureDetector(
                    onTap: () {
                      field.didChange(null);
                      widget.onTimeSelected?.call(null);
                    },
                    child: Icon(Icons.cancel_outlined, size: 14, color: MedColors.text3),
                  )
                else
                  Icon(Icons.access_time_rounded, size: 14, color: MedColors.text3),
              ],
            ),
          ),
        );
      },
    );
  }
}
