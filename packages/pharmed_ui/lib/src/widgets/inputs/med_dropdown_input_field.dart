import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Yeniden yazıldı: BaseInputField kalıtımı kaldırıldı, MedInputDecorator
// kompozisyon modeline geçildi. Herkese açık API değişmedi.
// NOT: Step 3.5'te MedDropdown ile birleştirilecek.

/// Manager form alanı — açılır menü, FormField desteği ile.
///
/// ```dart
/// DropdownInputField<String>(
///   label: 'Birim',
///   options: ['mg', 'ml', 'adet'],
///   labelBuilder: (v) => v,
///   onChanged: (v) { ... },
/// )
/// ```
class MedDropdownInputField<T> extends StatefulWidget {
  const MedDropdownInputField({
    super.key,
    required this.options,
    required this.onChanged,
    required this.labelBuilder,
    this.label,
    this.validator,
    this.initialValue,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.placeholder,
  });

  final List<T> options;
  final ValueChanged<T?> onChanged;
  final String? Function(T?) labelBuilder;
  final String? label;
  final String? Function(T?)? validator;
  final T? initialValue;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final String? placeholder;

  @override
  State<MedDropdownInputField<T>> createState() => _MedDropdownInputFieldState<T>();
}

class _MedDropdownInputFieldState<T> extends State<MedDropdownInputField<T>> {
  // null'ı PopupMenuItem.value içinde kullanmak için sentinel.
  static const Object _nullSentinel = Object();

  Object? _toMenuValue(T? v) => v ?? _nullSentinel;
  T? _fromMenuValue(Object? v) => identical(v, _nullSentinel) ? null : v as T?;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final value = field.value;
        final resolvedPlaceholder = widget.placeholder ?? context.l10n.common_selectPlaceholder;
        return MedInputDecorator(
          label: widget.label,
          errorText: field.errorText,
          enabled: widget.enabled,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return PopupMenuButton<Object>(
                enabled: widget.enabled,
                initialValue: _toMenuValue(value),
                onSelected: (Object selected) {
                  final newValue = _fromMenuValue(selected);
                  field.didChange(newValue);
                  widget.onChanged(newValue);
                },
                constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth),
                offset: const Offset(0, 30),

                elevation: 3,
                itemBuilder: (context) => widget.options.map((item) {
                  return PopupMenuItem<Object>(
                    value: _toMenuValue(item),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Text(widget.labelBuilder(item) ?? '-', style: MedTextStyles.bodyMd(color: MedColors.text)),
                    ),
                  );
                }).toList(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value != null
                            ? (widget.labelBuilder(value) ?? '-')
                            : (widget.labelBuilder(null) ?? resolvedPlaceholder),
                        style: MedTextStyles.bodyMd(color: MedColors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(PhosphorIcons.caretDown(), size: 16, color: MedColors.text3),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
