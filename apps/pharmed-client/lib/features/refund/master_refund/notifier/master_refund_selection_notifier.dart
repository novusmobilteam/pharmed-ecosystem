import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/usecase_providers.dart';

final masterRefundSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterRefundSelectionNotifier>((ref) {
  return MasterRefundSelectionNotifier(
    getMasterRefundablesUseCase: ref.read(getMasterRefundablesUseCaseProvider),
    checkMasterRefundStatusUseCase: ref.read(checkMasterRefundStatusUseCaseProvider),
    completeRefundUseCase: ref.read(completeRefundUseCaseProvider),
  );
});

class MasterRefundSelectionNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetMasterRefundablesUseCase _getMasterRefundablesUseCase;
  final CheckMasterRefundStatusUseCase _checkMasterRefundStatusUseCase;
  final CompleteRefundUseCase _completeRefundUseCase;

  MasterRefundSelectionNotifier({
    required GetMasterRefundablesUseCase getMasterRefundablesUseCase,
    required CheckMasterRefundStatusUseCase checkMasterRefundStatusUseCase,
    required CompleteRefundUseCase completeRefundUseCase,
  }) : _getMasterRefundablesUseCase = getMasterRefundablesUseCase,
       _checkMasterRefundStatusUseCase = checkMasterRefundStatusUseCase,
       _completeRefundUseCase = completeRefundUseCase;

  final OperationKey fetchRefundablesOp = OperationKey.custom('fetch-refundables');
  final OperationKey checkOp = OperationKey.custom('check-op');
  final OperationKey completeOp = OperationKey.custom('complete-op');
  final OperationKey startRefundOp = OperationKey.custom('start-refund');

  StationCabinsContext? _stationContext;

  // ── Hasta ─────────────────────────────────────────────────────────────────

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  // ── İade edilebilir kalemler ──────────────────────────────────────────────

  List<CabinTargetedPrescriptionItem> _refundables = const [];
  List<CabinTargetedPrescriptionItem> get refundables => _refundables;

  bool get isFetchingRefundables => isLoading(fetchRefundablesOp);
  bool get isFetchFailed => isFailed(fetchRefundablesOp);

  // ── Seçim ─────────────────────────────────────────────────────────────────

  /// Seçim nesne eşitliği yerine id ile tutulur — liste yeniden çekildiğinde
  /// instance'lar değişse bile seçim tutarlı kalır.
  final Set<int> _selectedItemIds = {};

  List<CabinTargetedPrescriptionItem> get selectedItems =>
      _refundables.where((it) => _selectedItemIds.contains(it.id)).toList(growable: false);

  bool get hasSelection => _selectedItemIds.isNotEmpty;

  bool isSelected(CabinTargetedPrescriptionItem item) => _selectedItemIds.contains(item.id);

  final Map<int, double> _returnQuantities = {};

  /// Hem completeDirectRefund'un (donanımsız) hem startRefund'un (donanımlı)
  /// per-item check/complete durumunu paylaşır.
  final Map<int, RefundCheckStatus> _itemStatuses = {};
  Map<int, RefundCheckStatus> get itemStatuses => Map.unmodifiable(_itemStatuses);

  // ── Başlatma ──────────────────────────────────────────────────────────────

  /// Check'ten geçmiş, execution'a devredilecek kalemler.
  List<RefundableItem> _checkedItems = const [];
  List<RefundableItem> get checkedItems => _checkedItems;

  // ── Karekod kapısı ────────────────────────────────────────────────────────

  /// Check'ten geçen kalemlerden alımda karekod okutulmuş olanların
  /// gereksinimleri. View bunlar için sırayla QrScanDialog açar; hepsi
  /// gönderilmeden execution başlatılmaz.
  List<RefundQrRequirement> _qrRequirements = const [];
  List<RefundQrRequirement> get qrRequirements => _qrRequirements;

  /// Doğrulanan kodlar (itemId → ham değerler). Şimdilik backend'e
  /// gönderilmiyor; iz sürme için log'a yazılır.
  final Map<int, List<String>> _scannedQrCodes = {};

  /// startRefund döngüsünün TAMAMINI kapsar. Eskiden `isLoading(startRefundOp)`
  /// kullanılıyordu — op her item'da açılıp kapandığı için item'lar arasında
  /// buton bir anlığına yeniden aktif oluyordu.
  bool _isStartingRefund = false;
  bool get isStartingRefund => _isStartingRefund;

  bool get canStart => hasSelection && !_isStartingRefund;

  // ── Kalem sınıflandırması (view ve notifier aynı kuralı kullanır) ─────────

  ReturnType? _returnTypeOf(CabinTargetedPrescriptionItem item) =>
      item.medicine?.when(drug: (d) => d.returnType, consumable: (_) => null);

  bool isRefundable(CabinTargetedPrescriptionItem item) =>
      (item.medicine?.canRefundable ?? false) && item.isCollectedAtCurrentStation;

  bool requiresHardware(CabinTargetedPrescriptionItem item) =>
      item.medicine?.returnType?.requiresCabinHardware ?? false;

  /// Yalnızca donanımlı iade kalemleri checkbox ile seçilip kuyruğa girebilir.
  bool isSelectable(CabinTargetedPrescriptionItem item) => isRefundable(item) && requiresHardware(item);

  /// Donanımsız kalemler kart üzerindeki "İade Et" butonuyla tek tek iade edilir.
  bool isDirectRefundable(CabinTargetedPrescriptionItem item) => isRefundable(item) && !requiresHardware(item);

  // ── Miktar ────────────────────────────────────────────────────────────────

  num amountFor(int itemId) {
    final item = _refundables.firstWhereOrNull((it) => it.id == itemId);
    return _returnQuantities[itemId] ?? item?.dosePiece ?? 0;
  }

  /// Uygulanmış dozdan (item.dosePiece) fazlası iade edilemez.
  num maxAmountFor(int itemId) {
    final item = _refundables.firstWhereOrNull((it) => it.id == itemId);
    return item?.dosePiece ?? 0;
  }

  void updateAmount(int itemId, double amount, {void Function(String message)? onFailed}) {
    if (amount <= 0) {
      onFailed?.call(contextlessL10n().refund_error_amountZero);
      return;
    }
    if (amount > maxAmountFor(itemId)) {
      onFailed?.call(contextlessL10n().refund_error_amountExceeded);
      return;
    }
    _returnQuantities[itemId] = amount;
    notifyListeners();
  }

  // ── Yaşam döngüsü ─────────────────────────────────────────────────────────

  void init(StationCabinsContext ctx) {
    _stationContext = ctx;
  }

  /// Hasta değişimi, seçim temizleme ve execution sonrası yenilemenin ortak
  /// sıfırlaması. Eskiden miktarlar ve item durumları hiçbir yolda
  /// temizlenmiyordu — önceki iadenin başarı rozeti/miktarı kartta kalıyordu.
  void _resetItemState() {
    _selectedItemIds.clear();
    _returnQuantities.clear();
    _itemStatuses.clear();
    _checkedItems = const [];
    _qrRequirements = const [];
    _scannedQrCodes.clear();
  }

  void clearSelection() {
    _selectedHospitalization = null;
    _refundables = const [];
    _resetItemState();
    notifyListeners();
  }

  void selectHospitalization(Hospitalization hosp) {
    if (_isStartingRefund) return;

    if (_selectedHospitalization?.id == hosp.id) {
      clearSelection();
      return;
    }

    _selectedHospitalization = hosp;
    // Liste `= const []` ile değiştirilir, `.clear()` ile değil — use case'in
    // döndürdüğü liste değiştirilemez olabilir.
    _refundables = const [];
    _resetItemState();
    notifyListeners();
    _getRefundables();
  }

  Future<void> retryFetch() => _getRefundables();

  Future<void> _getRefundables() async {
    final hosp = _selectedHospitalization;
    final hospId = hosp?.id;
    if (hosp == null || hospId == null) return;

    await execute(
      fetchRefundablesOp,
      operation: () => _getMasterRefundablesUseCase.call(hospId),
      onData: (refundables) {
        // Hızlı hasta değişiminde geç gelen eski yanıt yeni hastanın
        // listesinin üzerine yazmasın.
        if (_selectedHospitalization?.id != hospId) return;
        _refundables = refundables;
        notifyListeners();
      },
    );
  }

  void toggleItem(CabinTargetedPrescriptionItem item) {
    if (_isStartingRefund || !isSelectable(item)) return;

    if (!_selectedItemIds.remove(item.id)) {
      _selectedItemIds.add(item.id);
    }
    notifyListeners();
  }

  // ── Donanımsız iade ───────────────────────────────────────────────────────

  /// Kart üzerindeki "İade Et" butonundan çağrılır — check + complete'i
  /// arka arkaya, donanıma hiç dokunmadan yürütür. Yalnızca
  /// requiresCabinHardware=false tipler (toPharmacy/toReturnBox) için.
  Future<void> completeDirectRefund(int itemId, {void Function(String? msg)? onFailed, VoidCallback? onSuccess}) async {
    final item = _refundables.firstWhereOrNull((it) => it.id == itemId);
    if (item == null || !isDirectRefundable(item)) return;
    if (_itemStatuses[itemId] is RefundCheckLoading) return;

    final returnType = _returnTypeOf(item);
    if (item.medicine?.id == null || returnType == null) {
      onFailed?.call(contextlessL10n().refund_error_genericCheckFailed);
      return;
    }

    final quantity = amountFor(itemId);
    _itemStatuses[itemId] = const RefundCheckLoading();
    notifyListeners();

    void fail(String? message) {
      _itemStatuses.remove(itemId);
      notifyListeners();
      onFailed?.call(message);
    }

    RefundableItem? checkedItem;
    var checkFailed = false;

    await execute(
      checkOp,
      operation: () => _checkMasterRefundStatusUseCase.call(
        item: RefundableItem(source: item, appliedQuantity: item.dosePiece, returnQuantity: quantity),
        returnType: returnType,
        quantity: quantity.toDouble(),
      ),
      onFailed: (error) {
        checkFailed = true;
        fail(error.message);
      },
      onData: (data) => checkedItem = data,
    );

    // Eskiden check hatasında da complete'e geçiliyordu ve `checkedItem!`
    // patlıyordu.
    final checked = checkedItem;
    if (checkFailed) return;
    if (checked == null || checked.returnType == null) {
      fail(contextlessL10n().refund_error_genericCheckFailed);
      return;
    }

    await executeVoid(
      completeOp,
      operation: () => _completeRefundUseCase.call(
        CompleteRefundParams(
          type: checked.returnType!,
          id: checked.id,
          quantity: (checked.returnQuantity ?? checked.appliedQuantity).toDouble(),
          cabinDrawerDetailId: checked.source.stock?.cabinDrawerDetailId,
        ),
      ),
      onFailed: (error) => fail(error.message),
      onSuccess: () {
        _itemStatuses.remove(itemId);
        _returnQuantities.remove(itemId);
        notifyListeners();
        onSuccess?.call();
        _getRefundables();
      },
    );
  }

  // ── Donanımlı iade başlatma ───────────────────────────────────────────────

  /// "İadeyi Başlat" — seçili (hep donanımlı) kalemler için check koşturur,
  /// execution'a devredilecek kalem listesini ve karekod gereksinimlerini
  /// üretir, ardından `onSuccess`'i BEKLER — View orada karekod kapısını
  /// yürütüp execution'ı başlatır. Böylece başlatma durumu (buton loading,
  /// seçim kilidi) karekod okutma boyunca da sürer.
  ///
  /// Herhangi bir kalemde hata olursa liste TAMAMEN atılır — yarım kalmış
  /// bir listeyle asla execution'a geçilmemeli. Karekod ve çekmece çözümü
  /// de dialog açılmadan ÖNCE kontrol edilir: kullanıcı karekodları okutup
  /// sonra "çekmece bulunamadı" hatası almamalı.
  Future<void> startRefund({void Function(String? msg)? onFailed, Future<void> Function()? onSuccess}) async {
    if (!canStart) return;

    final items = selectedItems;
    if (items.isEmpty) return;

    _isStartingRefund = true;
    _checkedItems = const [];
    _qrRequirements = const [];
    _scannedQrCodes.clear();
    notifyListeners();

    try {
      final checked = <RefundableItem>[];

      for (final item in items) {
        final (failed, message) = await _checkHardwareItem(item, into: checked);
        if (failed) {
          // Başarısız olan dışındaki kalemlerin "başarılı" durumu da düşer —
          // liste bütün olarak reddedildi.
          _itemStatuses.removeWhere((id, _) => id != item.id);
          onFailed?.call(message);
          return;
        }
      }

      final skipped = RefundJobMapper.build(checked).skipped;
      if (skipped.isNotEmpty) {
        _rejectStart(
          failedItemIds: {for (final i in skipped) i.id},
          message: contextlessL10n().refund_error_drawerNotResolved(skipped.length),
          onFailed: onFailed,
        );
        return;
      }

      final requirements = [for (final item in checked) ?_qrRequirementOf(item)];
      final unsatisfiable = requirements.firstWhereOrNull((r) => !r.isSatisfiable);
      if (unsatisfiable != null) {
        _rejectStart(
          failedItemIds: {unsatisfiable.itemId},
          message: contextlessL10n().refund_qr_insufficientIntakeCodes(
            unsatisfiable.medicineName,
            unsatisfiable.requiredCount,
            unsatisfiable.matcher.availableCount,
          ),
          onFailed: onFailed,
        );
        return;
      }

      _checkedItems = List.unmodifiable(checked);
      _qrRequirements = List.unmodifiable(requirements);
      await onSuccess?.call();
    } finally {
      _isStartingRefund = false;
      notifyListeners();
    }
  }

  /// Check'ler geçti ama liste bütün olarak başlatılamıyor — ilgili
  /// kalemler hatalı, diğerlerinin "başarılı" durumu düşer.
  void _rejectStart({required Set<int> failedItemIds, required String message, void Function(String? msg)? onFailed}) {
    _itemStatuses
      ..clear()
      ..addAll({for (final id in failedItemIds) id: RefundCheckFailed(message: message)});
    onFailed?.call(message);
  }

  /// Alımda karekod okutulduysa gereksinim; değilse null (karekodsuz iade).
  RefundQrRequirement? _qrRequirementOf(RefundableItem item) {
    final source = item.source;
    if (!source.requiresQrOnRefund) return null;

    final medicine = source.medicine;
    final boxCount = medicine is Drug ? medicine.boxCountOf(RefundJobMapper.quantityOf(item)) : 0;

    return RefundQrRequirement(
      itemId: item.id,
      medicineName: source.medicineName,
      // Alımda kod okutulmuş bir kalem dönüşüm 0 verse bile karekodsuz
      // geçemez — en az bir kutu istenir.
      requiredCount: boxCount < 1 ? 1 : boxCount,
      expectedGtin: medicine?.barcode,
      matcher: RefundQrCodeMatcher(source.intakeQrCodes),
    );
  }

  /// QrScanDialog'un onSubmit'i. Adet ve tekrar kontrolünü dialog yapar;
  /// burada her kodun bu kalemin alımında okutulmuş olması doğrulanır.
  /// Hata dönerse dialog açık kalır, kullanıcı hatalı satırı silip yeniden
  /// okutabilir.
  Future<Result<void>> submitRefundQrCodes(RefundQrRequirement requirement, List<Gs1Code> codes) async {
    final unmatched = requirement.matcher.firstUnmatched(codes);
    if (unmatched != null) {
      MedLogger.warn(
        unit: 'MasterRefundSelection',
        swreq: 'SWREQ-CLI-MREFUND-QR-001',
        message: 'İade karekodu alımda okutulanlar arasında değil',
        context: {'itemId': requirement.itemId, 'gtin': unmatched.gtin, 'serial': unmatched.serial},
      );
      return _qrRejected(contextlessL10n().refund_qr_notFromIntake(unmatched.serial ?? unmatched.raw));
    }

    _scannedQrCodes[requirement.itemId] = [for (final c in codes) c.raw];
    MedLogger.info(
      unit: 'MasterRefundSelection',
      swreq: 'SWREQ-CLI-MREFUND-QR-001',
      message: 'İade karekodları doğrulandı',
      context: {
        'itemId': requirement.itemId,
        'serials': [for (final c in codes) c.serial],
      },
    );
    return const Result.ok(null);
  }

  Result<void> _qrRejected(String message) => Result.error(CustomException(message: message));

  /// Kullanıcı karekod dialog'unu iptal etti — iade başlamaz, hiçbir
  /// çekmece açılmaz. Seçim korunur, kullanıcı tekrar başlatabilir.
  void cancelRefundStart() {
    _checkedItems = const [];
    _qrRequirements = const [];
    _scannedQrCodes.clear();
    _itemStatuses.clear();
    notifyListeners();
  }

  /// Tek bir donanımlı kalem için check. Başarılıysa kalemi [into]'ya ekler.
  Future<(bool failed, String? message)> _checkHardwareItem(
    CabinTargetedPrescriptionItem item, {
    required List<RefundableItem> into,
  }) async {
    final returnType = _returnTypeOf(item);
    if (item.medicine?.id == null || returnType == null) {
      final message = contextlessL10n().refund_error_genericCheckFailed;
      _itemStatuses[item.id] = RefundCheckFailed(message: message);
      return (true, message);
    }

    _itemStatuses[item.id] = const RefundCheckLoading();
    notifyListeners();

    final quantity = amountFor(item.id);
    var failed = false;
    String? message;

    await execute(
      startRefundOp,
      operation: () => _checkMasterRefundStatusUseCase.call(
        item: RefundableItem(source: item, appliedQuantity: item.dosePiece, returnQuantity: quantity),
        returnType: returnType,
        quantity: quantity.toDouble(),
      ),
      onData: (checked) {
        var resolved = checked;
        if (resolved.returnType == ReturnType.toDrawer) {
          final assignment = _resolveReturnDrawerAssignment(resolved);
          if (assignment == null) {
            failed = true;
            message = contextlessL10n().refund_error_returnDrawerNotDefined;
            return;
          }
          resolved = resolved.copyWith(resolvedTarget: assignment);
        }
        into.add(resolved);
      },
      onFailed: (error) {
        failed = true;
        message = error.message;
      },
    );

    _itemStatuses[item.id] = failed ? RefundCheckFailed(message: message) : const RefundCheckSuccess();
    notifyListeners();
    return (failed, message);
  }

  /// İade kutusuna giden kalemin hedef atamasını çözer. İade kutusu, iade
  /// çekmecesi tanımlı KÜBİK çekmecenin son sütunudur (veride tutulmaz —
  /// kural resolveDrawerGroupLayout'ta, çizimle aynı kaynak). Kutu kapaksız
  /// tek bölme olduğu için sütundaki herhangi bir göz çekmeceyi adreslemeye
  /// yeter; ilk göz seçilir. Çekmecenin normal gözleri alıma açık kalır ve
  /// burada HİÇBİR ZAMAN seçilmez.
  ///
  /// TODO(refund-multi-cabin): Çoklu kabinde iade kutusu olan İLK kabin
  /// seçiliyor (Map.values sırası). Kural netleşince güncellenecek.
  MedicineAssignment? _resolveReturnDrawerAssignment(RefundableItem checkedItem) {
    final ctx = _stationContext;
    if (ctx == null) return null;

    for (final data in ctx.cabinDataByCabinId.values) {
      for (final group in data.groups) {
        final layout = resolveDrawerGroupLayout(group);
        if (!layout.isReturnDrawer) continue;

        final unit = group.units.firstWhereOrNull((u) => layout.returnUnitIds.contains(u.id));
        if (unit == null) continue;

        final resolvedUnit = unit.drawerSlot == null ? unit.copyWith(drawerSlot: group.slot) : unit;
        final matchingStock = data.stocks.firstWhereOrNull((s) => s.cabinDrawerId == unit.id);
        final detail = matchingStock?.cabinDrawerDetail;

        return MedicineAssignment.empty(cabinDrawerId: unit.id ?? 0).copyWith(
          drawerUnit: resolvedUnit,
          medicine: checkedItem.medicine,
          cabinDrawerDetail: detail != null ? [detail] : null,
        );
      }
    }
    return null;
  }

  /// Execution kuyruğu bitince (root view'dan çağrılır) listeyi tazeler,
  /// seçim ve handoff state'ini sıfırlar.
  Future<void> refreshAfterExecution() async {
    _resetItemState();
    notifyListeners();
    await _getRefundables();
  }
}
