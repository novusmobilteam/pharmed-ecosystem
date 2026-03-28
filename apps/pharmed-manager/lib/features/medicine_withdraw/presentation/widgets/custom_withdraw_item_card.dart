import 'package:flutter/material.dart';
import 'selection_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../domain/entity/withdraw_item.dart';
import 'quantity_badge.dart';

class CustomWithdrawItemCard extends StatelessWidget {
  final WithdrawItem item;
  final bool isCompleted;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomWithdrawItemCard({
    super.key,
    required this.item,
    required this.isCompleted,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color cardColor = isCompleted
        ? Colors.green.withAlpha(60)
        : isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surface;

    Color borderColor = isCompleted
        ? Colors.green.withAlpha(120)
        : isSelected
            ? theme.colorScheme.primary
            : theme.dividerColor.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SelectionIcon(
                isCompleted: isCompleted,
                isSelected: isSelected,
                totalAmount: item.dosePiece ?? 0.0,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.medicine?.name ?? '-',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected && !isCompleted ? colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _infoRow(context, PhosphorIcons.barcode(), 'Barkod: ${item.medicine?.barcode}'),
                    if (!isCompleted)
                      _infoRow(
                        context,
                        PhosphorIcons.clock(),
                        'Saat: ${item.prescriptionItem?.time?.formattedTime ?? '--:--'}',
                      ),
                    if (isCompleted) ...[
                      SizedBox(height: 12),
                      _infoRow(
                        context,
                        PhosphorIcons.user(),
                        'Uygulayan: ${item.prescriptionItem?.applicationUser?.fullName ?? '-'}',
                        iconColor: Colors.green,
                      ),
                      _infoRow(
                        context,
                        PhosphorIcons.calendarCheck(),
                        'Tarih: ${item.prescriptionItem?.applicationDate?.formattedDate}-${item.prescriptionItem?.applicationDate?.formattedTime} ',
                        iconColor: Colors.green,
                      ),
                    ],
                  ],
                ),
              ),
              QuantityBadge(
                totalAmount: item.totalAmount,
                totalAmountLabel: item.totalAmountLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? Theme.of(context).hintColor),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
