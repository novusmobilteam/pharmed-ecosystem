part of 'mobile_census_dialog.dart';

class _ExtraStockSummaryCard extends StatelessWidget {
  const _ExtraStockSummaryCard({required this.extraStocks, required this.onRemove});

  final List<CensusExtraStock> extraStocks;
  final ValueChanged<String> onRemove; // localId

  @override
  Widget build(BuildContext context) {
    if (extraStocks.isEmpty) return const SizedBox.shrink();

    return OperationBanner(
      tone: BannerTone.warning,
      icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
      title: context.l10n.census_extra_stock_summary_title,
      message: context.l10n.census_extraStockSummaryMessage,
      child: Column(
        children: extraStocks
            .map((stock) => _ExtraStockRow(stock: stock, onRemove: () => onRemove(stock.localId)))
            .toList(),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.mdAll),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stock.medicine.name ?? '—',
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                  ),
                  Text(
                    '${stock.quantity.formatFractional} ${stock.medicine.operationUnitLocalized(context)}',
                    style: MedTextStyles.bodySm(color: MedColors.text2),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onRemove,
              borderRadius: MedRadius.smAll,
              child: Padding(
                padding: const EdgeInsets.all(MedSpacing.xs),
                child: Icon(PhosphorIcons.xCircle(), size: 18, color: MedColors.text3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
