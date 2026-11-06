import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

// [SWREQ-MGR-RX-002] [IEC 62304 §5.5]
// Reçete detay paneli notifier'ı.
// hospitalization artık constructor'da değil, load() ile set edilir.
//
// Kalemler tarih aralığıyla sunucudan çekilir; durum filtresi yerelde
// uygulanır (durum chip'lerinde sayılar gösterilebilsin diye). Liste GÜN
// bazında gruplanır — reçete numarası kalem satırında ve aksiyonlarda kalır:
// seçili kalemler işlem yapılırken reçeteye göre bölünür ([byPrescription]).
// Sınıf: Class B

class PrescriptionDetailNotifier extends ChangeNotifier with ApiRequestMixin {
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

  /// Durum filtresi uygulanmış kalemler.
  List<PrescriptionItem> get visibleItems => _type == null ? _items : _items.where((i) => i.status == _type).toList();

  /// Durum → kalem sayısı (tarih aralığındaki tüm kalemler üzerinden).
  Map<PrescriptionMovementType, int> get statusCounts {
    final counts = <PrescriptionMovementType, int>{};
    for (final i in _items) {
      final s = i.status;
      if (s != null) counts.update(s, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Map<int, List<PrescriptionItem>> get groupedPrescriptions => visibleItems.groupedById;

  /// Görünen kalemler gün bazında (bkz. [PrescriptionGrouping.groupedByDay]).
  List<({DateTime? day, List<PrescriptionItem> items})> get dayGroups => visibleItems.groupedByDay;

  /// Seçili kalemleri reçeteye göre böler — onay/iptal/red servisleri reçete
  /// bazında çalışır.
  Map<int, List<PrescriptionItem>> byPrescription(List<PrescriptionItem> items) {
    final map = <int, List<PrescriptionItem>>{};
    for (final i in items) {
      final id = i.prescriptionId;
      if (id == null) continue;
      map.putIfAbsent(id, () => []).add(i);
    }
    return map;
  }

  Hospitalization? _hospitalization;
  Hospitalization? get hospitalization => _hospitalization;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  PrescriptionMovementType? _type;
  PrescriptionMovementType? get type => _type;

  /// Panel açıldığında çağrılır. Yeni hospitalization set edilir ve
  /// geçmiş yeniden yüklenir.
  void load(Hospitalization hosp, {DateTimeRange? range}) {
    _type = PrescriptionMovementType.pendingApproval;
    _startDate = range?.start;
    _endDate = range?.end;
    _hospitalization = hosp;
    _items = [];
    notifyListeners();
    getPatientPrescriptionHistory();
  }

  /// Hızlı aralık: son [days] gün (bugün dahil). null → tüm tarihler.
  void selectQuickRange(int? days) {
    if (days == null) {
      _startDate = null;
      _endDate = null;
    } else {
      final now = DateTime.now();
      _endDate = now;
      _startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    }
    notifyListeners();
    getPatientPrescriptionHistory();
  }

  void selectStartDate(DateTime? date) {
    _startDate = date;
    getPatientPrescriptionHistory();
  }

  void selectEndDate(DateTime? date) {
    _endDate = date;
    getPatientPrescriptionHistory();
  }

  /// Yerel filtre — sunucuya yeniden gidilmez.
  void selectPrescriptionType(PrescriptionMovementType? type) {
    _type = type;
    notifyListeners();
  }

  Future<void> getPatientPrescriptionHistory() async {
    final patientId = _hospitalization?.patient?.id;
    if (patientId == null) return;

    await execute(
      fetchOp,
      operation: () => _historyUseCase.call(
        patientId,
        params: PagedQueryParams(
          startDate: _startDate?.startOfDay,
          endDate: _endDate?.endOfDay,
        ),
      ),
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
        // Metin, BuildContext'e erişimi olmayan notifier yerine görüntüleyen
        // view katmanında (l10n ile) çözülür — bkz. prescription_detail_panel.dart.
        onSuccess?.call(null);
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
        // Metin, BuildContext'e erişimi olmayan notifier yerine görüntüleyen
        // view katmanında (l10n ile) çözülür — bkz. prescription_detail_panel.dart.
        onSuccess?.call(null);
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
        // Metin, BuildContext'e erişimi olmayan notifier yerine görüntüleyen
        // view katmanında (l10n ile) çözülür — bkz. prescription_detail_panel.dart.
        onSuccess?.call(null);
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
