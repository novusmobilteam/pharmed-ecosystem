import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MedSelectableCard extends StatelessWidget {
  const MedSelectableCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.margin = const EdgeInsets.only(bottom: 4),
  });

  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isSelected ? MedColors.blueLight : MedColors.surface,
        borderRadius: radius,
        border: Border.all(color: isSelected ? MedColors.blue.withValues(alpha: 0.4) : MedColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
