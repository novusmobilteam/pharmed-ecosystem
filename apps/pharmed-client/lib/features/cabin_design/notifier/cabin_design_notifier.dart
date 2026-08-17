// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class CabinDesignNotifier extends ChangeNotifier with ApiRequestMixin {
  CabinDesignNotifier({
    required GetCabinVisualizerDataUseCase getVisualizerData,
    required SetReturnDrawerUseCase setReturnDrawer,
  }) : _getVisualizerData = getVisualizerData,
       _setReturnDrawer = setReturnDrawer;

  final GetCabinVisualizerDataUseCase _getVisualizerData;
  final SetReturnDrawerUseCase _setReturnDrawer;

  final OperationKey initOp = OperationKey.custom('init');
  final OperationKey saveOp = OperationKey.custom('save-return-drawer');

  // ── State ────────────────────────────────────────────────────────

  Cabin? _cabin;
  Cabin? get cabin => _cabin;

  List<DrawerGroup> _groups = const [];
  List<DrawerGroup> get groups => _groups;

  int? _selectedSlotId;
  int? get selectedSlotId => _selectedSlotId;

  int? _currentReturnSlotId;
  int? get currentReturnSlotId => _currentReturnSlotId;

  /// Kaydedilmemiş toggle değişikliğinin uygulanacağı slot.
  int? _pendingReturnSlotId;
  int? get pendingReturnSlotId => _pendingReturnSlotId;

  /// true → pendingReturnSlotId iade çekmecesi OLACAK.
  /// false → pendingReturnSlotId iade çekmecesi OLMAKTAN ÇIKACAK
  /// (yalnızca pendingReturnSlotId == currentReturnSlotId iken anlamlıdır —
  /// toggle sadece o an iade çekmecesi olan slot üzerinde kapatılabilir).
  bool? _pendingReturnValue;
  bool? get pendingReturnValue => _pendingReturnValue;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isReady => _cabin != null;
  bool get isSaving => isLoading(saveOp);

  bool get hasPendingReturnChange => _pendingReturnSlotId != null && _pendingReturnValue != null;

  DrawerGroup? get selectedGroup => _groups.firstWhereOrNull((g) => g.slot.id == _selectedSlotId);

  int? get effectiveReturnSlotId {
    if (!hasPendingReturnChange) return _currentReturnSlotId;
    return _pendingReturnValue! ? _pendingReturnSlotId : null;
  }

  bool get canSave => hasPendingReturnChange && !isSaving;

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(int cabinId) async {
    await execute(
      initOp,
      operation: () => _getVisualizerData.call(cabinId: cabinId),
      onData: (data) {
        final groups = data.groups;
        final current = groups.firstWhereOrNull((g) => g.isReturnDrawer);
        final cabin = groups.firstOrNull?.slot.cabin;

        if (cabin == null) {
          _errorMessage = '...';
          notifyListeners();
          return;
        }

        _cabin = cabin;
        _groups = groups;
        _currentReturnSlotId = current?.slot.id;
        _selectedSlotId = groups.firstOrNull?.slot.id;
        notifyListeners();
      },
      onFailed: (e) {
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  // ── Aksiyonlar ───────────────────────────────────────────────────

  void selectSlot(int slotId) {
    if (!isReady) return;
    _selectedSlotId = slotId;
    notifyListeners();
  }

  void toggleReturnDrawer(bool value) {
    if (!isReady || isSaving) return;
    final slotId = _selectedSlotId;
    if (slotId == null) return;
    _pendingReturnSlotId = slotId;
    _pendingReturnValue = value;
    notifyListeners();
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> save() async {
    if (!canSave) return false;

    final slotId = _pendingReturnSlotId!;
    final value = _pendingReturnValue!;

    bool succeeded = false;

    await executeVoid(
      saveOp,
      operation: () => _setReturnDrawer.call(slotId, value),
      onSuccess: () {
        _currentReturnSlotId = value ? slotId : null;
        _pendingReturnSlotId = null;
        _pendingReturnValue = null;
        succeeded = true;
        notifyListeners();
      },
      onFailed: (e) {
        _errorMessage = e.message;
        notifyListeners();
      },
    );

    return succeeded;
  }
}
