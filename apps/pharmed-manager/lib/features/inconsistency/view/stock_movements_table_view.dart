part of 'inconsistency_screen.dart';

class StockMovementsTableView extends StatelessWidget {
  const StockMovementsTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center();
    // return Consumer<InconsistencyDetailViewModel>(
    //   builder: (context, vm, _) {
    //     return Flexible(
    //       child: GenericTableView<StockMovement>(
    //         isLoading: false,
    //         data: vm.filteredMovements,
    //       ),
    //     );
    //   },
    // );
  }
}
