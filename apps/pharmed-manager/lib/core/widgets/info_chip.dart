import 'package:flutter/material.dart';

import '../core.dart';

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, this.info, this.backgroundColor, this.foregroundColor});

  final String? info;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (info == null) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.primary,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        info!,
        textAlign: TextAlign.center,
        style: context.textTheme.labelSmall?.copyWith(
          color: foregroundColor ?? context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
