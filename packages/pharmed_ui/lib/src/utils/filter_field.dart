import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Filtre popup'ında gösterilecek tek bir alanı tanımlayan taban sınıf.
/// PatientListPanel (veya başka bir liste paneli) bu alanların NE olduğunu
/// bilmez — sadece render eder ve değişikliği anahtar bazlı toplar.
abstract class FilterField<T> {
  const FilterField({required this.key, required this.label, required this.initialValue, required this.defaultValue});

  /// Sonuç map'inde bu alanı bulmak için kullanılan anahtar (ör. 'viewType').
  final String key;
  final String? label;

  /// Dialog açıldığında gösterilecek değer — çağıran taraf her rebuild'de
  /// notifier'ın o anki state'inden geçirir (ör. ready.selectedService).
  final T initialValue;

  /// "Filtre uygulanmamış" kabul edilen değer. Chip satırında bu değere eşit
  /// olan alanlar gösterilmez; X'e basınca alan bu değere geri döner.
  final T defaultValue;

  /// currentValue/onChanged dynamic — dialog tarafı tüm alanları tek bir
  /// listede tuttuğu için generic T dialog seviyesinde erişilemez;
  /// cast işlemi her alt sınıfın kendi buildInput'unda yapılır.
  Widget buildInput(BuildContext context, dynamic currentValue, ValueChanged<dynamic> onChanged);

  bool isActive(dynamic value) => value != defaultValue;

  String activeLabel(dynamic value);

  /// false ise bu alan aktif filtre chip satırında HİÇ gösterilmez —
  /// binary toggle'lar gibi "kapatılabilir" değil, sadece "değiştirilebilir"
  /// alanlar için. Varsayılan true.
  bool get isClearable => true;
}

class SegmentedFilterField<T> extends FilterField<T> {
  const SegmentedFilterField({
    required super.key,
    super.label,
    required super.initialValue,
    required super.defaultValue,
    required this.options,
    required this.labelBuilder,
  });

  final List<T> options;
  final String Function(T) labelBuilder;

  @override
  Widget buildInput(BuildContext context, dynamic currentValue, ValueChanged<dynamic> onChanged) {
    final value = currentValue as T;
    return MedSegmentedButton(
      selectedIndex: options.indexOf(value),
      onChanged: (i) => onChanged(options[i]),
      labels: options.map(labelBuilder).toList(),
    );
  }

  @override
  String activeLabel(dynamic value) => labelBuilder(value as T);

  @override
  bool get isClearable => false;
}

class DropdownFilterField<T> extends FilterField<T> {
  const DropdownFilterField({
    required super.key,
    super.label,
    required super.initialValue,
    required super.defaultValue,
    required this.options,
    required this.labelBuilder,
  });

  final List<T> options;
  final String? Function(T?) labelBuilder;

  @override
  Widget buildInput(BuildContext context, dynamic currentValue, ValueChanged<dynamic> onChanged) {
    return MedDropdownInputField<T>(
      options: options,
      onChanged: onChanged,
      labelBuilder: labelBuilder,
      initialValue: currentValue as T?,
    );
  }

  @override
  String activeLabel(dynamic value) => labelBuilder(value as T) ?? '-';
}

class ToggleFilterField extends FilterField<bool> {
  const ToggleFilterField({
    required super.key,
    required super.label,
    required super.initialValue,
    required super.defaultValue,
    required this.trueLabel,
    required this.falseLabel,
  });

  final String trueLabel;
  final String falseLabel;

  @override
  Widget buildInput(BuildContext context, dynamic currentValue, ValueChanged<dynamic> onChanged) {
    final value = currentValue as bool;
    return MedToggleField(
      showBorder: true,
      label: value ? trueLabel : falseLabel,
      value: value,
      onChanged: (_) => onChanged(!value),
      textStyle: MedTextStyles.bodyLg().copyWith(
        fontWeight: FontWeight.bold,
        color: value ? MedColors.blue : MedColors.text,
      ),
    );
  }

  @override
  String activeLabel(dynamic value) => (value as bool) ? trueLabel : falseLabel;

  @override
  bool get isClearable => false;
}

class ChipGroupFilterField<T> extends FilterField<T> {
  const ChipGroupFilterField({
    required super.key,
    required super.label,
    required super.initialValue,
    required super.defaultValue,
    required this.options,
    required this.labelBuilder,
  });

  final List<T> options;
  final String Function(T) labelBuilder;

  @override
  Widget buildInput(BuildContext context, dynamic currentValue, ValueChanged<dynamic> onChanged) {
    return MedFilterChipGroup<T>(
      options: options,
      selected: currentValue as T,
      onChanged: onChanged,
      labelBuilder: labelBuilder,
    );
  }

  @override
  String activeLabel(dynamic value) => labelBuilder(value as T);
}
