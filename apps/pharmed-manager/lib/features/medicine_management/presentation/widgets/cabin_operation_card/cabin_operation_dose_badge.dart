import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

import '../../../domain/entity/cabin_operation_item.dart';

/// İşlem tipinden bağımsız doz rozetini gösterir.
/// Alım, iade ve fire/imha kartlarında ortak kullanılır.
class CabinOperationDoseBadge extends StatelessWidget {
  final CabinOperationItem item;

  const CabinOperationDoseBadge({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.doseLabel.split(' ').first,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
          Text(item.medicine?.operationUnit ?? 'Adet', style: context.textTheme.labelSmall?.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class CabinOperationInfoChip extends StatelessWidget {
  final String title;
  final String value;

  const CabinOperationInfoChip({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            '$title : $value',
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
