import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Yeniden yazıldı: BaseInputField kalıtımı kaldırıldı, MedInputDecorator
// kompozisyon modeline geçildi. Yanlış pharmed_manager import'u düzeltildi.
// Herkese açık API değişmedi.

/// Manager form alanı — arama diyaloğu üzerinden çoklu seçim, FormField desteği.
///
/// ```dart
/// MultiSelectionField<Role>(
///   label: 'Roller',
///   dataSource: roleDataSource,
///   labelBuilder: (r) => r.name,
///   onSelected: (roles) { ... },
/// )
/// ```
class MultiSelectionField<T extends Selectable> extends StatefulWidget {
  const MultiSelectionField({
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
  final ValueChanged<List<T>?> onSelected;
  final List<T>? initialValue;
  final String? Function(List<T>?)? validator;
  final bool enabled;
  final AutovalidateMode autovalidateMode;

  @override
  State<MultiSelectionField<T>> createState() => _MultiSelectionFieldState<T>();
}

class _MultiSelectionFieldState<T extends Selectable> extends State<MultiSelectionField<T>> {
  @override
  Widget build(BuildContext context) {
    return FormField<List<T>>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final value = field.value;
        final hasValue = value != null && value.isNotEmpty;

        return MedInputDecorator(
          label: widget.label,
          errorText: field.errorText,
          enabled: widget.enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled
                ? () async {
                    final results = await SelectionDialog.showMulti<T>(
                      context,
                      title: widget.title ?? widget.label ?? '-',
                      dataSource: widget.dataSource,
                      labelBuilder: widget.labelBuilder,
                      initiallySelected: value,
                    );
                    if (results != null) {
                      field.didChange(results);
                      widget.onSelected(results);
                    }
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    hasValue ? value.map(widget.labelBuilder).join(', ') : 'Seçiniz',
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
