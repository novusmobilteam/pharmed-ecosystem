part of 'directed_orders_screen.dart';

void showMedicineTableDialog(BuildContext context, Hospitalization hosp) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (context) => DirectedOrdersDetailViewModel(
        orderRepository: context.read(),
      )..fetchOrders(),
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
        return CustomDialog(
          title: 'Yönlendirilmiş Order Listesi',
          showSearch: true,
          onSearchChanged: vm.search,
          width: context.width * 0.7,
          child: SizedBox(
            height: 600,
            child: UnifiedTableView(
              data: vm.filteredItems,
              isLoading: vm.isFetching,
            ),
          ),
        );
      },
    );
  }
}
