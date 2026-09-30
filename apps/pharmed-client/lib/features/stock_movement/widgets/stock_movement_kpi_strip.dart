import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/stock_movement_summary.dart';
import 'stock_movement_palette.dart';

/// Toplam hareket + tip bazlı toplamlar. Tip sayısı değişken olduğu için
/// yatay kaydırılabilir.
class StockMovementKpiStrip extends StatelessWidget {
  const StockMovementKpiStrip({super.key, required this.summary});

  final StockMovementSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _KpiCard(
          label: context.l10n.movement_kpi_totalLabel,
          value: summary.totalCount.toString(),
          color: MedColors.blue,
          emphasized: true,
        ),
        for (final t in summary.byType)
          _KpiCard(label: t.type.label(context), value: t.count.toString(), color: StockMovementPalette.of(t.type)),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.color, this.emphasized = false});

  final String label;
  final String value;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: MedSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
      decoration: BoxDecoration(
        color: emphasized ? color.withValues(alpha: 0.08) : MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: MedTextStyles.numericXl().copyWith(color: color)),
          const SizedBox(height: MedSpacing.xs),
          Text(label, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
