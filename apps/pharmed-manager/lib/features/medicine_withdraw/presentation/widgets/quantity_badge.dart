import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class QuantityBadge extends StatelessWidget {
  const QuantityBadge({
    super.key,
    required this.totalAmount,
    required this.totalAmountLabel,
  });

  final double totalAmount;
  final String totalAmountLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = totalAmount > 0 ? theme.colorScheme.secondary.withValues(alpha: 0.1) : context.colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        totalAmountLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }
}
