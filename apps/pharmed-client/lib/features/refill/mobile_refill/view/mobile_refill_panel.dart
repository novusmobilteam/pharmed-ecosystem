// import 'package:flutter/material.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../widgets/widgets.dart';
// import '../../refill.dart';

// // [SWREQ-CLI-REFILL-002] [IEC 62304 §5.5]
// // Mobil kabin dolum sağ paneli.
// //
// // İki ana görünüm:
// //   - Hasta seçilmemişse: kabine atanmış hastaların listesi (CabinPatientPickerList)
// //   - Hasta seçilmişse:  hasta başlığı + filtreler + reçete listesi + action bar
// //
// // Drawer/RFID akışı bu panel'in dışında yönetilir; panel sadece state'ten okur:
// //   - drawerStage     → action bar buton seçimi
// //   - state.canComplete → "Tamamla" mı yoksa "Devam Et" mi (UNEXPECTED blokajı dahil)
// //   - state.isBlockedByUnexpected → UNEXPECTED banner'ı için
// //   - state.hasUnplannedMovement  → plan dışı banner'ı için
// //
// // Sınıf: Class B

// class MobileRefillPanel extends StatelessWidget {
//   const MobileRefillPanel({
//     super.key,
//     required this.notifier,
//     required this.state,
//     required this.drawerStage,
//     required this.onStartRefill,
//     required this.onCompleteRefill,
//     required this.onSelectAssignment,
//     required this.onChangePatient,
//     required this.onToggleItem,
//   });

//   final MobileRefillNotifier notifier;
//   final MobileRefillState state;
//   final MobileDrawerStage drawerStage;
//   final VoidCallback onStartRefill;
//   final VoidCallback onCompleteRefill;
//   final ValueChanged<BedAssignment> onSelectAssignment;
//   final VoidCallback onChangePatient;
//   final ValueChanged<int> onToggleItem;

//   /// Süreç aktif (Opening/Opened/Closed) mı?
//   bool get _isProcessActive => drawerStage.isActive;

//   /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
//   bool get _isSelectionLocked => drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened;

//   @override
//   Widget build(BuildContext context) {
//     return OperationPanelBase(
//       mode: CabinOperationMode.refill,
//       child: switch (state) {
//         MobileRefillUninitialized() ||
//         MobileRefillLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

//         MobileRefillIdle() || MobileRefillSlotSelected() || MobileRefillNoPatient() || MobileRefillFatalError() =>
//           CabinPatientPickerList(assignments: state.availableAssignments, onSelected: onSelectAssignment),

//         _ when state.readyContext != null => _buildReady(context, notifier, state.readyContext!),

//         _ => throw StateError('Unhandled MobileRefillState: $state'),
//       },
//     );
//   }

//   Widget _buildReady(BuildContext context, MobileRefillNotifier notifier, MobileRefillReady ready) {
//     return Column(
//       spacing: 8.0,
//       children: [
//         CabinActivePatientCard(
//           patient: ready.patient,
//           bed: ready.bed,
//           room: ready.room,
//           onChange: _isProcessActive ? null : onChangePatient,
//         ),

//         MedFilterChipGroup<PrescriptionMovementType?>(
//           options: [null, ...PrescriptionMovementType.refillableTypes],
//           selected: ready.statusFilter,
//           onChanged: notifier.onStatusFilterChanged,
//           labelBuilder: (type) => type?.label(context) ?? context.l10n.filter_all,
//           bgColor: ready.statusFilter?.backgroundColor,
//         ),
//         MedFilterChipGroup<DateRangePreset>(
//           options: DateRangePreset.values,
//           selected: ready.datePreset,
//           labelBuilder: (p) => p.label(context.l10n),
//           onChanged: notifier.onDatePresetChanged,
//         ),
//         Expanded(
//           child: _PrescriptionList(
//             items: ready.prescriptionItems,
//             selectedItemIds: ready.selectedItemIds,
//             isProcessActive: _isSelectionLocked,
//             onToggleItem: onToggleItem,
//           ),
//         ),
//         _RefillActionBar(state: ready, hasSelection: ready.selectedItemIds.isNotEmpty, onStart: onStartRefill),
//       ],
//     );
//   }
// }

// class _PrescriptionList extends StatelessWidget {
//   const _PrescriptionList({
//     required this.items,
//     required this.selectedItemIds,
//     required this.isProcessActive,
//     required this.onToggleItem,
//   });

//   final List<PrescriptionItem> items;
//   final Set<int> selectedItemIds;

//   /// Süreç aktifken kullanıcı seçim değiştiremez (orchestrator açıkken kilitli).
//   final bool isProcessActive;
//   final ValueChanged<int> onToggleItem;

//   @override
//   Widget build(BuildContext context) {
//     if (items.isEmpty) {
//       return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
//     }

//     // canFill durumundakileri başa, diğerlerini arkaya sırala
//     final sortedItems = List<PrescriptionItem>.from(items)
//       ..sort((a, b) {
//         final aCanFill = a.lastMovement?.type.canFill ?? false;
//         final bCanFill = b.lastMovement?.type.canFill ?? false;
//         if (aCanFill && !bCanFill) return -1;
//         if (!aCanFill && bCanFill) return 1;
//         return 0;
//       });

//     return ListView.builder(
//       padding: const EdgeInsets.only(bottom: 6, right: 2),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = sortedItems[index];

//         final isEligible = item.status?.canFill ?? false;
//         final isSelected = item.id != null && selectedItemIds.contains(item.id);

//         return RxOperationCard(
//           mode: RxOperationCardMode.refill,
//           item: item,
//           isSelected: isSelected,
//           isEligible: isEligible,
//           onTap: isProcessActive || item.id == null ? null : () => onToggleItem(item.id!),
//         );
//       },
//     );
//   }
// }

// class _RefillActionBar extends StatelessWidget {
//   const _RefillActionBar({required this.state, required this.hasSelection, required this.onStart});

//   final MobileRefillState state;
//   final bool hasSelection;
//   final VoidCallback onStart;

//   @override
//   Widget build(BuildContext context) {
//     if (state is MobileRefillReady) {
//       return SizedBox(
//         width: context.width,
//         child: MedButton(
//           label: context.l10n.refill_action_start,
//           onPressed: hasSelection ? onStart : null,
//           size: MedButtonSize.sm,
//         ),
//       );
//     } else {
//       return SizedBox();
//     }
//   }
// }
