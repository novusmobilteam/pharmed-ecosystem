part of 'directed_orders_screen.dart';

// class _TableView extends StatelessWidget {
//   const _TableView({required this.vm});

//   final DirectedOrdersViewModel vm;

//   Widget? _buildCell(Hospitalization item, int colIndex, dynamic _) {
//     return switch (colIndex) {
//       0 => Text(item.patient?.fullName ?? '-'),
//       1 => Text(item.patient?.protocolNo ?? '-'),
//       // 2 => Text(item.bedNo ?? '-'),
//       // 3 => Text(item.roomNo ?? '-'),
//       _ => null,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MedTable<Hospitalization>(
//       data: vm.filteredItems,
//       isLoading: vm.isFetching,
//       enableSearch: true,
//       enableExcel: true,
//       onSearchChanged: vm.search,
//       // columnDefs: _buildColumnDefs(context),
//       cellBuilder: _buildCell,
//       actions: [
//         TableActionItem(
//           icon: PhosphorIcons.dotsThreeVertical(),
//           tooltip: context.l10n.directedOrdersMedicinesTooltip,
//           onPressed: (hosp) => showMedicineTableDialog(context, hosp),
//         ),
//       ],
//       emptyWidget: vm.hasNoSearchResults
//           ? EmptyStateWidget(variant: EmptyStateVariant.noResults)
//           : EmptyStateWidget(variant: EmptyStateVariant.noResults),
//       columnDefs: [],
//     );
//   }
// }
