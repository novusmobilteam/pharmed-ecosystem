// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../core/core.dart';
// import '../../../old_features/cabin/shared/cabin_assignment_picker/notifier/cabin_assignment_picker_notifier.dart';
// import '../../../old_features/cabin/shared/cabin_assignment_picker/view/cabin_assignment_picker_view.dart';

// import '../notifier/refill_list_detail_notifier.dart';

// class RefillListRefillView extends StatelessWidget {
//   const RefillListRefillView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final fillingNotifier = context.read<RefillListDetailNotifier>();

//     return ChangeNotifierProvider(
//       create: (context) {
//         final notifier = CabinAssignmentPickerNotifier(
//           getCabinAssignmetsUseCase: context.read(),
//           onSave: (inputs) => fillingNotifier.refill(inputs, 0),
//           externalAssignments: fillingNotifier.details.toCabinAssignments(),
//         )..getAssignments();

//         return notifier;
//       },
//       child: Consumer2<RefillListDetailNotifier, CabinAssignmentPickerNotifier>(
//         builder: (context, refillNotifier, accordionNotifier, _) {
//           if (refillNotifier.isLoading(refillNotifier.fetchDetailOp)) {
//             return Center(child: CircularProgressIndicator.adaptive());
//           }

//           return CustomDialog(
//             title: context.l10n.refillList_dialogTitle,
//             width: context.width * 0.8,
//             maxHeight: context.height * 0.9,
//             //onSearchChanged: accordionNotifier.search,
//             showSearch: true,
//             child: CabinAssignmentPickerView(type: CabinInventoryType.refillList),
//           );
//         },
//       ),
//     );
//   }
// }
