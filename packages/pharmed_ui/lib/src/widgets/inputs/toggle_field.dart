import 'package:flutter/material.dart';
import 'package:pharmed_ui/src/theme/med_tokens.dart';
import 'package:pharmed_ui/src/widgets/widgets.dart';

class ToggleField extends StatelessWidget {
  const ToggleField({super.key, required this.value, this.onChanged, required this.label, this.enabled = true});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4.0,
      children: [
        MedToggle(value: value, onChanged: onChanged, enabled: enabled),
        Text(label, style: MedTextStyles.bodySm().copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
