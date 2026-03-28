import 'package:flutter/material.dart';
import 'package:pharmed_core/src/result/result.dart';

import '../../core.dart';
import 'form_field_metadata.dart';

/// GENERIC FORM WIDGET - BaseInputField ENTEGRASYONLU
///
/// FormFieldMetadata nesnelerini uygun BaseInputField türevlerine dönüştürür.
/// Tüm form alanları için tutarlı ve tip güvenli bir yapı sağlar.
///
/// ÖZELLİKLER:
/// 1. FormFieldMetadata → BaseInputField otomatik dönüşüm
/// 2. Tüm field tipleri için destek (text, dropdown, dialog, date, vs.)
/// 3. Controller opsiyonel desteği
/// 4. Validasyon ve hata gösterimi
/// 5. Responsive tasarım hazırlığı
///
/// KULLANIM:
/// ```dart
/// GenericFormWidget(
///   fields: CabinFormMetadata.allFields,
///   formValues: viewModel.formValues,
///   onFieldChanged: (key, value) => viewModel.updateFormField(key, value),
///   errors: viewModel.formErrors,
/// )
/// ```

// lib/core/widgets/form/generic_form_widget.dart

/// GENERIC FORM WIDGET - Mevcut BaseInputField Yapısıyla Uyumlu
///
/// FormFieldMetadata'yı mevcut BaseInputField türevlerine dönüştürür.
/// Minimum değişiklik, maksimum uyumluluk.

class GenericFormWidget extends StatelessWidget {
  final List<FormFieldMetadata> fields;
  final Map<String, dynamic> formValues;
  final void Function(String key, dynamic value) onFieldChanged;
  final Map<String, String?> errors;
  final double spacing;
  final bool enabled;

  const GenericFormWidget({
    super.key,
    required this.fields,
    required this.formValues,
    required this.onFieldChanged,
    required this.errors,
    this.spacing = 16.0,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildFieldWidgets(context));
  }

  List<Widget> _buildFieldWidgets(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final isLast = i == fields.length - 1;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0.0 : spacing),
          child: _buildFieldWidget(context, field),
        ),
      );
    }

    return widgets;
  }

  Widget _buildFieldWidget(BuildContext context, FormFieldMetadata field) {
    final currentValue = formValues[field.key];
    final error = errors[field.key];
    final isFieldEnabled = enabled && field.enabled;

    TextEditingController? createController(dynamic value) {
      if (value == null) return null;
      return TextEditingController(text: value.toString());
    }

    switch (field.fieldType) {
      case FieldType.text:
        return TextInputField(
          label: field.label,
          initialValue: currentValue?.toString(),
          validator: (_) => field.validator?.call(currentValue) ?? error,
          enabled: isFieldEnabled,
          onChanged: (value) => onFieldChanged(field.key, value),
        );

      case FieldType.number:
        return TextInputField(
          label: field.label,
          initialValue: currentValue?.toString(),
          validator: (_) => field.validator?.call(currentValue) ?? error,
          enabled: isFieldEnabled,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = int.tryParse(value ?? '') ?? double.tryParse(value ?? '');
            onFieldChanged(field.key, numValue);
          },
        );

      case FieldType.dropdown:
        final options = field.additionalData as List? ?? [];

        return DropdownInputField(
          label: field.label,
          options: options,
          labelBuilder: (item) => item?.toString() ?? '',
          onChanged: (value) => onFieldChanged(field.key, value),
          initialValue: currentValue,
          validator: (_) => field.validator?.call(currentValue) ?? error,
          enabled: isFieldEnabled,
        );

      case FieldType.dialog:
        // Dialog için additionalData'da future ve labelBuilder beklenir
        final additionalData = field.additionalData as Map<String, dynamic>?;

        if (additionalData != null) {
          final future = additionalData['future'] as Future<Result<ApiResponse<List<Selectable>>>> Function()?;
          final labelBuilder = additionalData['labelBuilder'] as String? Function(Selectable?)?;

          if (future != null && labelBuilder != null) {
            return DialogInputField(
              label: field.label,
              future: future,
              labelBuilder: labelBuilder,
              onSelected: (value) => onFieldChanged(field.key, value),
              initialValue: currentValue as Selectable?,
              validator: (_) => field.validator?.call(currentValue) ?? error,
              enabled: isFieldEnabled,
            );
          }
        }

        // Fallback: Dropdown kullan
        final options = field.additionalData as List? ?? [];
        return DropdownInputField(
          label: field.label,
          options: options,
          labelBuilder: (item) => item?.toString() ?? '',
          onChanged: (value) => onFieldChanged(field.key, value),
          initialValue: currentValue,
          validator: (_) => field.validator?.call(currentValue) ?? error,
          enabled: isFieldEnabled,
        );

      case FieldType.date:
        // DateInputField için controller oluştur
        final controller = createController(currentValue);

        return DateInputField(
          label: field.label,
          controller: controller ?? TextEditingController(),
          onDateSelected: (date) => onFieldChanged(field.key, date),
          // firstDate: additionalData?['firstDate'] as DateTime?,
          // lastDate: additionalData?['lastDate'] as DateTime?,
        );

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: currentValue is bool ? currentValue : false,
          onChanged: isFieldEnabled ? (value) => onFieldChanged(field.key, value) : null,
          subtitle: error != null ? Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
        );

      default:
        // Diğer tipler için fallback
        return TextInputField(
          label: field.label,
          initialValue: currentValue?.toString(),
          validator: (_) => field.validator?.call(currentValue) ?? error,
          enabled: isFieldEnabled,
          onChanged: (value) => onFieldChanged(field.key, value),
        );
    }
  }
}

/// BASİT FORM WIDGET HELPER
class SimpleFormHelper {
  /// Form değerlerini düz metin olarak gösterir (debug için)
  static String formatFormValues(Map<String, dynamic> formValues) {
    final buffer = StringBuffer();
    buffer.writeln('=== FORM DEĞERLERİ ===');

    formValues.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    return buffer.toString();
  }

  /// Boş alanları kontrol eder
  static List<String> findEmptyFields(List<FormFieldMetadata> fields, Map<String, dynamic> formValues) {
    final emptyFields = <String>[];

    for (final field in fields) {
      if (field.isRequired) {
        final value = formValues[field.key];
        if (value == null || value.toString().isEmpty) {
          emptyFields.add(field.label);
        }
      }
    }

    return emptyFields;
  }
}
