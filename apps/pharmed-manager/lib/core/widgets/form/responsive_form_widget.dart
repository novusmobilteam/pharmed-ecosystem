import 'package:flutter/material.dart';

import 'form_field_metadata.dart';
import 'generic_form_widget.dart';

class ResponsiveFormWidget extends StatelessWidget {
  final List<FormFieldMetadata> fields;
  final Map<String, dynamic> formValues;
  final void Function(String key, dynamic value) onFieldChanged;
  final Map<String, String?> errors;
  final double spacing;
  final bool enabled;
  final int maxColumns;

  const ResponsiveFormWidget({
    super.key,
    required this.fields,
    required this.formValues,
    required this.onFieldChanged,
    required this.errors,
    this.spacing = 16.0,
    this.enabled = true,
    this.maxColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = _calculateColumns(screenWidth);

    if (columns == 1) {
      return GenericFormWidget(
        fields: fields,
        formValues: formValues,
        onFieldChanged: onFieldChanged,
        errors: errors,
        spacing: spacing,
        enabled: enabled,
      );
    }

    return _buildGridLayout(columns);
  }

  int _calculateColumns(double screenWidth) {
    if (screenWidth > 1600) return maxColumns.clamp(1, 4);
    if (screenWidth > 1200) return maxColumns.clamp(1, 3);
    if (screenWidth > 800) return maxColumns.clamp(1, 2);
    return 1;
  }

  Widget _buildGridLayout(int columns) {
    // Alanları flex değerlerine göre grupla
    final rows = _groupFieldsIntoRows(columns);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: entry.key == rows.length - 1 ? 0 : spacing),
          child: _buildRow(entry.value),
        );
      }).toList(),
    );
  }

  List<List<FormFieldMetadata>> _groupFieldsIntoRows(int columns) {
    final rows = <List<FormFieldMetadata>>[];
    var currentRow = <FormFieldMetadata>[];
    var currentRowFlex = 0;

    for (final field in fields) {
      final fieldFlex = field.layout.flex;

      // breakAfter kontrolü
      if (field.layout.breakAfter && currentRow.isNotEmpty) {
        rows.add(List.from(currentRow));
        currentRow.clear();
        currentRowFlex = 0;
      }

      // Yeni satıra geçme kontrolü
      if (currentRowFlex + fieldFlex > columns && currentRow.isNotEmpty) {
        rows.add(List.from(currentRow));
        currentRow.clear();
        currentRowFlex = 0;
      }

      currentRow.add(field);
      currentRowFlex += fieldFlex;

      // Satır tam dolduysa
      if (currentRowFlex == columns) {
        rows.add(List.from(currentRow));
        currentRow.clear();
        currentRowFlex = 0;
      }
    }

    // Kalan field'lar
    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  Widget _buildRow(List<FormFieldMetadata> rowFields) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowFields.map((field) {
        return Expanded(
          flex: field.layout.flex,
          child: Padding(
            padding: EdgeInsets.only(
              right: rowFields.last == field ? 0 : spacing,
            ),
            child: GenericFormWidget(
              fields: [field],
              formValues: formValues,
              onFieldChanged: onFieldChanged,
              errors: errors,
              spacing: 0,
              enabled: enabled,
            ),
          ),
        );
      }).toList(),
    );
  }
}
