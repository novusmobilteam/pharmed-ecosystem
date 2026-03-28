import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

class DateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?) onStartDateSelected;
  final Function(DateTime?) onEndDateSelected;
  final VoidCallback? onClearFilters;
  final bool showClearButton;

  const DateRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    this.onClearFilters,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        SizedBox(
          width: 300,
          child: _DatePickerField(
            date: startDate,
            label: 'Başlangıç Tarihi',
            onDateSelected: onStartDateSelected,
          ),
        ),
        SizedBox(
          width: 300,
          child: _DatePickerField(
            date: endDate,
            label: 'Bitiş Tarihi',
            onDateSelected: onEndDateSelected,
          ),
        ),
        if (showClearButton && (startDate != null || endDate != null))
          IconButton(
            onPressed: onClearFilters,
            icon: Icon(PhosphorIcons.funnelX()),
            tooltip: 'Filtreleri Temizle',
          ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final String label;
  final Function(DateTime?) onDateSelected;

  const _DatePickerField({
    required this.date,
    required this.label,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withAlpha(120)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 8,
          children: [
            Icon(PhosphorIcons.calendarBlank()),
            Expanded(
              child: Text(
                date != null ? date.formattedDate : label,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    onDateSelected(selectedDate);
  }
}
