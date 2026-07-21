part of 'directed_orders_screen.dart';

void showMedicineTableDialog(BuildContext context, Hospitalization hosp) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (context) =>
          DirectedOrdersDetailViewModel(orderRepository: context.read(), l10n: context.l10n)..fetchOrders(),
      child: MedicineTableView(),
    ),
  );
}

class MedicineTableView extends StatelessWidget {
  const MedicineTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DirectedOrdersDetailViewModel>(
      builder: (context, vm, child) {
        return Center();
        // return CustomDialog(
        //   title: context.l10n.directedOrdersScreenTitle,
        //   showSearch: true,
        //   onSearchChanged: vm.search,
        //   width: context.width * 0.7,
        //   child: SizedBox(
        //     height: 600,
        //     child: MedTable<Object>(
        //       data: vm.filteredItems,
        //       isLoading: vm.isFetching,
        //       columnDefs: [],
        //       // DirectedOrder.titles context'e erişimi olmayan bir entity
        //       // getter'ı olduğundan, kolon başlıkları burada l10n ile override edilir.
        //       // columnDefs: [
        //       //   TableColumnDef(title: context.l10n.wizard_summaryLabelStation, contentIndex: 0),
        //       //   TableColumnDef(title: context.l10n.directedOrdersColumnBarcode, contentIndex: 1),
        //       //   TableColumnDef(title: context.l10n.drugActivity_column_material, contentIndex: 2),
        //       // ],
        //     ),
        //   ),
        // );
      },
    );
  }
}
