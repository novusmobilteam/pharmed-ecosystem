import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Onay kutusu + etiket satırı.
///
/// Tek bir boolean değeri temsil eder. [MedCheckbox] ile aynı
/// API'yi sunar ancak yanına metin etiketi ekler.
///
/// ```dart
/// CheckboxField(
///   value: _accepted,
///   label: 'Şartları kabul ediyorum',
///   onChanged: (v) => setState(() => _accepted = v),
/// )
/// ```
class CheckboxField extends StatelessWidget {
  const CheckboxField({
    super.key,
    required this.value,
    this.onChanged,
    required this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: MedSpacing.xs,
      children: [
        MedCheckbox(value: value, onChanged: onChanged, enabled: enabled),
        Text(label, style: MedTextStyles.bodySm()),
      ],
    );
  }
}
