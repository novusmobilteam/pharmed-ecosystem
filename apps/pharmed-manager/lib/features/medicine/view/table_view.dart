part of 'medicine_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final MedicineNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Medicine>(
      data: notifier.items,
      isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
      enableExcel: true,
      enableSearch: true,
      onSearchChanged: notifier.search,
      actions: [
        TableActionItem.edit(
          context: context,
          onPressed: (medicine) => notifier.openPanel(medicine: medicine),
        ),
        TableActionItem.delete(context: context, onPressed: (medicine) => _onDelete(context, notifier, medicine)),
      ],
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      onPageChanged: (page) => notifier.setPage(page),
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<Medicine>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.medicine_table_barcodeColumn, displayValue: (item) => item.barcode),
  TableColumnDef(
    title: context.l10n.medicine_table_atcCodeColumn,
    displayValue: (item) => item.when(drug: (d) => d.atcCode?.toString(), consumable: (_) => '-'),
  ),
  TableColumnDef(title: context.l10n.medicine_table_nameColumn, displayValue: (item) => item.name),
  TableColumnDef(
    title: context.l10n.medicine_table_materialTypeColumn,
    displayValue: (item) => item.when(
      drug: (_) => context.l10n.enumCore_medicineTypeDrug,
      consumable: (_) => context.l10n.enumCore_medicineTypeConsumable,
    ),
  ),
  TableColumnDef(
    title: context.l10n.medicine_table_prescriptionTypeColumn,
    displayValue: (item) => item.when(drug: (d) => d.prescriptionType.label, consumable: (_) => '-'),
  ),
  TableColumnDef(title: context.l10n.medicine_table_countTypeColumn, displayValue: (item) => item.countType?.label),
  TableColumnDef(
    title: context.l10n.medicine_table_purchaseTypeColumn,
    displayValue: (item) => item.purchaseType?.label,
  ),
  TableColumnDef(title: context.l10n.medicine_table_returnTypeColumn, displayValue: (item) => item.returnType?.label),
  TableColumnDef(
    title: context.l10n.medicine_table_statusColumn,
    displayValue: (item) => item.when(drug: (d) => d.status.label, consumable: (c) => c.status.label),
  ),
];
