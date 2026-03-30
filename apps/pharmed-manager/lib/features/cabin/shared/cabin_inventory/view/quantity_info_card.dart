import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/core.dart';

class QuantityInfoCard extends StatelessWidget {
  final CabinAssignment data;
  final double quantity;
  final CabinInventoryType type;

  /// Planlanan dolum miktarı. SADECE refillList tipinde geçilir; diğer tiplerde null bırakılır.
  final double? plannedQuantity;

  const QuantityInfoCard({
    super.key,
    required this.data,
    required this.quantity,
    required this.type,
    this.plannedQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final medicine = data.medicine;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppDimensions.cardDecoration(context).copyWith(borderRadius: BorderRadius.circular(8)),
      child: Row(
        spacing: 10,
        children: [
          // İkon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(PhosphorIcons.pill(PhosphorIconsStyle.fill), color: context.colorScheme.primary, size: 18),
          ),

          // İlaç adı + barkod
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Text(
                  medicine?.name ?? 'İsimsiz Malzeme',
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  medicine?.barcode ?? '-',
                  style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // İstatistikler — dikey ayırıcıyla ayrılmış
          _buildStatChip(context, 'Min', data.minQuantityLabel(type)),
          _buildVerticalDivider(context),
          _buildStatChip(context, 'Krit', data.critQuantityLabel(type)),
          _buildVerticalDivider(context),
          _buildStatChip(context, 'Maks', data.maxQuantityLabel(type)),
          _buildVerticalDivider(context),
          _buildStatChip(context, 'Mevcut', data.totalQuantityLabel(type), highlight: true),
          if (plannedQuantity != null) ...[
            _buildVerticalDivider(context),
            _buildStatChip(context, 'Planlanan', plannedQuantity!.formatFractional),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return SizedBox(
      height: 28,
      child: VerticalDivider(width: 1, thickness: 1, color: context.colorScheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, String value, {bool highlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 1,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? context.colorScheme.primary : context.colorScheme.onSurface,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
