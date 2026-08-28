import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MedQuantityValueCard extends StatelessWidget {
  const MedQuantityValueCard({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.suffix,
    this.density = MedValueCardDensity.compact,
  });

  final String label;
  final double? value;

  /// null → salt-okunur: dokunma hiçbir şey açmaz.
  final ValueChanged<double>? onChanged;
  final String? suffix;
  final MedValueCardDensity density;

  bool get _readOnly => onChanged == null;

  static double _parseQty(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  Future<void> _open(BuildContext context) async {
    final callback = onChanged;
    if (callback == null) return;
    final result = await showNumpadView(context, initialValue: value.formatFractional);
    if (result != null) callback(_parseQty(result));
  }

  @override
  Widget build(BuildContext context) {
    return MedValueCard(
      density: density,
      label: label,
      value: value.formatFractional,
      placeholder: (value ?? 0) == 0,
      suffix: suffix,
      onTap: _readOnly ? () {} : () => _open(context),
    );
  }
}

class MedDateValueCard extends StatelessWidget {
  const MedDateValueCard({
    super.key,
    required this.label,
    required this.date,
    this.onChanged,
    this.hasError = false,
    this.density = MedValueCardDensity.compact,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?>? onChanged;
  final bool hasError;
  final MedValueCardDensity density;

  bool get _readOnly => onChanged == null;

  Future<void> _open(BuildContext context) async {
    final callback = onChanged;
    if (callback == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: date.clampedForPicker(),
      firstDate: todayDateOnly(),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) callback(picked);
  }

  @override
  Widget build(BuildContext context) {
    return MedValueCard(
      density: density,
      label: label,
      value: date == null ? context.l10n.dateField_placeholder : date!.formattedDate,
      placeholder: date == null,
      hasError: hasError,
      trailingIcon: PhosphorIcons.calendarBlank(),
      onTap: _readOnly ? () {} : () => _open(context),
    );
  }
}
