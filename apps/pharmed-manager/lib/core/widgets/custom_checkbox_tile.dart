import 'package:flutter/material.dart';

import '../core.dart';

class CustomCheckboxTile extends StatelessWidget {
  const CustomCheckboxTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        CustomCheckbox(value: value, onTap: onTap, enabled: enabled),
        Text(label, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({super.key, required this.value, required this.onTap, this.enabled = true});

  final bool value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final double borderSize = 25;
    final double checkboxSize = value ? (borderSize - 7) : 0;
    return GestureDetector(
      onTap: () {
        enabled ? onTap() : null;
      },
      child: Container(
        alignment: Alignment.center,
        width: borderSize,
        height: borderSize,
        decoration: BoxDecoration(
          border: Border.all(color: value ? context.colorScheme.primary : Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: checkboxSize,
          height: checkboxSize,
          decoration: BoxDecoration(color: context.colorScheme.primary, borderRadius: BorderRadius.circular(4.0)),
        ),
      ),
    );
  }
}
