import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class OperationStatsRow extends StatelessWidget {
  const OperationStatsRow({super.key, required this.cells});

  final List<StatCellData> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: MedColors.bg,
      child: Row(
        children: [for (final c in cells) Expanded(child: _StatCell(data: c))],
      ),
    );
  }
}

class StatCellData {
  const StatCellData({required this.label, required this.value, this.valueColor, this.icon});
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.data});

  final StatCellData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(data.label, style: MedTextStyles.monoXs(color: MedColors.text3)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (data.icon != null) ...[
              Icon(data.icon, size: 18, color: data.valueColor ?? MedColors.text),
              const SizedBox(width: 6),
            ],
            Text(data.value, style: MedTextStyles.titleSm(color: data.valueColor ?? MedColors.text)),
          ],
        ),
      ],
    );
  }
}
