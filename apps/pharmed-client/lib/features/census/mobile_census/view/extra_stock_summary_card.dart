part of 'mobile_census_dialog.dart';

class _ExtraStockSummaryCard extends StatelessWidget {
  const _ExtraStockSummaryCard({required this.extraStocks, required this.onRemove});

  final List<CensusExtraStock> extraStocks;
  final ValueChanged<String> onRemove; // localId

  @override
  Widget build(BuildContext context) {
    if (extraStocks.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.amberLight.withAlpha(120),
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.census_extra_stock_summary_title,
            style: MedTextStyles.titleSm().copyWith(color: MedColors.amber),
          ),
          const SizedBox(height: MedSpacing.sm),
          ...extraStocks.map((stock) => _ExtraStockRow(stock: stock, onRemove: () => onRemove(stock.localId))),
        ],
      ),
    );
  }
}

class _ExtraStockRow extends StatelessWidget {
  const _ExtraStockRow({required this.stock, required this.onRemove});

  final CensusExtraStock stock;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MedSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stock.medicine.name ?? '—', style: MedTextStyles.titleSm()),
              Text(
                '${stock.quantity.formatFractional} ${stock.medicine.operationUnit}',
                style: MedTextStyles.bodyMd(color: MedColors.text2, weight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(width: MedSpacing.sm),
          InkWell(
            onTap: onRemove,
            borderRadius: MedRadius.smAll,
            child: Padding(
              padding: const EdgeInsets.all(MedSpacing.xs),
              child: Icon(PhosphorIcons.xCircle(), size: 18, color: MedColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
