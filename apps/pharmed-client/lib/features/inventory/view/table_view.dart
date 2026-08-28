part of 'inventory_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.items, required this.isLoading, required this.notifier});

  final InventoryNotifier notifier;
  final List<MedicineAssignment> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return MedTable<MedicineAssignment>(
      data: items,
      isLoading: isLoading,
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
      enableDateFilter: false,
      enablePagination: false,
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<MedicineAssignment>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.medicine_fieldName, displayValue: (item) => item.medicine?.name),
  TableColumnDef(title: context.l10n.medicine_fieldBarcode, displayValue: (item) => item.medicine?.barcode),
];
