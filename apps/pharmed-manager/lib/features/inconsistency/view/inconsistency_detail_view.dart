// part of 'inconsistency_screen.dart';

// class InconsistencyDetailView extends StatefulWidget {
//   const InconsistencyDetailView({super.key});

//   @override
//   State<InconsistencyDetailView> createState() => _InconsistencyDetailViewState();
// }

// class _InconsistencyDetailViewState extends State<InconsistencyDetailView> {
//   InconsistencyDetailViewModel? _viewModel;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (BuildContext context, vm, _) {
//         if (_viewModel != vm) {
//           _viewModel = vm;
//           _setupCallbacks(context, vm);
//         }

//         return buildLayout();
//       },
//     );
//   }

//   Widget buildLayout() {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (BuildContext context, vm, _) {
//         switch (vm.status) {
//           case APIRequestStatus.initial:
//           case APIRequestStatus.loading:
//             return Center(
//               child: CircularProgressIndicator.adaptive(),
//             );
//           case APIRequestStatus.failed:
//             return Center(
//               child: Text(vm.statusMessage.toString()),
//             );
//           case APIRequestStatus.success:
//             return CustomDialog(
//               maxHeight: 800,
//               width: context.width * 0.8,
//               title: 'Tutarsızlık Hareketleri',
//               actions: [
//                 RectangleIconButton(
//                   iconData: PhosphorIcons.check(),
//                   tooltip: 'Tutarsızlık Çöz',
//                   onPressed: () => _onSolve(context, vm),
//                 ),
//                 RectangleIconButton(
//                   iconData: vm.movementType.icon,
//                   tooltip: vm.movementType.label,
//                   onPressed: vm.toggleMovements,
//                 ),
//               ],
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 spacing: AppDimensions.registrationDialogSpacing,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (vm.movementType == MovementType.material) InconsistencySummaryView(),
//                   StockMovementsTableView(),
//                 ],
//               ),
//             );
//         }
//       },
//     );
//   }

//   void _setupCallbacks(BuildContext context, InconsistencyDetailViewModel vm) {
//     vm.onLoading = () => showLoading(context);
//     vm.onError = (message) {
//       hideLoading(context);
//       MessageUtils.showErrorSnackbar(context, message ?? 'Bir hata oluştu');
//     };
//     vm.onSuccess = (message) {
//       hideLoading(context);
//       if (message != null) {
//         MessageUtils.showSuccessSnackbar(context, message);
//       }
//     };
//   }
// }

// void _onSolve(BuildContext context, InconsistencyDetailViewModel viewModel) {
//   showDialog(
//     context: context,
//     builder: (_) => ChangeNotifierProvider.value(
//       value: viewModel,
//       child: SolveDialog(
//         onSave: () async {
//           final res = await viewModel.solveInconsistency();
//           if (res == true && context.mounted) {
//             Navigator.of(context).pop();
//           }
//         },
//       ),
//     ),
//   );
// }

// class SolveDialog extends StatelessWidget {
//   const SolveDialog({super.key, required this.onSave});

//   final VoidCallback onSave;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<InconsistencyDetailViewModel>(
//       builder: (context, vm, _) {
//         return RegistrationDialog(
//           title: 'Açıklama',
//           maxHeight: 350,
//           onSave: () => vm.deleteDescription.isNotEmpty ? onSave() : null,
//           saveButtonText: 'Çöz',
//           child: Column(
//             children: [
//               TextInputField(
//                 maxLines: 3,
//                 label: 'Tutarsızlık çözme nedenini açıklayınız',
//                 onChanged: (value) => vm.deleteDescription = value ?? '',
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
