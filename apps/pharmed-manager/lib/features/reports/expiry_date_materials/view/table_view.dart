part of 'expiry_date_materials_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final ExpiryDateMaterialsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<CabinStock>(
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

      // Tarih (miadDate) & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      onSearchChanged: notifier.search,

      // İstasyon (tekli seçim)
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.report_stationsCategoryTitle,

      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
      columnDefs: _buildColumnDefs(context),
    );
  }
}

/// Kolonlar SKT'si Geçmiş Malzemeler raporuyla aynı (aynı CabinStock modeli,
/// aynı başlık anahtarları).
List<TableColumnDef<CabinStock>> _buildColumnDefs(BuildContext context) {
  final l10n = context.l10n;
  String qty(CabinStock item, num? value) => '${value.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}';

  return [
    TableColumnDef(title: l10n.expiredItems_table_barcodeColumn, displayValue: (item) => item.medicine?.barcode),
    TableColumnDef(title: l10n.expiredItems_table_medicineColumn, flex: 2, displayValue: (item) => item.medicine?.name),
    TableColumnDef(
      title: l10n.expiredItems_table_cabinColumn,
      // cabinDrawrQuantity'de kabin boş gelebiliyor; göz → çekmece → kabin yolundan da okunur.
      displayValue: (item) =>
          item.assignment?.cabin?.name ?? item.cabinDrawerDetail?.drawerUnit?.drawerSlot?.cabin?.name,
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_locationColumn,
      displayValue: (item) => '${item.shelfNo ?? '-'}/${item.corpartmentNo ?? '-'}',
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_minQuantityColumn,
      numeric: true,
      displayValue: (item) => qty(item, item.assignment?.minQuantity),
      sortValue: (item) => item.assignment?.minQuantity,
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_maxQuantityColumn,
      numeric: true,
      displayValue: (item) => qty(item, item.assignment?.maxQuantity),
      sortValue: (item) => item.assignment?.maxQuantity,
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_criticalQuantityColumn,
      numeric: true,
      displayValue: (item) => qty(item, item.assignment?.criticalQuantity),
      sortValue: (item) => item.assignment?.criticalQuantity,
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_quantityColumn,
      numeric: true,
      displayValue: (item) => qty(item, item.quantity),
      sortValue: (item) => item.quantity,
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_expiryDateColumn,
      displayValue: (item) => item.miadDate?.formattedDate,
      sortValue: (item) => item.miadDate,
    ),
    TableColumnDef(
      title: l10n.expiredItems_table_remainingDaysColumn,
      displayValue: (item) => item.remainingDayText,
      sortValue: (item) => item.remainingDay,
      cellBuilder: (item) => Align(alignment: Alignment.centerLeft, child: MedRemainingDayChip(days: item.remainingDay ?? 0)),
    ),
  ];
}
