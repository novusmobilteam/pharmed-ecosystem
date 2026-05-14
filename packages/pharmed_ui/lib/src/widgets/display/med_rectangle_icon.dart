import 'package:flutter/material.dart';

import '../../../pharmed_ui.dart';

class MedRectangleIcon extends StatelessWidget {
  const MedRectangleIcon({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    this.size,
    required this.icon,
    this.iconSize,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Size? size;
  final double? iconSize;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size?.width ?? 42,
      height: size?.height ?? 42,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: MedRadius.mdAll),
      child: Icon(icon, size: 20, color: foregroundColor),
    );
  }
}
