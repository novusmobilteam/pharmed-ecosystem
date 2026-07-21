// import 'package:flutter/material.dart';

// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:provider/provider.dart';

// import '../../../core/core.dart';
// import '../notifier/refill_list_detail_notifier.dart';
// import 'refill_list_refill_view.dart';

// class FillingListView extends StatelessWidget {
//   const FillingListView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => RefillListDetailNotifier(
//         getCurrentStationRefillList: context.read(),
//         getRefillListDetail: context.read(),
//         refill: context.read(),
//       )..getRefillLists(),
//       child: Consumer<RefillListDetailNotifier>(
//         builder: (context, notifier, child) {
//           return CustomDialog(
//             title: context.l10n.refillList_dialogTitle,
//             isLoading: notifier.isLoading(notifier.fetchDetailOp),
//             showSearch: true,
//             child: _buildChild(),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChild() {
//     return Consumer<RefillListDetailNotifier>(
//       builder: (context, notifier, _) {
//         if (notifier.isLoading(notifier.fetchOp)) {
//           return const Center(child: CircularProgressIndicator.adaptive());
//         }
//         if (notifier.items.isEmpty) {
//           return Center(child: EmptyStateWidget(variant: EmptyStateVariant.custom));
//         }

//         return ListView.builder(
//           itemCount: notifier.items.length,
//           itemBuilder: (context, index) {
//             final item = notifier.items.elementAt(index);
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 12.0),
//               child: InkWell(
//                 onTap: () {
//                   notifier.selectRefillList(
//                     item,
//                     onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
//                     onSuccess: () => _showRefillView(context),
//                   );
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             context.l10n.refillList_recordNoLabel('${item.id}'),
//                             style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             context.l10n.refillList_createdDateLabel('${item.date?.formattedDateTime}'),
//                             style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             context.l10n.refillList_assignedUserNameLabel('${item.user?.fullName}'),
//                             style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 10),
//                           MedInfoChip(info: item.status?.label),
//                         ],
//                       ),
//                       Icon(PhosphorIcons.caretRight()),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// void _showRefillView(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (_) =>
//         ChangeNotifierProvider.value(value: context.read<RefillListDetailNotifier>(), child: RefillListRefillView()),
//   );
// }
