import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// Yeniden yazıldı: BaseInputField kalıtımı kaldırıldı, MedInputDecorator
// kompozisyon modeline geçildi. Herkese açık API değişmedi.

/// Manager form alanı — sistem tarih seçici ile FormField destekli tarih girişi.
///
/// Dokunulduğunda Material DatePicker açılır. Seçilen tarih formatlanarak
/// gösterilir. FormField doğrulaması desteklenir.
///
/// ```dart
/// DateInputField(
///   label: 'Başlangıç Tarihi',
///   validator: (d) => d == null ? 'Zorunlu' : null,
///   onDateSelected: (date) { ... },
/// )
/// ```
class DateInputField extends StatefulWidget {
  const DateInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
  });

  final String? label;
  final String? hint;
  final DateTime? initialValue;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime date)? onDateSelected;

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
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
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: value ?? DateTime.now(),
                      firstDate: widget.firstDate ?? DateTime(1900),
                      lastDate: widget.lastDate ?? DateTime(2100),
                      locale: const Locale('tr', 'TR'),
                      builder: (context, child) => Theme(data: Theme.of(context), child: child!),
                    );
                    if (selected != null) {
                      field.didChange(selected);
                      widget.onDateSelected?.call(selected);
                    }
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value != null ? value.formattedDate : 'Tarih seçin',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.bodyMd(color: value != null ? MedColors.text : MedColors.text4),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: 14, color: MedColors.text3),
              ],
            ),
          ),
        );
      },
    );
  }
}
