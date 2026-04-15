import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class DateInputField extends BaseInputField<DateTime> {
  DateInputField({
    super.key,
    super.label,
    super.hint,
    super.initialValue,
    super.validator,
    super.enabled = true,
    DateTime? firstDate,
    DateTime? lastDate,
    void Function(DateTime date)? onDateSelected,
  }) : super(
         buildInput: (context, value, field) {
           return GestureDetector(
             behavior: HitTestBehavior.opaque,
             onTap: () async {
               if (!field.widget.enabled) return;

               final selected = await showDatePicker(
                 context: context,
                 initialDate: value ?? DateTime.now(),
                 firstDate: firstDate ?? DateTime(1900),
                 lastDate: lastDate ?? DateTime(2100),
                 locale: const Locale('tr', 'TR'),
                 builder: (context, child) => Theme(data: Theme.of(context), child: child!),
               );

               if (selected != null) {
                 field.didChange(selected);
                 onDateSelected?.call(selected);
               }
             },
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
           );
         },
       );
}
