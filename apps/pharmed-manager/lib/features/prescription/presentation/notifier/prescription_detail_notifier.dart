import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../../../patient_order_review/domain/usecase/get_patient_prescription_history_usecase.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../../prescription/domain/utils/prescription_grouping.dart';
import '../../domain/usecase/submit_prescription_action_usecase.dart';

class PrescriptionDetailNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<PrescriptionItem> {
  final Hospitalization _hospitalization;
  final SubmitPrescriptionActionUseCase _submitUseCase;
  final GetPatientPrescriptionHistoryUseCase _historyUseCase;

  PrescriptionDetailNotifier({
    required SubmitPrescriptionActionUseCase submitUseCase,
    required GetPatientPrescriptionHistoryUseCase historyUseCase,
    required Hospitalization hospitalization,
  }) : _historyUseCase = historyUseCase,
       _submitUseCase = submitUseCase,
       _hospitalization = hospitalization;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => _items;

  Map<int, List<PrescriptionItem>> get groupedPrescriptions => _items.groupedById;
  Map<int, List<PrescriptionItem>> get filteredGroupedPrescriptions => _items.filteredGrouped(searchQuery);

  void getPatientPrescriptionHistory() async {
    final patientId = _hospitalization.patient?.id;
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
    Function()? onLoading,
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
