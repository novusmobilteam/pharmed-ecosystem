// // [SWREQ-CLI-MWASTE-001] [IEC 62304 §5.5]
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';

// enum DisposeType { wastage, destruction }

// extension DisposeTypeX on DisposeType {
//   String localizedLabel(BuildContext context) => switch (this) {
//     DisposeType.wastage => context.l10n.waste_action_wastage,
//     DisposeType.destruction => context.l10n.waste_action_destruction,
//   };
// }

// sealed class MasterWasteState {
//   const MasterWasteState();
// }

// final class MasterWasteUninitialized extends MasterWasteState {
//   const MasterWasteUninitialized();
// }

// final class MasterWasteLoading extends MasterWasteState {
//   const MasterWasteLoading();
// }

// final class MasterWastePatientSelection extends MasterWasteState {
//   const MasterWastePatientSelection({required this.cabinId});
//   final int cabinId;
// }

// /// FAZ 2 — hasta seçili, kalem listesi geldi. Donanım/kuyruk YOK, bu yüzden
// /// ayrı bir Executing fazı hiç yok — submit doğrudan buradan yapılır.
// final class MasterWasteMedicineSelection extends MasterWasteState {
//   const MasterWasteMedicineSelection({
//     required this.cabinId,
//     required this.hospitalization,
//     required this.items,
//     this.type = DisposeType.wastage,
//     this.selectedItemIds = const {},
//     this.amounts = const {},
//     this.search = '',
//     this.isSubmitting = false,
//   });

//   final int cabinId;
//   final Hospitalization hospitalization;
//   final List<DisposableItem> items;
//   final DisposeType type;
//   final Set<int> selectedItemIds;
//   final Map<int, double> amounts;
//   final String search;
//   final bool isSubmitting;

//   List<DisposableItem> get visibleItems {
//     if (search.isEmpty) return items;
//     final q = search.toLowerCase();
//     return items.where((i) => (i.medicine?.name ?? '').toLowerCase().contains(q)).toList();
//   }

//   List<DisposableItem> get selectedItems => items.where((i) => selectedItemIds.contains(i.id)).toList();

//   double amountFor(int itemId) => amounts[itemId] ?? 0;

//   double maxAmountFor(int itemId) => items.firstWhereOrNull((i) => i.id == itemId)?.dosePiece.toDouble() ?? 0;

//   bool get canStart => !isSubmitting && selectedItemIds.isNotEmpty && selectedItems.every((i) => amountFor(i.id) > 0);

//   MasterWasteMedicineSelection copyWith({
//     List<DisposableItem>? items,
//     DisposeType? type,
//     Set<int>? selectedItemIds,
//     Map<int, double>? amounts,
//     String? search,
//     bool? isSubmitting,
//   }) {
//     return MasterWasteMedicineSelection(
//       cabinId: cabinId,
//       hospitalization: hospitalization,
//       items: items ?? this.items,
//       type: type ?? this.type,
//       selectedItemIds: selectedItemIds ?? this.selectedItemIds,
//       amounts: amounts ?? this.amounts,
//       search: search ?? this.search,
//       isSubmitting: isSubmitting ?? this.isSubmitting,
//     );
//   }
// }

// final class MasterWasteError extends MasterWasteState {
//   const MasterWasteError({required this.failure, required this.previousState});
//   final CabinOperationFailure failure;
//   final MasterWasteState previousState;
// }

// extension MasterWasteStateX on MasterWasteState {
//   int get cabinId => switch (this) {
//     MasterWastePatientSelection(:final cabinId) => cabinId,
//     MasterWasteMedicineSelection(:final cabinId) => cabinId,
//     MasterWasteError(:final previousState) => previousState.cabinId,
//     _ => 0,
//   };

//   Hospitalization? get hospitalization => switch (this) {
//     MasterWasteMedicineSelection(:final hospitalization) => hospitalization,
//     MasterWasteError(:final previousState) => previousState.hospitalization,
//     _ => null,
//   };
// }
