import 'package:flutter/material.dart';

class CabinAssignmentView extends StatelessWidget {
  const CabinAssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

// class CabinAssignmentView extends StatelessWidget {
//   const CabinAssignmentView({super.key, this.stationId});

//   final int? stationId;

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => CabinAssignmentNotifier(
//         cabinsUseCase: context.read(),
//         layoutUseCase: context.read(),
//         getAssignmentsUseCase: context.read(),
//         updateAssignmentUseCase: context.read(),
//         deleteAssignmentUseCase: context.read(),
//         getCabinsByStationUseCase: context.read(),
//       )..initialize(stationId: stationId),
//       child: _buildChild(),
//     );
//   }

//   Widget _buildChild() {
//     return Consumer<CabinAssignmentNotifier>(
//       builder: (context, notifier, _) {
//         if (notifier.isFetching && notifier.cabins.isEmpty) {
//           return Center(child: CircularProgressIndicator.adaptive());
//         }

//         if (notifier.cabins.isEmpty) {
//           return Center(child: CommonEmptyStates.noCabin());
//         }

//         return CabinEditorView<CabinAssignment>(
//           mode: CabinViewMode.assignment,
//           cabinId: notifier.selectedCabin?.id ?? 0,
//           cabins: notifier.cabins,
//           selectedCabin: notifier.selectedCabin,
//           onCabinChanged: notifier.onCabinChanged,
//           layouts: notifier.layout,
//           cellData: null,
//           cellBuilder: (context, unit, data) {
//             final assignment = notifier.getAssignmentForUnit(unit.id);

//             return AssignmentCell(
//               unit: unit,
//               assignment: assignment,
//               onTap: () => _onTap(context, assignment),
//               onIconTap: () => _onDelete(context, assignment),
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _onTap(BuildContext context, CabinAssignment? data) async {
//     final vm = context.read<CabinAssignmentNotifier>();
//     final result = await showCabinAssignmentFormView(context, data);
//     if (result == true && context.mounted) {
//       vm.refreshCabinData();
//     }
//   }

//   Future<void> _onDelete(BuildContext context, CabinAssignment? item) async {
//     // Veri null ise veya ilaç atanmamışsa silinecek bir şey yoktur
//     if (item == null) return;

//     final vm = context.read<CabinAssignmentNotifier>();

//     MessageUtils.showConfirmDeleteDialog(
//       context: context,
//       onConfirm: () {
//         vm.deleteAssignment(
//           item,
//           onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
//           onSuccess: (message) => MessageUtils.showSuccessSnackbar(context, message),
//         );
//       },
//     );
//   }
// }
