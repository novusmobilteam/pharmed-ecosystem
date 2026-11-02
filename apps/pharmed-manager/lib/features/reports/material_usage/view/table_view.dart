part of 'material_usage_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final MaterialUsageReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final columnDefs = _buildColumnDefs(context);
    // Listelenen satırların miktar toplamı. Farklı birimli malzemeler
    // karışabileceği için birimsiz, salt sayı olarak gösterilir.
    final total = notifier.items.fold<num>(0, (sum, item) => sum + (item.quantity ?? 0));
    final totalText = total.formatFractional;
    final quantityIndex = columnDefs.indexWhere((c) => c.title == context.l10n.tableCore_stockTransactionQuantityColumn);

    return MedTable<StockTransaction>(
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
      columnDefs: columnDefs,

      // Toplam miktar — ekranda tablonun altında, Excel/PDF'te son satırda.
      summary: _TotalQuantityBar(text: context.l10n.report_materialUsage_totalQuantityLabel(totalText)),
      exportSummaryRow: [
        for (var i = 0; i < columnDefs.length; i++)
          i == 0
              ? context.l10n.report_materialUsage_totalLabel
              : i == quantityIndex
              ? totalText
              : '',
      ],
    );
  }
}

List<TableColumnDef<StockTransaction>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionDateColumn,
    displayValue: (item) => _dateOf(item)?.formattedDateTime,
    sortValue: _dateOf,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionMedicineCodeColumn,
    displayValue: (item) => switch (item.medicine) {
      Drug d => d.code,
      _ => null,
    },
  ),
  TableColumnDef(title: context.l10n.tableCore_materialColumn, displayValue: (item) => item.medicine?.name.toString()),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionBarcodeColumn,
    displayValue: (item) => item.medicine?.barcode,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionTypeColumn,
    displayValue: (item) => item.transactionKind?.label,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionQuantityColumn,
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.quantity,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionPreviousQuantityColumn,
    displayValue: (item) => '${item.beforeQuantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.beforeQuantity,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionActorColumn,
    displayValue: (item) => item.user?.fullName,
  ),
];

/// İşlem tarihi: servisin transactionStartDate alanı (StockTransaction.startDate).
/// sendDate servis tarafında 'hbysSendDate' — HBYS'ye gönderim tarihidir, işlem
/// tarihi değildir; bu yüzden kullanılmaz.
DateTime? _dateOf(StockTransaction item) => item.startDate ?? item.endDate;

class _TotalQuantityBar extends StatelessWidget {
  const _TotalQuantityBar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MedColors.surface2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.centerRight,
      child: Text(text, style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w700)),
    );
  }
}
