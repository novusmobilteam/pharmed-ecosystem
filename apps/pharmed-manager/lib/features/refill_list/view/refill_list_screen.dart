// import 'package:flutter/material.dart';
// import 'package:pharmed_manager/widgets/side_panel.dart';

// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:provider/provider.dart';

// import '../../../core/core.dart';

// import '../widgets/medicine_filling_card.dart';
// import '../notifier/new_refill_list_notifier.dart';
// import '../notifier/refill_list_notifier.dart';

// part 'refill_list_form_panel.dart';

// class RefillListScreen extends StatelessWidget {
//   const RefillListScreen({super.key, required this.menu});

//   final MenuItem menu;

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => RefillListNotifier(
//         getStations: context.read(),
//         getRefillLists: context.read(),
//         updateRefillListStatus: context.read(),
//         cancelRefillList: context.read(),
//       )..getStations(),
//       child: Consumer<RefillListNotifier>(
//         builder: (context, notifier, _) {
//           return MedResponsiveLayout(
//             mobile: const MedMobileLayout(),
//             tablet: const MedTabletLayout(),
//             desktop: MedDesktopLayout(
//               menu: menu,
//               actions: [
//                 MedButton(
//                   label: context.l10n.refillList_newButtonLabel,
//                   size: MedButtonSize.sm,
//                   onPressed: () => notifier.openPanel(),
//                 ),
//               ],

//               child: SidePanelWrapper(
//                 isOpen: notifier.isPanelOpen,
//                 width: 700,
//                 panel: RefillListFormPanel(station: notifier.selectedStation, refillList: notifier.selectedItem),
//                 child: MedTable<RefillList>(
//                   data: notifier.items,
//                   isLoading: notifier.isTableLoading,
//                   enableExcel: true,
//                   enableSearch: true,
//                   categories: notifier.tableCategories,
//                   //onSearchChanged: notifier.search,
//                   categoryTitle: context.l10n.report_stationsCategoryTitle,
//                   onCategoryChanged: (id) =>
//                       notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
//                   selectedCategoryId: notifier.selectedStationId,
//                   cellBuilder: (item, colIndex, value) {
//                     if (colIndex == 3) {
//                       final text = value == true
//                           ? context.l10n.refillList_cellValueYes
//                           : context.l10n.refillList_cellValueNo;
//                       return Text(text);
//                     }
//                     return null;
//                   },
//                   actions: [
//                     TableActionItem.edit(context: context, onPressed: (item) => notifier.openPanel),
//                     TableActionItem(
//                       icon: PhosphorIcons.arrowClockwise(),
//                       tooltip: context.l10n.refillList_updateStatusTooltip,
//                       onPressed: (record) => notifier.updateRefillListStatus(
//                         record,
//                         onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
//                         onSuccess: (_) =>
//                             MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
//                       ),
//                     ),
//                     TableActionItem(
//                       icon: PhosphorIcons.x(),
//                       tooltip: context.l10n.common_cancelButton,
//                       onPressed: (record) => notifier.cancelRefillList(
//                         record,
//                         onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
//                         onSuccess: (_) =>
//                             MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
//                       ),
//                     ),
//                   ],
//                   columnDefs: [],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
