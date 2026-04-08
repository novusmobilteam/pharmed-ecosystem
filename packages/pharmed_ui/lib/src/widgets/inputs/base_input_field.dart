import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

abstract class BaseInputField<T> extends FormField<T> {
  BaseInputField({
    super.key,
    super.initialValue,
    super.validator,
    super.enabled = true,
    String? label,
    String? hint,
    super.autovalidateMode = AutovalidateMode.disabled,
    required Widget Function(BuildContext context, T? value, FormFieldState<T> field) buildInput,
  }) : super(
         builder: (field) {
           final context = field.context;
           final hasError = field.hasError;
           final isEnabled = enabled && field.widget.enabled;

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               // Label
               if (label != null)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 4),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         label.toUpperCase(),
                         style: MedTextStyles.monoXs(
                           color: hasError ? MedColors.red : MedColors.text3,
                         ).copyWith(letterSpacing: 0.8),
                       ),
                       if (!isEnabled) Icon(Icons.lock_outline_rounded, size: 10, color: MedColors.text4),
                     ],
                   ),
                 ),

               // Input kutusu
               AnimatedContainer(
                 duration: const Duration(milliseconds: 150),
                 padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                 constraints: const BoxConstraints(minHeight: 38),
                 decoration: BoxDecoration(
                   color: isEnabled ? MedColors.surface2 : MedColors.surface3,
                   borderRadius: MedRadius.smAll,
                   border: Border.all(color: hasError ? MedColors.red : MedColors.border, width: 1.5),
                 ),
                 child: IgnorePointer(
                   ignoring: !isEnabled,
                   child: Opacity(opacity: isEnabled ? 1.0 : 0.5, child: buildInput(context, field.value, field)),
                 ),
               ),

               // Hint
               if (hint != null && !hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4, left: 2),
                   child: Text(hint, style: MedTextStyles.monoXs()),
                 ),

               // Hata mesajı
               if (hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4, left: 2),
                   child: Row(
                     children: [
                       Icon(Icons.warning_amber_rounded, size: 11, color: MedColors.red),
                       const SizedBox(width: 4),
                       Expanded(
                         child: Text(field.errorText!, style: MedTextStyles.monoXs(color: MedColors.red)),
                       ),
                     ],
                   ),
                 ),
             ],
           );
         },
       );
}
