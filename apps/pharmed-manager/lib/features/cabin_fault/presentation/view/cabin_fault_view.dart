import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../cabin/shared/widgets/cabin_editor/cabin_editor_view.dart';
import '../notifier/cabin_fault_form_notifier.dart';

part 'fault_cell.dart';
part 'fault_registration_dialog.dart';
part 'fault_history_view.dart';

class CabinFaultView extends StatelessWidget {
  const CabinFaultView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

// class CabinFaultView extends StatelessWidget {
//   const CabinFaultView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (BuildContext context) => CabinFaultNotifier(
//         cabinsUseCase: context.read(),
//         layoutUseCase: context.read(),
//         getFaultsUseCase: context.read(),
//       )..initCabinContext(),
//       child: CustomDialog(
//         title: 'Çekmece Arıza',
//         maxHeight: context.height,
//         width: context.width * 0.9,
//         child: _buildChild(),
//       ),
//     );
//   }

//   Widget _buildChild() {
//     return Consumer<CabinFaultNotifier>(
//       builder: (context, notifier, _) {
//         if (notifier.isFetching && notifier.cabins.isEmpty) {
//           return Center(child: CircularProgressIndicator.adaptive());
//         }

//         if (notifier.cabins.isEmpty) {
//           return Center(child: CommonEmptyStates.noCabin());
//         }

//         return CabinEditorView<CabinFault>(
//           mode: CabinViewMode.maintenance,
//           cabinId: notifier.selectedCabin?.id ?? 0,
//           layouts: notifier.layout,
//           cabins: notifier.cabins,
//           selectedCabin: notifier.selectedCabin,
//           onCabinChanged: notifier.onCabinChanged,
//           cellData: null,
//           cellBuilder: (context, unit, data) {
//             final fault = notifier.getFaultForSlot(unit.id);
//             final faultRecords = notifier.getActiveFaultsForSlot(unit.id);

//             return FaultCell(
//               unit: unit,
//               fault: fault,
//               onTap: () => _showFaultRegistrationDialog(
//                 context,
//                 slotId: unit.id ?? 0,
//                 faultRecords: faultRecords,
//                 activeFault: fault,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// Future<void> _showFaultRegistrationDialog(
//   BuildContext context, {
//   required List<CabinFault> faultRecords,
//   required int slotId,
//   CabinFault? activeFault,
// }) async {
//   final result = await showDialog<bool?>(
//     context: context,
//     builder: (context) {
//       return ChangeNotifierProvider(
//         create: (context) => CabinFaultFormNotifier(
//           createUseCase: context.read(),
//           clearUseCase: context.read(),
//           slotId: slotId,
//           activeFault: activeFault,
//         ),
//         child: FaultRegistrationDialog(faultRecords: faultRecords),
//       );
//     },
//   );

//   if (context.mounted && result == true) {
//     context.read<CabinFaultNotifier>().initCabinContext();
//   }
// }
