import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'base_input_field.dart';

class DropdownInputField<T> extends BaseInputField<T> {
  DropdownInputField({
    super.key,
    required List<T> options,
    required ValueChanged<T> onChanged,
    required String? Function(T?) labelBuilder,
    required super.label,
    super.validator,
    super.initialValue,
    super.enabled,
  }) : super(
          buildInput: (context, value, field) {
            final colorScheme = Theme.of(context).colorScheme;

            return LayoutBuilder(
              builder: (context, constraints) {
                return PopupMenuButton<T>(
                  padding: EdgeInsets.zero,
                  enabled: enabled,
                  initialValue: value,
                  onSelected: (T newValue) {
                    field.didChange(newValue);
                    onChanged(newValue);
                  },
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                  ),
                  offset: const Offset(0, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                  ),
                  elevation: 3,

                  // Dış görünüm (Input alanı)
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          value != null ? (labelBuilder(value) ?? '-') : 'Seçiniz',
                          style: TextStyle(
                            color: value != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withAlpha(128),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        PhosphorIcons.caretDown(),
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),

                  // Menü elemanları
                  itemBuilder: (context) => options.map((T item) {
                    return PopupMenuItem<T>(
                      value: item,
                      height: 44,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Text(
                          labelBuilder(item) ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
}
