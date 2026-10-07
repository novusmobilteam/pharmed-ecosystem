part of 'inventory_screen.dart';

class TableView extends ConsumerWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(inventoryNotifierProvider);
    final notifier = ref.read(inventoryNotifierProvider.notifier);

    return MedTable<MedicineAssignment>(
      data: notifier.items,
      isLoading: notifier.isFetchingItems,
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
