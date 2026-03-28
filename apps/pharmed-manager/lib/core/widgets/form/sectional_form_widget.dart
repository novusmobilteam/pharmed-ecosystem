import 'package:flutter/material.dart';

import 'form_section.dart';
import 'responsive_form_widget.dart';

class SectionalFormWidget extends StatelessWidget {
  final List<FormSection> sections;
  final Map<String, dynamic> formValues;
  final void Function(String key, dynamic value) onFieldChanged;
  final Map<String, String?> errors;
  final double sectionSpacing;

  const SectionalFormWidget({
    super.key,
    required this.sections,
    required this.formValues,
    required this.onFieldChanged,
    required this.errors,
    this.sectionSpacing = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.asMap().entries.map((entry) {
        final section = entry.value;
        final isLast = entry.key == sections.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : sectionSpacing),
          child: _buildSection(context, section),
        );
      }).toList(),
    );
  }

  Widget _buildSection(BuildContext context, FormSection section) {
    return Container(
      decoration: section.showBorder
          ? BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      padding: section.padding,
      child: Column(
        crossAxisAlignment: section.crossAxisAlignment,
        children: [
          if (section.title != null) ...[
            Text(
              section.title!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (section.description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 4),
                child: Text(
                  section.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
            const SizedBox(height: 16),
          ],
          ResponsiveFormWidget(
            fields: section.fields,
            formValues: formValues,
            onFieldChanged: onFieldChanged,
            errors: errors,
            spacing: 12,
            maxColumns: section.columns,
          ),
        ],
      ),
    );
  }
}
