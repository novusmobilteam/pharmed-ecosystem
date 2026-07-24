// // Master kabin İLAÇ İADE ekranının state hiyerarşisi. MasterIntakeState'in
// // şahitsiz, IntakeType'sız hâli — ama check sonrası dallanma farklı: her
// // item'ın returnType'ına göre donanım gerekip gerekmediği ayrı ayrı belirlenir
// // (bkz. CheckMasterRefundStatusUseCase). Bu yüzden "hepsi tek kuyruğa girer"
// // varsayımı YOK — check sonrası item'lar iki gruba ayrılır:
// //   - donanımsız (toPharmacy/toReturnBox) → hemen completeRefund
// //   - donanımlı (toDrawer/toOrigin) → MasterRefundExecuting kuyruğuna girer
// //
// // Sınıf: Class B

// import 'package:pharmed_core/pharmed_core.dart';

// import '../../../intake/intake.dart';

// sealed class MasterRefundState {
//   const MasterRefundState();
// }

// final class MasterRefundUninitialized extends MasterRefundState {
//   const MasterRefundUninitialized();
// }

// final class MasterRefundLoading extends MasterRefundState {
//   const MasterRefundLoading();
// }

// final class MasterRefundPatientSelection extends MasterRefundState {
//   const MasterRefundPatientSelection({required this.cabinId});
//   final int cabinId;
// }

// final class MasterRefundMedicineSelection extends MasterRefundState {
//   const MasterRefundMedicineSelection({
//     required this.cabinId,
//     required this.hospitalization,
//     required this.items,
//     this.selectedItemIds = const {},
//     this.search = '',
//     this.checkStatuses = const {},
//     this.isChecking = false,
//   });

//   final int cabinId;
//   final Hospitalization hospitalization;
//   final List<MedicineIntakeItem> items;
//   final Set<int> selectedItemIds;
//   final String search;
//   final Map<int, IntakeCheckStatus> checkStatuses;
//   final bool isChecking;

//   List<MedicineIntakeItem> get visibleItems {
//     if (search.trim().isEmpty) return items;
//     final q = search.toLowerCase().trim();
//     return items.where((a) {
//       final name = a.medicine?.name?.toLowerCase() ?? '';
//       final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
//       return name.contains(q) || barcode.contains(q);
//     }).toList();
//   }

//   bool get canStart => selectedItemIds.isNotEmpty && !isChecking;
//   List<MedicineIntakeItem> get selectedItems => items.where((a) => selectedItemIds.contains(a.id)).toList();

//   MasterRefundMedicineSelection copyWith({
//     List<MedicineIntakeItem>? items,
//     Set<int>? selectedItemIds,
//     String? search,
//     Map<int, IntakeCheckStatus>? checkStatuses,
//     bool? isChecking,
//   }) {
//     return MasterRefundMedicineSelection(
//       cabinId: cabinId,
//       hospitalization: hospitalization,
//       items: items ?? this.items,
//       selectedItemIds: selectedItemIds ?? this.selectedItemIds,
//       search: search ?? this.search,
//       checkStatuses: checkStatuses ?? this.checkStatuses,
//       isChecking: isChecking ?? this.isChecking,
//     );
//   }
// }

// // MasterRefundExecuting / MasterRefundError — execution'a geçince ele alacağız.
