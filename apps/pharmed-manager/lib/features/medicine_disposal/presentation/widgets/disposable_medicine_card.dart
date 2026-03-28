import 'package:flutter/material.dart';
import '../../../../core/core.dart';

import '../../../medicine/domain/entity/medicine.dart';
import '../../../prescription/domain/entity/prescription_item.dart';

class DisposableMedicineCard extends StatelessWidget {
  final PrescriptionItem item;
  final VoidCallback? onTap;
  final bool isSelected;

  const DisposableMedicineCard({
    super.key,
    required this.item,
    this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicine = item.medicine;
    final displayDate = item.applicationDate;
    final appUser = item.applicationUser;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: İlaç İsmi ve Dozaj
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine?.name ?? 'Bilinmeyen İlaç',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Barkod: ${medicine?.barcode ?? '-'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDoseBadge(theme, medicine),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(
                height: 1,
                color: theme.dividerColor,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(
                  context,
                  'Alım Tarihi',
                  '${displayDate?.formattedDate ?? "--"} ${displayDate?.formattedTime ?? "--"}',
                ),
                _infoChip(
                  context,
                  'Alan Kişi',
                  appUser?.fullName ?? '-',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseBadge(ThemeData theme, Medicine? medicine) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '${item.dosePiece?.formatFractional}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            medicine?.operationUnit ?? 'Adet',
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, String title, String label) {
    return Flexible(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '$title : $label',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
