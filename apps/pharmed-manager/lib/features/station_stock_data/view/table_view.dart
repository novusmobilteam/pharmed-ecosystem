part of 'station_stock_data_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final StationStockDataNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          flex: 6,
          child: MedTable<MedicineAssignment>(
            data: notifier.assignments,
            //isLoading: notifier.isFetching,
            columnDefs: _buildColumnDefs(context),
            categories: notifier.sideCategories,
            selectedCategoryId: notifier.selectedCategoryId,
            onCategoryChanged: notifier.selectCategory,
          ),
        ),
        Expanded(
          flex: 2,
          // Salt-okunur: hücre seçimi ve tıklama aksiyonu yok.
          child: CabinAssignmentMiniPanel(
            groups: notifier.groups,
            assignments: notifier.assignments,
            selectedUnitId: null,
            onCellTap: (unit, {required isEmpty}) {},
          ),
        ),
      ],
    );
  }
}

List<TableColumnDef<MedicineAssignment>> _buildColumnDefs(BuildContext context) {
  final l10n = context.l10n;
  // TR: %50, EN: 50%, FR: 50 % — yerel ayara göre biçimlenir.
  final percentFormat = NumberFormat.percentPattern(Localizations.localeOf(context).toString());

  return [
    TableColumnDef(title: l10n.stationStock_drugColumn, displayValue: (item) => item.medicine?.name),
    TableColumnDef(title: l10n.stationStock_stockColumn, displayValue: (item) => item.quantityLabel(item.currentStock)),
    TableColumnDef(
      title: l10n.stationStock_fillRateColumn,
      displayValue: (item) {
        final ratio = item.fillRatio;
        return ratio == null ? '-' : percentFormat.format(ratio);
      },
    ),
    TableColumnDef(title: l10n.stationStock_minColumn, displayValue: (item) => item.quantityLabel(item.minQuantity)),
    TableColumnDef(
      title: l10n.stationStock_criticalColumn,
      displayValue: (item) => item.quantityLabel(item.criticalQuantity),
    ),
    TableColumnDef(title: l10n.stationStock_maxColumn, displayValue: (item) => item.quantityLabel(item.maxQuantity)),
  ];
}
