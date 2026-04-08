import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SelectionField<T extends Selectable> extends BaseInputField<T> {
  SelectionField({
    super.key,
    required super.label,
    required String title,
    required SearchDataSource<T> dataSource,
    required String Function(T item) labelBuilder,
    required ValueChanged<T?> onSelected,
    super.initialValue,
    super.validator,
    super.enabled,
  }) : super(
         buildInput: (context, value, field) {
           final colorScheme = Theme.of(context).colorScheme;
           final hasValue = value?.id != null;

           return GestureDetector(
             behavior: HitTestBehavior.opaque,
             onTap: enabled
                 ? () async {
                     final result = await PharmedSearchDialog.show<T>(
                       context,
                       title: title,
                       dataSource: dataSource,
                       labelBuilder: labelBuilder,
                     );
                     if (result != null) {
                       field.didChange(result);
                       onSelected(result);
                     }
                   }
                 : null,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Flexible(
                   child: Text(
                     hasValue ? labelBuilder(value as T) : 'Seçiniz',
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
