import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MultiSelectionField<T extends Selectable> extends BaseInputField<List<T>> {
  MultiSelectionField({
    super.key,
    required super.label,
     String? title,
    required SearchDataSource<T> dataSource,
    required String? Function(T item) labelBuilder,
    required ValueChanged<List<T>?> onSelected,
    super.initialValue,
    super.validator,
    super.enabled,
  }) : super(
         buildInput: (context, value, field) {
           final colorScheme = Theme.of(context).colorScheme;
           final hasValue = value != null && value.isNotEmpty;

           return GestureDetector(
             behavior: HitTestBehavior.opaque,
             onTap: enabled
                 ? () async {
                     final results = await SelectionDialog.showMulti<T>(
                       context,
                       title: title ?? label ?? '-',
                       dataSource: dataSource,
                       labelBuilder: labelBuilder,
                       initiallySelected: value,
                     );
                     if (results != null) {
                       field.didChange(results);
                       onSelected(results);
                     }
                   }
                 : null,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Flexible(
                   child: Text(
                     hasValue ? value.map(labelBuilder).join(', ') : 'Seçiniz',
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: MedTextStyles.bodyMd(color: MedColors.text),
                   ),
                 ),
                 Icon(PhosphorIcons.magnifyingGlass(), size: 16, color: colorScheme.onSurfaceVariant),
               ],
             ),
           );
         },
       );
}
