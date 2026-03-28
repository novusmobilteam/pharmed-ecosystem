import 'package:flutter/material.dart';
import '../../../core.dart';

class DateInputField extends BaseInputField<DateTime> {
  final TextEditingController? controller;
  final void Function(DateTime date)? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget? customIcon;

  DateInputField({
    super.key,
    super.label,
    super.hintText = '',
    super.initialValue,
    super.validator,
    super.enabled = true,
    this.controller,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.customIcon,
  }) : super(
          buildInput: (context, value, field) {
            _syncControllerWithValue(controller, value);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (!field.widget.enabled) return;

                final selectedDate = await _showDatePicker(
                  context,
                  value,
                  firstDate,
                  lastDate,
                );

                if (selectedDate != null) {
                  _handleDateSelected(
                    selectedDate,
                    field,
                    controller,
                    onDateSelected,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      value != null ? value.formattedDate : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: (value != null)
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

  /// Controller ile değeri senkronize eder
  static void _syncControllerWithValue(
    TextEditingController? controller,
    DateTime? value,
  ) {
    if (controller != null && value != null) {
      final formatted = value.formattedDate;
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
  }

  /// Tarih seçici dialog'u gösterir
  static Future<DateTime?> _showDatePicker(
    BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Tarih seçildiğinde yapılacak işlemler
  static void _handleDateSelected(
    DateTime selectedDate,
    FormFieldState<DateTime> field,
    TextEditingController? controller,
    void Function(DateTime date)? onDateSelected,
  ) {
    // FormField state'ini güncelle
    field.didChange(selectedDate);

    // Controller'ı güncelle (varsa)
    if (controller != null) {
      controller.text = selectedDate.formattedDate;
    }

    // Callback'i çağır
    onDateSelected?.call(selectedDate);
  }

  /// Değeri temizleme metodu (manuel çağrılabilir)
  void clear(FormFieldState<DateTime>? fieldState) {
    // Controller'ı temizle (varsa)
    controller?.clear();

    // FormField state'ini temizle
    fieldState?.didChange(null);
  }

  /// Yeni değer atama metodu (manuel çağrılabilir)
  void setValue(
    DateTime date, {
    FormFieldState<DateTime>? fieldState,
    bool notifyCallback = true,
  }) {
    // Controller'ı güncelle (varsa)
    controller?.text = date.formattedDate;

    // FormField state'ini güncelle
    fieldState?.didChange(date);

    // Callback'i çağır (isteğe bağlı)
    if (notifyCallback) {
      onDateSelected?.call(date);
    }
  }

  /// Widget'ın mevcut değerini döndürür
  DateTime? getCurrentValue(FormFieldState<DateTime>? fieldState) {
    return fieldState?.value;
  }
}
