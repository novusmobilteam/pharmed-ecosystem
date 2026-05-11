import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Yeniden yazıldı: BaseInputField kalıtımı kaldırıldı, MedInputDecorator
// kompozisyon modeline geçildi. Herkese açık API değişmedi.
// NOT: Step 3.5'te MedSelectField ile birleştirilecek.

/// Manager form alanı — arama diyaloğu üzerinden tek seçim, FormField desteği.
///
/// ```dart
/// SelectionField<Branch>(
///   label: 'Branş',
///   dataSource: branchDataSource,
///   labelBuilder: (b) => b.name,
///   onSelected: (b) { ... },
/// )
/// ```
class SelectionField<T extends Selectable> extends StatefulWidget {
  const SelectionField({
    super.key,
    required this.label,
    this.title,
    required this.dataSource,
    required this.labelBuilder,
    required this.onSelected,
    this.initialValue,
    this.validator,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final String? label;
  final String? title;
  final SearchDataSource<T> dataSource;
  final String? Function(T item) labelBuilder;
  final ValueChanged<T?> onSelected;
  final T? initialValue;
  final String? Function(T?)? validator;
  final bool enabled;
  final AutovalidateMode autovalidateMode;

  @override
  State<SelectionField<T>> createState() => _SelectionFieldState<T>();
}

class _SelectionFieldState<T extends Selectable> extends State<SelectionField<T>> {
  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final value = field.value;
        final hasValue = value?.id != null;

        return MedInputDecorator(
          label: widget.label,
          errorText: field.errorText,
          enabled: widget.enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled
                ? () async {
                    final result = await SelectionDialog.show<T>(
                      context,
                      title: widget.title ?? widget.label ?? '-',
                      dataSource: widget.dataSource,
                      labelBuilder: widget.labelBuilder,
                    );
                    if (result != null) {
                      field.didChange(result);
                      widget.onSelected(result);
                    }
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    hasValue ? (widget.labelBuilder(value as T) ?? '-') : 'Seçiniz',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.bodyMd(color: MedColors.text),
                  ),
                ),
                Icon(PhosphorIcons.magnifyingGlass(), size: 16, color: MedColors.text3),
              ],
            ),
          ),
        );
      },
    );
  }
}
