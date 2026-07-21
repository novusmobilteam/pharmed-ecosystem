part of 'cabin_temperature_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinTemperatureReportNotifier>(
      builder: (context, notifier, _) {
        return MedTable(
          data: notifier.items,
          isLoading: notifier.isFetching,
          enableExcel: true,
          enableSearch: true,
          enablePDF: true,
          enableDateFilter: true,

          // Pagination
          enablePagination: true,
          pageSize: notifier.pageSize,
          currentPage: notifier.currentPage,
          serverTotalCount: notifier.totalCount,
          onPageChanged: notifier.setPage,

          // Filter & Search
          initialDateRange: notifier.dateRange,
          onDateRangeChanged: notifier.setDateRange,
          onSearchChanged: notifier.search,

          // Kategori
          categories: notifier.tableCategories,
          selectedCategoryId: notifier.selectedCategoryId,
          onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
          categoryTitle: context.l10n.report_stationsCategoryTitle,
          toolbarActions: [
            MedRectangleIconButton(
              tooltip: !notifier.showOutOfRange
                  ? context.l10n.cabinTemperature_action_showOutOfRange
                  : context.l10n.cabinTemperature_action_showAll,
              iconData: !notifier.showOutOfRange ? PhosphorIcons.bellRinging() : PhosphorIcons.bell(),
              color: MedColors.amberLight,
              iconColor: MedColors.amber,
              onPressed: notifier.toggleOutOfRange,
            ),
          ],

          columnDefs: _buildColumnDefs(context),
        );
      },
    );
  }
}

List<TableColumnDef<CabinTemperatureValue>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.cabinTemperature_table_dateColumn,
    displayValue: (item) => item.createdDate?.formattedDateTime,
  ),
  TableColumnDef(title: context.l10n.cabinTemperature_table_cabinColumn, displayValue: (item) => item.cabinName),
  TableColumnDef(
    title: context.l10n.cabinTemperature_table_insideTempColumn,
    displayValue: (item) => '${item.insideTemperature?.toStringAsFixed(2)}°C',
  ),
  TableColumnDef(
    title: context.l10n.cabinTemperature_table_outsideTempColumn,
    displayValue: (item) => '${item.outsideTemperature?.toStringAsFixed(2)}°C',
  ),
  TableColumnDef(
    title: context.l10n.cabinTemperature_table_humidityColumn,
    displayValue: (item) => '${item.humidity?.toStringAsFixed(2)}%',
  ),
];
