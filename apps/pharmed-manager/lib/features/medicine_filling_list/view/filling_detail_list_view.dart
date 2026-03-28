// part of 'filling_record_list_view.dart';

// Future<void> showFillingDetailView(BuildContext context, int recordId) async {
//   await showDialog(
//     context: context,
//     builder: (_) => ChangeNotifierProvider.value(
//       value: context.read<FillingListViewModel>(),
//       child: FillingDetailListView(
//         recordId: recordId,
//       ),
//     ),
//   );
// }

// class FillingDetailListView extends StatelessWidget {
//   const FillingDetailListView({super.key, required this.recordId});

//   final int recordId;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FillingListViewModel>(
//       builder: (context, vm, child) {
//         return CabinProcessWrapper(
//           onDrawerReady: (BuildContext context, CabinAssignment activeDrawer) async {
//             try {
//               final FillingDetail detailItem = vm.details.firstWhere(
//                 (detail) => detail.cabinDrawerQuantity?.id == activeDrawer.id,
//               );

//               final CabinAssignment normalizedData = detailItem.toCompatibleQuantity();

//               final bool isSuccess = await showCabinInventoryView(
//                 context,
//                 quantity: (detailItem.quantity ?? 0).toDouble(),
//                 initial: normalizedData,
//                 onSave: (List<CabinInputData> inputs) {
//                   return context.read<FillingListViewModel>().fillCabin(inputs, detailItem.id ?? 0);
//                 },
//               );

//               if (isSuccess && context.mounted) {
//                 context.read<FillingListViewModel>().fetchFillingDetail(recordId);
//               }

//               return isSuccess;
//             } catch (e) {
//               debugPrint("Hata: Aktif çekmece listede bulunamadı. $e");
//               return false;
//             }
//           },
//           child: CustomDialog(
//             title: 'İlaç Dolum Listesi',
//             showSearch: true,
//             onSearchChanged: vm.searchDetails,
//             child: _buildChild(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildChild() {
//     return Consumer<FillingListViewModel>(
//       builder: (context, vm, _) {
//         if (vm.isLoading(vm.fetchDetailKey) && vm.details.isEmpty) {
//           return const Center(
//             child: CircularProgressIndicator.adaptive(),
//           );
//         }
//         if (vm.isFailed(vm.fetchDetailKey) || vm.details.isEmpty) {
//           return Center(
//             child: CommonEmptyStates.noData(),
//           );
//         }
//         return ListView.builder(
//           itemCount: vm.details.length,
//           itemBuilder: (BuildContext context, int index) {
//             final detail = vm.details.elementAt(index);
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: _MedicineTileView(detail),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class _MedicineTileView extends StatelessWidget {
//   const _MedicineTileView(this.detail);

//   final FillingDetail detail;

//   @override
//   Widget build(BuildContext context) {
//     final notifier = context.read<CabinStatusNotifier>();

//     return Container(
//       padding: EdgeInsets.all(6.0),
//       decoration: BoxDecoration(
//         color: detail.isFilled ? Colors.green.withAlpha(120) : Colors.transparent,
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: ListTile(
//         onTap: () {
//           if (!detail.isFilled) {
//             notifier.startOperation(
//               detail.cabinDrawerQuantity ?? CabinAssignment(),
//             );
//           }
//         },
//         title: Text(detail.medicine?.name ?? '-'),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Miktar: ${detail.quantity}',
//               style: context.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             if (detail.fillingQuantity != null) Text('Dolum Miktarı: ${detail.fillingQuantity}'),
//           ],
//         ),
//         trailing: Icon(
//           detail.isFilled ? PhosphorIcons.check() : PhosphorIcons.caretRight(),
//         ),
//       ),
//     );
//   }
// }
