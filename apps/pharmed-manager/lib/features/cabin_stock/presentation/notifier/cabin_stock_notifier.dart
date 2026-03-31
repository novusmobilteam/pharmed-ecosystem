import 'package:flutter/material.dart';

import '../../../../core/core.dart';

import '../../../cabin/shared/widgets/cabin_editor/cabin_editor_mixin.dart';

// class CabinStockNotifier extends ChangeNotifier with ApiRequestMixin, CabinEditorMixin {
//   @override
//   final GetCabinsUseCase cabinsUseCase;
//   @override
//   final GetCabinLayoutUseCase layoutUseCase;

//   final GetCabinAssignmentsWithCabinUseCase _getAssignmentsUseCase;
//   final GetCabinsByStationUseCase _getCabinsByStationUseCase;
//   final Function(List<CabinAssignment> assignments)? onDataLoaded;

//   CabinStockNotifier({
//     required this.cabinsUseCase,
//     required this.layoutUseCase,
//     required GetCabinAssignmentsWithCabinUseCase getAssignmentsUseCase,
//     required GetCabinsByStationUseCase getCabinsByStationUseCase,
//     this.onDataLoaded,
//   }) : _getAssignmentsUseCase = getAssignmentsUseCase,
//        _getCabinsByStationUseCase = getCabinsByStationUseCase;

//   OperationKey fetchOp = OperationKey.fetch();

//   List<CabinAssignment> _assignments = [];
//   List<CabinAssignment> get assignments => _assignments;

//   @override
//   void onLayoutRefreshed(List<DrawerGroup> groups) {
//     fetchAssignments();
//   }

//   /// Sayfa ilk açıldığında veya istasyon değiştiğinde tetiklenen ana metot
//   Future<void> initialize({int? stationId}) async {
//     await executeVoid(
//       fetchCabinOp,
//       operation: () async {
//         final res = stationId != null ? await _getCabinsByStationUseCase.call(stationId) : await cabinsUseCase.call();

//         return res.when(
//           error: (e) => Result.error(e),
//           ok: (data) async {
//             setCabins(data);
//             if (cabins.isNotEmpty) {
//               selectCabin(cabins.first);
//               await refreshLayout();
//             } else {
//               selectCabin(null);
//               _assignments = [];
//               notifyListeners();
//             }
//             return Result.ok(null);
//           },
//         );
//       },
//     );
//   }

//   Future<void> fetchAssignments() async {
//     if (selectedCabin == null) return;

//     final res = await _getAssignmentsUseCase.call(selectedCabin!.id!);
//     res.when(
//       ok: (data) {
//         _assignments = data;
//         onDataLoaded?.call(_assignments);
//         notifyListeners();
//       },
//       error: (e) => debugPrint("Stok çekme hatası: $e"),
//     );
//   }

//   Map<int, List<CabinAssignment>> get groupedSelectedAssignments {
//     final Map<int, List<CabinAssignment>> grouped = {};
//     for (var assignment in assignments) {
//       final mId = assignment.medicine?.id;

//       if (mId != null) {
//         grouped.putIfAbsent(mId, () => []).add(assignment);
//       }
//     }
//     return grouped;
//   }

//   /// Belirli bir ünitenin (Hücrenin) stok bilgisini döner
//   CabinAssignment getAssignmentForUnit(int? unitId) {
//     if (unitId == null) {
//       return CabinAssignment.empty(cabinId: selectedCabin?.id ?? 0, cabinDrawerId: unitId ?? 0);
//     }
//     try {
//       return _assignments.firstWhere((s) {
//         return s.cabinDrawerId == unitId;
//       });
//     } catch (e) {
//       // Eğer stok kaydı yoksa (hiç ilaç konulmamışsa) boş stok dön
//       return CabinAssignment.empty(cabinId: selectedCabin?.id ?? 0, cabinDrawerId: unitId);
//     }
//   }
// }
