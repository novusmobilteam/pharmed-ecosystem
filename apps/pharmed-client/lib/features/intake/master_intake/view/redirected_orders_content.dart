// part of 'master_intake_selection_view.dart';

// class RedirectedOrdersContent extends ConsumerWidget {
//   const RedirectedOrdersContent({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(redirectedIntakeOrdersNotifierProvider);
//     final notifier = ref.read(redirectedIntakeOrdersNotifierProvider.notifier);

//     final bool noPatientSelected = state is RedirectedOrdersNoPatient;
//     final bool isLoading = state is RedirectedOrdersLoading;

//     final orders = state is RedirectedOrdersLoaded ? state.pendingOrders : const <RedirectedIntakeOrder>[];
//     final selectedOrderIds = state is RedirectedOrdersLoaded ? state.selectedOrderIds : const <int>{};
//     final checkStates = state is RedirectedOrdersLoaded ? state.checkStates : const <int, IntakeCheckState>{};

//     return CabinSelectionContentShell(
//       searchQuery: '',
//       onSearchQueryChanged: (_) {},
//       searchHint: '',
//       isLoading: isLoading,
//       isEmpty: noPatientSelected || (!isLoading && orders.isEmpty),
//       emptyMessage: noPatientSelected ? context.l10n.wasteSelectPatient : context.l10n.intake_hint_noRedirectedOrders,
//       content: (isLoading || noPatientSelected)
//           ? null
//           : CabinOperationGrid(
//               singleColumnThreshold: 0,
//               maxColumns: 3,
//               itemCount: orders.length,
//               itemBuilder: (context, i) {
//                 final order = orders[i];
//                 final isSelected = selectedOrderIds.contains(order.id);
//                 final checkStatus = checkStates[order.id] ?? const CheckIdle();
//                 final drug = order.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
//                 final collectNote = drug?.collectNote?.trim();

//                 final time = order.prescriptionItem?.time;
//                 final dose = order.dosePiece.formatFractional;
//                 final unit = order.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

//                 return RxOperationCard2(
//                   title: order.medicine?.name ?? '—',
//                   subtitle: time != null ? '$dose $unit (${time.shortRelativeLabelOf(context)})' : '$dose $unit',
//                   isSelected: isSelected,
//                   onTap: () => notifier.toggleOrder(order.id),
//                   statusChip: RxCardChip(label: context.l10n.intake_status_redirected, tone: MedTone.info),
//                   statusRow: switch (checkStatus) {
//                     CheckIdle() => null,
//                     CheckLoading() => RxCardStatusRow(
//                       leadingText: context.l10n.intake_status_checking,
//                       indicator: RxCardIndicator.spinner,
//                     ),
//                     CheckSuccess() => RxCardStatusRow(
//                       leadingText: context.l10n.intake_status_readyToTake,
//                       tone: MedTone.success,
//                       indicator: RxCardIndicator.check,
//                     ),
//                     CheckFailed(:final message) => RxCardStatusRow(
//                       leadingText: message ?? context.l10n.intake_status_checkFailed,
//                       tone: MedTone.error,
//                       indicator: RxCardIndicator.warn,
//                     ),
//                   },
//                   note: (collectNote != null && collectNote.isNotEmpty)
//                       ? RxCardNote(label: context.l10n.medicine_fieldCollectNote, text: collectNote)
//                       : null,

//                   extras: [
//                     if (order.isEquivalent)
//                       MedChip(
//                         label: context.l10n.intake_label_equivalentOptions,
//                         background: MedColors.amberLight,
//                         foreground: MedColors.amber,
//                         showBorder: false,
//                       ),

//                     _RedirectSourceInfo(order: order),
//                   ],
//                 );
//               },
//             ),
//       footer: (state is RedirectedOrdersLoaded && orders.isNotEmpty)
//           ? MedButton(
//               label: context.l10n.intake_action_start,
//               onPressed: state.canStart
//                   ? () async {
//                       final selected = orders.where((o) => selectedOrderIds.contains(o.id)).toList();
//                       await ref.read(masterIntakeNotifierProvider.notifier).startRedirectedIntake(selected);
//                     }
//                   : null,
//             )
//           : null,
//     );
//   }
// }

// class _RedirectSourceInfo extends StatelessWidget {
//   const _RedirectSourceInfo({required this.order});

//   final RedirectedIntakeOrder order;

//   @override
//   Widget build(BuildContext context) {
//     final rows = <(IconData, String)>[
//       if (order.sendStationName != null)
//         (
//           PhosphorIcons.mapPin(),
//           order.sendServiceName != null
//               ? '${order.sendStationName} · ${order.sendServiceName}'
//               : order.sendStationName!,
//         ),
//       if (order.sendUserName != null)
//         (PhosphorIcons.user(), context.l10n.intake_label_redirectedBy(order.sendUserName!)),
//     ];

//     if (rows.isEmpty) return const SizedBox.shrink();

//     return Container(
//       padding: MedSpacing.insetLg,
//       decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.mdAll),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         spacing: MedSpacing.xs,
//         children: rows
//             .map(
//               (r) => Row(
//                 spacing: MedSpacing.xs,
//                 children: [
//                   Icon(r.$1, size: 16, color: MedColors.text2),
//                   Expanded(
//                     child: Text(
//                       r.$2,
//                       style: MedTextStyles.bodyMd(color: MedColors.text2),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }
