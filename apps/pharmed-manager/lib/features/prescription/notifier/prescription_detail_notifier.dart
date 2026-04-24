import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../patient_order_review/domain/usecase/get_patient_prescription_history_usecase.dart';

// [SWREQ-MGR-RX-002] [IEC 62304 §5.5]
// Reçete detay paneli notifier'ı.
// hospitalization artık constructor'da değil, load() ile set edilir.
// Sınıf: Class B

class PrescriptionDetailNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<PrescriptionItem> {
  final SubmitPrescriptionActionUseCase _submitUseCase;
  final GetPatientPrescriptionHistoryUseCase _historyUseCase;

  PrescriptionDetailNotifier({
    required SubmitPrescriptionActionUseCase submitUseCase,
    required GetPatientPrescriptionHistoryUseCase historyUseCase,
  }) : _submitUseCase = submitUseCase,
       _historyUseCase = historyUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => _items;

  Map<int, List<PrescriptionItem>> get groupedPrescriptions => _items.groupedById;

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  /// Panel açıldığında çağrılır. Yeni hospitalization set edilir ve
  /// geçmiş yeniden yüklenir.
  void load(Hospitalization hosp) {
    if (_hospitalization?.id == hosp.id) return; // aynı hasta, tekrar fetch etme
    _hospitalization = hosp;
    _items = [];
    notifyListeners();
    getPatientPrescriptionHistory();
  }

  void getPatientPrescriptionHistory() async {
    final patientId = _hospitalization?.patient?.id;
    if (patientId == null) return;

    await execute(
      fetchOp,
      operation: () => _historyUseCase.call(patientId),
      onData: (history) {
        _items = history;
        notifyListeners();
      },
    );
  }

  Future<void> submit(
    PrescriptionActionType type,
    int prescriptionId,
    List<PrescriptionItem> items, {
    VoidCallback? onLoading,
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final ids = items.map((p) => p.id ?? 0).toList();
    onLoading?.call();

    await executeVoid(
      submitOp,
      operation: () =>
          _submitUseCase.call(SubmitActionParams(actionType: type, prescriptionId: prescriptionId, itemIds: ids)),
      onSuccess: () {
        onSuccess?.call('İşlem başarıyla tamamlandı.');
        getPatientPrescriptionHistory();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
