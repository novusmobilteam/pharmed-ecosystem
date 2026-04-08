import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'base_input_field.dart';

class TimeInputField extends BaseInputField<TimeOfDay> {
  TimeInputField({
    super.key,
    super.label,
    super.hint,
    super.initialValue,
    super.validator,
    super.enabled = true,
    String? dayHint,
    void Function(TimeOfDay? time)? onTimeSelected,
  }) : super(
         buildInput: (context, value, field) {
           return GestureDetector(
             behavior: HitTestBehavior.opaque,
             onTap: () async {
               if (!field.widget.enabled) return;

               final selected = await showTimePicker(
                 context: context,
                 initialTime: value ?? TimeOfDay.now(),
                 helpText: dayHint != null ? '$dayHint için saat seçin' : 'Saat seçin',
                 builder: (context, child) => Theme(data: Theme.of(context), child: child!),
               );

               if (selected != null && context.mounted) {
                 field.didChange(selected);
                 onTimeSelected?.call(selected);
               }
             },
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   value != null ? value.format(context) : 'Saat seçin',
                   style: MedTextStyles.bodyMd(color: value != null ? MedColors.text : MedColors.text4),
                 ),
                 if (value != null && enabled)
                   GestureDetector(
                     onTap: () {
                       field.didChange(null);
                       onTimeSelected?.call(null);
                     },
                     child: Icon(Icons.cancel_outlined, size: 14, color: MedColors.text3),
                   )
                 else
                   Icon(Icons.access_time_rounded, size: 14, color: MedColors.text3),
               ],
             ),
           );
         },
       );
}
