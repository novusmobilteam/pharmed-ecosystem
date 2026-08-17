// [SWREQ-UI-CAB-006]
// Hasta bazlı atama ekranı state yönetimi.
// Sadece mobil kabinde çalışır.
//
// Şu an desteklenen işlemler:
//   - Slot (çekmece) seç / toggle
//   - Hücre seç (MobileCellCoord)
//   - Yatış seç (dialogdan)
//
// Sınıf: Class B

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class BedAssignmentNotifier extends ChangeNotifier with ApiRequestMixin {
  BedAssignmentNotifier({
    required GetBedAssignmentsUseCase getAssignments,
    required CreateBedAssignmentUseCase createAssignment,
    required DeleteBedAssignmentUseCase deleteAssignment,
    required UpdateBedAssignmentUseCase updateAssignment,
    required GetCabinUseCase getCabin,
    required GetStationUseCase getStation,
    required GetServiceUseCase getService,
  }) : _getAssignments = getAssignments,
       _createAssignment = createAssignment,
       _deleteAssignment = deleteAssignment,
       _updateAssignment = updateAssignment,
       _getCabin = getCabin,
       _getStation = getStation,
       _getService = getService;

  final GetBedAssignmentsUseCase _getAssignments;
  final CreateBedAssignmentUseCase _createAssignment;
  final DeleteBedAssignmentUseCase _deleteAssignment;
  final UpdateBedAssignmentUseCase _updateAssignment;
  final GetCabinUseCase _getCabin;
  final GetStationUseCase _getStation;
  final GetServiceUseCase _getService;

  final OperationKey initOp = OperationKey.custom('init');
  final OperationKey saveOp = OperationKey.custom('save-assignment');
  final OperationKey serviceOp = OperationKey.custom('load-service');

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // ── Kabin/bağlam ─────────────────────────────────────────────────

  int _cabinId = 0;
  int get cabinId => _cabinId;

  List<MobileSlotVisual> _slots = const [];
  List<MobileSlotVisual> get slots => _slots;

  List<MobileDrawerSlot> _mobileSlots = const [];
  List<MobileDrawerSlot> get mobileSlots => _mobileSlots;

  List<BedAssignment> _assignments = const [];
  List<BedAssignment> get assignments => _assignments;

  /// In-memory servis listesi — oturum boyunca geçerli (istasyondan bir kez çekilir).
  List<HospitalService> _services = const [];
  List<HospitalService> get services => _services;

  // ── Seçim ────────────────────────────────────────────────────────

  MobileSlotVisual? _selectedSlot;
  MobileSlotVisual? get selectedSlot => _selectedSlot;
  int? get selectedSlotId => _selectedSlot?.slotId;

  MobileCellCoord? _selectedCell;
  MobileCellCoord? get selectedCell => _selectedCell;

  BedAssignment? _existingAssignment;
  BedAssignment? get existingAssignment => _existingAssignment;

  HospitalService? _selectedService;
  HospitalService? get selectedService => _selectedService;

  List<Room> _rooms = const [];
  List<Room> get rooms => _rooms;

  Room? _selectedRoom;
  Room? get selectedRoom => _selectedRoom;

  List<Bed> _beds = const [];
  List<Bed> get beds => _beds;

  Bed? _selectedBed;
  Bed? get selectedBed => _selectedBed;

  // ── Hata ─────────────────────────────────────────────────────────

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Başarı bildirimi (bir kerelik banner) ───────────────────────

  bool _isCreated = false;
  bool _showSuccess = false;
  bool get showSuccess => _showSuccess;
  bool get isCreated => _isCreated;

  // ── Türetilen ────────────────────────────────────────────────────

  bool get isCellSelected => _selectedCell != null;
  bool get isSlotSelected => _selectedSlot != null;
  bool get canSave => _selectedBed != null;
  bool get isAssigned => _existingAssignment != null;

  Map<MobileCellCoord, BedAssignment> get assignmentByCoord {
    final map = <MobileCellCoord, BedAssignment>{};
    for (final a in _assignments) {
      if (a.cellId == null) continue;
      final coord = _resolveCoord(cellId: a.cellId!);
      if (coord != null) map[coord] = a;
    }
    return map;
  }

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    _slots = data.slots.whereType<MobileSlotVisual>().toList();
    _notify();

    await execute(
      initOp,
      operation: () async {
        // 1. Kabin + atamalar paralel çek
        final results = await Future.wait([_getCabin.call(data.cabinId), _getAssignments.call(data.cabinId)]);
        final cabinResult = results[0] as Result<Cabin?>;
        final assignmentResult = results[1] as Result<List<BedAssignment>>;

        final cabin = cabinResult.when(ok: (c) => c, error: (_) => null);
        if (cabin == null || cabin.stationId == null) {
          return Result<List<BedAssignment>>.error(
            CustomException(message: contextlessL10n().assignment_error_stationLoadFailed),
          );
        }

        // 2. İstasyon çek → services
        final stationResult = await _getStation.call(cabin.stationId!);
        stationResult.when(
          ok: (station) => _services = station?.services ?? const [],
          error: (_) => _services = const [],
        );

        return assignmentResult;
      },
      onData: (assignments) {
        _mobileSlots = data.mobileSlots;
        _assignments = assignments;
        _notify();
      },
    );
  }

  // ── Seçim ────────────────────────────────────────────────────────

  void onSlotTap(MobileSlotVisual slot) {
    if (_selectedSlot?.slotId == slot.slotId) {
      clearSelection();
      return;
    }

    _selectedSlot = slot;
    _clearCellSelection();
    _notify();
  }

  void onCellTap(MobileCellCoord coord) {
    final selectedSlot = _selectedSlot;
    if (selectedSlot == null) return;

    if (_selectedCell == coord) {
      _clearCellSelection();
      _notify();
      return;
    }

    final cellId = _resolveCellId(coord: coord);
    final existingAssignment = cellId != null ? _assignments.firstWhereOrNull((a) => a.cellId == cellId) : null;

    _selectedCell = coord;
    _existingAssignment = existingAssignment;
    _selectedBed = existingAssignment?.bed;
    _selectedRoom = existingAssignment?.bed?.room;
    _selectedService = existingAssignment?.hospitalization?.physicalService ?? existingAssignment?.bed?.room?.service;
    _rooms = const [];
    _beds = const [];
    _notify();
  }

  /// Seçimi tamamen temizler.
  void clearSelection() {
    _selectedSlot = null;
    _clearCellSelection();
    _notify();
  }

  void _clearCellSelection() {
    _selectedCell = null;
    _existingAssignment = null;
    _selectedService = null;
    _rooms = const [];
    _selectedRoom = null;
    _beds = const [];
    _selectedBed = null;
  }

  Future<void> onServiceSelected(HospitalService? service) async {
    if (!isCellSelected) return;

    // Önce servisi seç, oda+yatak sıfırla, loading göster
    _selectedService = service;
    _rooms = const [];
    _selectedRoom = null;
    _beds = const [];
    _selectedBed = null;
    _notify();

    await execute(
      serviceOp,
      operation: () => _getService.call(service?.id! ?? 0),
      onData: (fullService) {
        if (!isCellSelected) return;
        _selectedService = fullService ?? service;
        _rooms = fullService?.rooms ?? const [];
        _selectedRoom = null;
        _beds = const [];
        _selectedBed = null;
        _notify();
      },
      onFailed: (e) {
        _errorMessage = e.message;
        _notify();
      },
    );
  }

  void onRoomSelected(Room? room) {
    if (!isCellSelected) return;
    _selectedRoom = room;
    _beds = room?.beds ?? const [];
    _selectedBed = null;
    _notify();
  }

  void onBedSelected(Bed? bed) {
    if (!isCellSelected) return;
    _selectedBed = bed;
    _notify();
  }

  // ── Kaydet / Sil ─────────────────────────────────────────────────

  Future<void> saveAssignment() async {
    if (!isCellSelected || !canSave) return;
    final coord = _selectedCell;
    final bed = _selectedBed;
    if (coord == null || bed == null) return;

    final cellId = _resolveCellId(coord: coord);
    if (cellId == null) {
      _errorMessage = contextlessL10n().assignment_cellNotFoundError;
      _notify();
      return;
    }

    final existing = _existingAssignment;

    await executeVoid(
      saveOp,
      operation: () {
        if (existing != null) {
          final entity = existing.copyWith(bedId: bed.id);
          return _updateAssignment.call(entity);
        }
        final entity = BedAssignment(cellId: cellId, bedId: bed.id);
        return _createAssignment.call(entity);
      },
      onSuccess: () => unawaited(_refreshAssignments(isCreated: true)),
      onFailed: (e) {
        _errorMessage = e.message;
        _notify();
      },
    );
  }

  Future<void> deleteAssignment() async {
    if (!isCellSelected) return;
    final existing = _existingAssignment;
    if (existing == null) return;

    await executeVoid(
      saveOp,
      operation: () => _deleteAssignment.call(existing),
      onSuccess: () => unawaited(_refreshAssignments(isCreated: false)),
      onFailed: (e) {
        _errorMessage = e.message;
        _notify();
      },
    );
  }

  Future<void> _refreshAssignments({required bool isCreated}) async {
    await execute(
      initOp,
      operation: () => _getAssignments.call(_cabinId),
      onData: (assignments) {
        _assignments = assignments;
        _isCreated = isCreated;
        _showSuccess = true;
        _notify();
      },
      onFailed: (e) {
        _errorMessage = e.message;
        _notify();
      },
    );
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notify();
  }

  void dismissSuccess() {
    if (!_showSuccess) return;
    _showSuccess = false;

    // Başarı sonrası hücre seçili kalır — mevcut atamayı yeniden çözüp
    // formu güncel veriyle tazeler (orijinaldeki dismissSuccess davranışı).
    final coord = _selectedCell;
    if (coord != null) {
      final cellId = _resolveCellId(coord: coord);
      final existingAssignment = cellId != null ? _assignments.firstWhereOrNull((a) => a.cellId == cellId) : null;
      _existingAssignment = existingAssignment;
      _selectedBed = existingAssignment?.bed;
      _selectedRoom = existingAssignment?.bed?.room;
      _selectedService = existingAssignment?.hospitalization?.physicalService ?? existingAssignment?.bed?.room?.service;
    }
    _notify();
  }

  int? _resolveCellId({required MobileCellCoord coord}) {
    final slot = _mobileSlots.where((s) => s.id == coord.$1).firstOrNull;
    if (slot == null) return null;
    if (coord.$2 >= slot.units.length) return null;
    final unit = slot.units[coord.$2];
    if (coord.$3 >= unit.cells.length) return null;
    return unit.cells[coord.$3].id;
  }

  MobileCellCoord? _resolveCoord({required int cellId}) {
    for (final slot in _mobileSlots) {
      for (int uIdx = 0; uIdx < slot.units.length; uIdx++) {
        final unit = slot.units[uIdx];
        for (int cIdx = 0; cIdx < unit.cells.length; cIdx++) {
          if (unit.cells[cIdx].id == cellId) {
            return (slot.id, uIdx, cIdx);
          }
        }
      }
    }
    return null;
  }
}
