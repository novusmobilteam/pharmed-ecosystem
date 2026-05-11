import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Açma/kapama anahtarı + kalın etiket satırı.
///
/// [MedToggle] ile aynı API'yi sunar ancak yanına etiket ekler.
///
/// ```dart
/// ToggleField(
///   value: _isActive,
///   label: 'Aktif',
///   onChanged: (v) => setState(() => _isActive = v),
/// )
/// ```
class ToggleField extends StatelessWidget {
  const ToggleField({
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
        MedToggle(value: value, onChanged: onChanged, enabled: enabled),
        Text(
          label,
          style: MedTextStyles.bodySm(weight: FontWeight.w700),
        ),
      ],
    );
  }
}
