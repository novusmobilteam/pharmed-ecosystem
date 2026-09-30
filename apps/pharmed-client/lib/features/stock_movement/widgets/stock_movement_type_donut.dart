import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/stock_movement_summary.dart';
import 'stock_movement_palette.dart';

/// Hareket tipi dağılımı: halka grafik + yüzdeli lejant.
class StockMovementTypeDonut extends StatefulWidget {
  const StockMovementTypeDonut({super.key, required this.summary});

  final StockMovementSummary summary;

  @override
  State<StockMovementTypeDonut> createState() => _StockMovementTypeDonutState();
}

class _StockMovementTypeDonutState extends State<StockMovementTypeDonut> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final byType = widget.summary.byType;
    final total = widget.summary.totalCount;

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 52,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final index = response?.touchedSection?.touchedSectionIndex;
                      final next = event.isInterestedForInteractions && index != null && index >= 0 ? index : null;
                      if (next != _touched) setState(() => _touched = next);
                    },
                  ),
                  sections: [
                    for (var i = 0; i < byType.length; i++)
                      PieChartSectionData(
                        value: byType[i].count.toDouble(),
                        color: StockMovementPalette.of(byType[i].type),
                        radius: _touched == i ? 30 : 24,
                        showTitle: false,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 200),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(total.toString(), style: MedTextStyles.numericXl()),
                  Text(context.l10n.movement_kpi_totalLabel, style: MedTextStyles.bodySm()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: MedSpacing.lg),
        for (var i = 0; i < byType.length; i++) _LegendRow(item: byType[i], total: total, highlighted: _touched == i),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item, required this.total, required this.highlighted});

  final StockMovementTypeTotal item;
  final int total;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (item.count * 100 / total);
    final color = StockMovementPalette.of(item.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.xs),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.08) : null,
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              item.type.label(context),
              style: MedTextStyles.bodySm(weight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${item.count}', style: MedTextStyles.monoMd()),
          SizedBox(
            width: 52,
            child: Text('%${percent.toStringAsFixed(0)}', textAlign: TextAlign.right, style: MedTextStyles.monoMd()),
          ),
        ],
      ),
    );
  }
}
