// import 'package:flutter/material.dart';
// import '../../../core/core.dart';
// import '../../cabin_assignment/domain/entity/cabin_assignment.dart';
// import '../../cabin/shared/cabin_inventory/view/cabin_inventory_view.dart';
// import '../../cabin/shared/cabin_process/view/cabin_process_wrapper.dart';
// import '../../filling_list/domain/entity/filling_detail.dart';
// import '../view_model/filling_list_viewmodel.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:provider/provider.dart';

// import '../../cabin/domain/entity/cabin_input_data.dart';
// import '../../cabin/shared/cabin_process/notifier/cabin_status_notifier.dart';

// part 'filling_detail_list_view.dart';

// class FillingRecordListView extends StatefulWidget {
//   const FillingRecordListView({super.key});

//   @override
//   State<FillingRecordListView> createState() => _FillingRecordListViewState();
// }

// class _FillingRecordListViewState extends State<FillingRecordListView> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => FillingListViewModel(
//         fillingListRepository: context.read(),
//       )..fetchFillingRecords(),
//       child: Consumer<FillingListViewModel>(
//         builder: (context, vm, child) {
//           return CustomDialog(
//             title: 'İlaç Dolum Listesi',
//             showSearch: true,
//             onSearchChanged: vm.search,
//             child: _buildChild(),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChild() {
//     return Consumer<FillingListViewModel>(
//       builder: (context, vm, _) {
//         if (vm.isLoading(vm.fetchMedicineKey)) {
//           return const Center(
//             child: CircularProgressIndicator.adaptive(),
//           );
//         }
//         if (vm.isError || vm.hasNoSearchResults) {
//           return Center(
//             child: CommonEmptyStates.noData(),
//           );
//         }

//         return ListView.builder(
//           itemCount: vm.filteredItems.length,
//           itemBuilder: (context, index) {
//             final record = vm.allItems.elementAt(index);
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 12.0),
//               child: ListTile(
//                 title: Text('Dolum Kayıt No: ${record.id}'),
//                 trailing: Icon(PhosphorIcons.caretRight()),
//                 onTap: () {
//                   final recordId = record.id ?? 0;
//                   vm.fetchFillingDetail(recordId);
//                   showFillingDetailView(context, recordId);
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
