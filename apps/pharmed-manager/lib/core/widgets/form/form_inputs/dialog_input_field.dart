import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core.dart';

part 'selection_dialog.dart';

typedef DialogFuture<T> = Future<Result<ApiResponse<List<T>>?>> Function();

/// Tekli Seçim Yapan Dialog Input
class DialogInputField<T extends Selectable> extends BaseInputField<T> {
  DialogInputField({
    super.key,
    required super.label,
    DialogFuture<T>? future,
    ValueNotifier<DialogFuture<T>>? futureNotifier,
    required String? Function(T?) labelBuilder,
    required ValueChanged<T?> onSelected,
    bool showIcon = true,
    super.initialValue,
    super.validator,
    super.enabled,

    List<Widget>? actions,
  }) : super(
         buildInput: (context, value, field) {
           final colorScheme = Theme.of(context).colorScheme;

           return GestureDetector(
             behavior: HitTestBehavior.opaque,
             onTap: enabled
                 ? () async {
                     final result = await showDialog<T>(
                       context: context,
                       builder: (_) => SelectionDialog.single(
                         dialogTitle: label ?? '',
                         future: future,
                         futureNotifier: futureNotifier,
                         selected: value,
                         actions: actions,
                       ),
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
                     (value?.id != null && labelBuilder(value) != null) ? labelBuilder(value)! : 'Seçiniz',
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(
                       color: (value?.id != null)
                           ? colorScheme.onSurface
                           : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                       fontSize: 14,
                     ),
                   ),
                 ),
                 if (showIcon) Icon(PhosphorIcons.magnifyingGlass(), size: 16, color: colorScheme.onSurfaceVariant),
               ],
             ),
           );
         },
       );
}

/// Çoklu Seçim Yapan Dialog Input
class MultiDialogInputField<T extends Selectable> extends BaseInputField<List<T>> {
  MultiDialogInputField({
    super.key,
    required super.label,
    required DialogFuture<T> future,
    ValueNotifier<DialogFuture<T>>? futureNotifier,
    required String? Function(T?) labelBuilder,
    required ValueChanged<List<T>?> onSelected,
    super.initialValue,
    super.validator,
    super.enabled,
    bool showIcon = true,
  }) : super(
         buildInput: (context, value, field) {
           final colorScheme = Theme.of(context).colorScheme;

           final displayText = (value != null && value.isNotEmpty) ? value.map(labelBuilder).join(', ') : 'Seçiniz';

           return GestureDetector(
             behavior: HitTestBehavior.opaque,
             onTap: enabled
                 ? () async {
                     final result = await showDialog<List<T>>(
                       context: context,
                       builder: (_) => SelectionDialog.multi(
                         dialogTitle: label ?? '',
                         future: future,
                         initiallySelected: value,
                         labelBuilder: labelBuilder,
                       ),
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
                 Expanded(
                   child: Text(
                     displayText,
                     style: TextStyle(
                       color: (value != null && value.isNotEmpty)
                           ? colorScheme.onSurface
                           : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                       fontSize: 14,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 if (showIcon) Icon(PhosphorIcons.magnifyingGlass(), size: 16, color: colorScheme.onSurfaceVariant),
               ],
             ),
           );
         },
       );
}
