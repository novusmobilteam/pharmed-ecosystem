import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../prescription.dart';

// [SWREQ-MGR-RX-002] [IEC 62304 §5.5]
// Reçete detay paneli notifier'ı.
// hospitalization artık constructor'da değil, load() ile set edilir.
// Sınıf: Class B

class PrescriptionDetailNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<PrescriptionItem> {
  final SubmitPrescriptionActionUseCase _submitUseCase;
  final GetPatientPrescriptionHistoryUseCase _historyUseCase;
  final AssignRfidTagUseCase _assignRfidTagUseCase;
  final DeleteRfidTagUseCase _deleteRfidTagUseCase;
  final CheckAndApprovePrescriptionUseCase _checkAndApproveUseCase;

  PrescriptionDetailNotifier({
    required SubmitPrescriptionActionUseCase submitUseCase,
    required GetPatientPrescriptionHistoryUseCase historyUseCase,
    required AssignRfidTagUseCase assignRfidTagUseCase,
    required DeleteRfidTagUseCase deleteRfidTagUseCase,
    required CheckAndApprovePrescriptionUseCase checkAndApproveUseCase,
  }) : _submitUseCase = submitUseCase,
       _historyUseCase = historyUseCase,
       _assignRfidTagUseCase = assignRfidTagUseCase,
       _deleteRfidTagUseCase = deleteRfidTagUseCase,
       _checkAndApproveUseCase = checkAndApproveUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();
  OperationKey rfidOp = OperationKey.custom('rfid');

  List<PrescriptionItem> _items = [];
  List<PrescriptionItem> get items => _items;

  Map<int, List<PrescriptionItem>> get groupedPrescriptions => _items.groupedById;

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  /// Panel açıldığında çağrılır. Yeni hospitalization set edilir ve
  /// geçmiş yeniden yüklenir.
  void load(Hospitalization hosp) {
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

  /// Reçete kalemine RFID etiketi atar.
  /// Akış: reconnect → scan → en yüksek RSSI → API persist → local güncelleme
  Future<void> assignRfidTag(
    PrescriptionItem item, {
    Function(String epc)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    await execute(
      rfidOp,
      operation: () => _assignRfidTagUseCase.call(item.id!),
      onData: (epc) {
        _updateItem(item.id!, (i) => i.copyWith(rfidTag: epc));
        onSuccess?.call(epc);
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  /// Reçete kalemine atanmış RFID etiketini siler.
  /// Başarılıysa local liste güncellenir, API çağrısına gerek kalmaz.
  Future<void> deleteRfidTag(
    PrescriptionItem item, {
    VoidCallback? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    await execute(
      rfidOp,
      operation: () => _deleteRfidTagUseCase.call(item.id!),
      onData: (_) {
        _updateItem(item.id!, (i) => i.copyWith(clearRfidTag: true));
        onSuccess?.call();
      },
      onFailed: (error) => onFailed?.call(error.message),
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

  /// Check + approve iki adımlı onay akışı.
  ///
  /// Check hata dönerse [onCheckWarning] tetiklenir — kullanıcıya mesaj gösterilir.
  /// Kullanıcı "Devam Et" derse [approveOnly] çağrılır.
  /// Check başarılıysa doğrudan approve çalışır.
  Future<void> checkAndApprove(
    int prescriptionId,
    List<PrescriptionItem> items, {
    Function(String message, VoidCallback onContinue)? onCheckWarning,
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final ids = items.map((p) => p.id ?? 0).toList();

    await executeVoid(
      submitOp,
      operation: () => _checkAndApproveUseCase.call(prescriptionId, ids),
      onSuccess: () {
        onSuccess?.call('Reçete başarıyla onaylandı.');
        getPatientPrescriptionHistory();
      },
      onFailed: (error) {
        if (error is CheckException) {
          // Check uyarısı — kullanıcıya göster, onay verirse approve çalışır
          onCheckWarning?.call(
            error.message,
            () => approveOnly(prescriptionId, items, onSuccess: onSuccess, onFailed: onFailed),
          );
        } else {
          onFailed?.call(error.message);
        }
      },
    );
  }

  /// Kullanıcı check uyarısını onayladıktan sonra çağrılır.
  Future<void> approveOnly(
    int prescriptionId,
    List<PrescriptionItem> items, {
    Function(String? message)? onSuccess,
    Function(String? message)? onFailed,
  }) async {
    final ids = items.map((p) => p.id ?? 0).toList();

    await executeVoid(
      submitOp,
      operation: () => _checkAndApproveUseCase.approveOnly(prescriptionId, ids),
      onSuccess: () {
        onSuccess?.call('Reçete başarıyla onaylandı.');
        getPatientPrescriptionHistory();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void _updateItem(int itemId, PrescriptionItem Function(PrescriptionItem) update) {
    _items = _items.map((i) => i.id == itemId ? update(i) : i).toList();
    notifyListeners();
  }
}
