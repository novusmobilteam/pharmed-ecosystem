// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../core/providers/providers.dart';
// import 'master_refund_state.dart';

// final masterRefundNotifierProvider = NotifierProvider<MasterRefundNotifier, MasterRefundState>(
//   MasterRefundNotifier.new,
// );

// class MasterRefundNotifier extends Notifier<MasterRefundState> {
//   int _cabinId = 0;
//   Hospitalization? _hospitalization;

//   GetMasterRefundablesUseCase get _getRefundables => ref.read(getMasterRefundablesUseCaseProvider);
//   CheckMasterRefundStatusUseCase get _checkStatus => ref.read(checkMasterRefundStatusUseCaseProvider);
//   // CompleteRefundUseCase get _completeRefund => ...; — imza netleşince eklenecek

//   @override
//   MasterRefundState build() => const MasterRefundUninitialized();

//   Future<void> init(CabinVisualizerData data) async {
//     _cabinId = data.cabinId;
//     _hospitalization = null;
//     state = MasterRefundPatientSelection(cabinId: _cabinId);
//   }

//   Future<void> selectPatient(Hospitalization hospitalization) async {
//     _hospitalization = hospitalization;
//     state = const MasterRefundLoading();
//     await _loadItems();
//   }

//   Future<void> _loadItems() async {
//     final hospitalization = _hospitalization;
//     if (hospitalization == null) {
//       state = MasterRefundPatientSelection(cabinId: _cabinId);
//       return;
//     }

//     final result = await _getRefundables.call(hospitalization.id ?? 0);
//     result.when(
//       ok: (items) =>
//           state = MasterRefundMedicineSelection(cabinId: _cabinId, hospitalization: hospitalization, items: items),
//       error: (e) => state = MasterRefundError(
//         failure: CabinApiFailure(message: e.message),
//         previousState: MasterRefundMedicineSelection(
//           cabinId: _cabinId,
//           hospitalization: hospitalization,
//           items: const [],
//         ),
//       ),
//     );
//   }

//   void onSearchChanged(String value) {
//     final s = state;
//     if (s is! MasterRefundMedicineSelection || s.isChecking) return;
//     state = s.copyWith(search: value);
//   }

//   void toggleItem(int itemId) {
//     final s = state;
//     if (s is! MasterRefundMedicineSelection || s.isChecking) return;
//     final next = Set<int>.from(s.selectedItemIds);
//     next.contains(itemId) ? next.remove(itemId) : next.add(itemId);
//     state = s.copyWith(selectedItemIds: next);
//   }

//   void updateAmount(int itemId, double amount) {
//     final s = state;
//     if (s is! MasterRefundMedicineSelection || s.isChecking) return;
//     // TODO: eski MedicineRefundNotifier.changeAmount validasyonu (0'dan büyük,
//     // dosePiece'i aşamaz) buraya taşınacak — item bazlı hale getirilmesi lazım.
//     final items = s.items.map((it) => it.id == itemId ? it.copyWith(dosePiece: amount) : it).toList();
//     state = s.copyWith(items: items);
//   }

//   // startRefund() — CompleteRefundUseCase'in master/toplu imzasını bekliyor.
// }
