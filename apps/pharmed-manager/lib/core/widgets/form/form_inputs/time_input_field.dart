import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core.dart';

class TimeInputField extends BaseInputField<TimeOfDay> {
  final TextEditingController? controller;
  final void Function(TimeOfDay? time)? onTimeSelected;
  final Widget? customIcon;
  final String? dayHint;

  TimeInputField({
    super.key,
    required super.label,
    super.hintText = '',
    super.initialValue,
    super.validator,
    super.enabled = true,
    this.controller,
    this.onTimeSelected,
    this.customIcon,
    this.dayHint,
  }) : super(
          buildInput: (context, value, field) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncControllerWithValue(context, controller, value);
            });

            return Row(
              children: [
                // Saat Seçiciyi Açan Alan (Genişleyen kısım)
                Expanded(
                  child: InkWell(
                    // GestureDetector yerine InkWell görsel geri bildirim verir
                    onTap: () async {
                      if (!field.widget.enabled) return;

                      final selectedTime = await _showTimePicker(context, value, dayHint);

                      if (selectedTime != null && context.mounted) {
                        _handleTimeSelected(
                          context,
                          selectedTime,
                          field,
                          controller,
                          onTimeSelected,
                        );
                      }
                    },
                    child: Text(
                      value != null ? value.format(context) : (hintText ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: (value != null)
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Temizleme İkonu (Sadece değer varsa ve alan aktifse gözükür)
                if (value != null && enabled)
                  InkWell(
                    child: Icon(
                      PhosphorIcons.minusCircle(),
                      size: 16,
                    ),
                    onTap: () {
                      field.didChange(null);
                      controller?.clear();
                      onTimeSelected?.call(null);
                    },
                  ),
              ],
            );
          },
        );

  /// Controller ile değeri senkronize eder
  static void _syncControllerWithValue(
    BuildContext context,
    TextEditingController? controller,
    TimeOfDay? value,
  ) {
    if (controller != null) {
      // Değer null ise boş string, değilse formatlı saat
      final formatted = value != null ? value.format(context) : '';

      // Eğer controller'daki yazı, gelen değerden farklıysa güncelle
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
  }

  /// Saat seçici dialog'u gösterir
  static Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    TimeOfDay? initialTime,
    String? dayHint,
  ) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: dayHint != null ? '$dayHint için saat seçin' : 'Saat seçin',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
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

  /// Saat seçildiğinde yapılacak işlemler
  static void _handleTimeSelected(
    BuildContext context,
    TimeOfDay selectedTime,
    FormFieldState<TimeOfDay> field,
    TextEditingController? controller,
    void Function(TimeOfDay time)? onTimeSelected,
  ) {
    // FormField state'ini güncelle
    field.didChange(selectedTime);

    // Controller'ı güncelle (varsa)
    if (controller != null) {
      controller.text = selectedTime.format(context);
    }

    // Callback'i çağır
    onTimeSelected?.call(selectedTime);
  }

  /// Değeri temizleme metodu
  void clear(FormFieldState<TimeOfDay>? fieldState) {
    controller?.clear();
    fieldState?.didChange(null);
  }

  /// Yeni değer atama metodu
  void setValue(
    BuildContext context,
    TimeOfDay time, {
    FormFieldState<TimeOfDay>? fieldState,
    bool notifyCallback = true,
  }) {
    controller?.text = time.format(context);
    fieldState?.didChange(time);

    if (notifyCallback) {
      onTimeSelected?.call(time);
    }
  }

  /// Widget'ın mevcut değerini döndürür
  TimeOfDay? getCurrentValue(FormFieldState<TimeOfDay>? fieldState) {
    return fieldState?.value;
  }
}

/// TIME INPUT FIELD YARDIMCI METODLARI
extension TimeInputFieldHelpers on TimeInputField {
  /// Widget'ı GlobalKey ile kullanmak için yardımcı metod
  static TimeInputField withKey({
    required GlobalKey<FormFieldState<TimeOfDay>> fieldKey,
    required String label,
    TextEditingController? controller,
    void Function(TimeOfDay? time)? onTimeSelected,
    TimeOfDay? initialValue,
    String? Function(TimeOfDay? value)? validator,
  }) {
    return TimeInputField(
      key: fieldKey,
      label: label,
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      onTimeSelected: onTimeSelected,
    );
  }

  /// Form'daki saat alanlarını toplu temizleme
  static void clearAllFields(List<FormFieldState<TimeOfDay>?> fieldStates) {
    for (final field in fieldStates) {
      field?.didChange(null);
    }
  }
}
