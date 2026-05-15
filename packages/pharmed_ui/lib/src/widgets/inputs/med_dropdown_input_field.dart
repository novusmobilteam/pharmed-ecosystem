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
    required this.label,
    this.validator,
    this.initialValue,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final List<T> options;
  final ValueChanged<T> onChanged;
  final String? Function(T?) labelBuilder;
  final String? label;
  final String? Function(T?)? validator;
  final T? initialValue;
  final bool enabled;
  final AutovalidateMode autovalidateMode;

  @override
  State<MedDropdownInputField<T>> createState() => _MedDropdownInputFieldState<T>();
}

class _MedDropdownInputFieldState<T> extends State<MedDropdownInputField<T>> {
  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final value = field.value;
        return MedInputDecorator(
          label: widget.label,
          errorText: field.errorText,
          enabled: widget.enabled,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return PopupMenuButton<T>(
                enabled: widget.enabled,
                initialValue: value,
                onSelected: (T newValue) {
                  field.didChange(newValue);
                  widget.onChanged(newValue);
                },
                constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth),
                offset: const Offset(0, 30),

                elevation: 3,
                itemBuilder: (context) => widget.options.map((item) {
                  return PopupMenuItem<T>(
                    value: item,
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
                        value != null ? (widget.labelBuilder(value) ?? '-') : 'Seçiniz',
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
