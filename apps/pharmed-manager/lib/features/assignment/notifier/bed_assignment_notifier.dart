import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/core/core.dart';

class BedAssignmentNotifier extends ChangeNotifier with ApiRequestMixin {
  final GetBedAssignmentsUseCase _getBedAssignmentsUseCase;
  final CreateBedAssignmentUseCase _createBedAssignmentUseCase;
  final UpdateBedAssignmentUseCase _updateBedAssignmentUseCase;
  final DeleteBedAssignmentUseCase _deleteBedAssignmentUseCase;
  final GetServiceUseCase _getServiceUseCase;

  BedAssignmentNotifier({
    required GetBedAssignmentsUseCase getBedAssignmentsUseCase,
    required CreateBedAssignmentUseCase createBedAssignmentUseCase,
    required UpdateBedAssignmentUseCase updateBedAssignmentUseCase,
    required DeleteBedAssignmentUseCase deleteBedAssignmentUseCase,
    required GetServiceUseCase getServiceUseCase,
  }) : _getBedAssignmentsUseCase = getBedAssignmentsUseCase,
       _createBedAssignmentUseCase = createBedAssignmentUseCase,
       _updateBedAssignmentUseCase = updateBedAssignmentUseCase,
       _deleteBedAssignmentUseCase = deleteBedAssignmentUseCase,
       _getServiceUseCase = getServiceUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();
  OperationKey deleteOp = OperationKey.delete();
  OperationKey fetchServicesOp = OperationKey.fetch();

  Cabin? _cabin;
  Cabin? get cabin => _cabin;

  List<BedAssignment> _assignments = [];
  List<BedAssignment> get assigngments => _assignments;

  List<MobileSlotVisual> _slots = [];
  List<MobileSlotVisual> get slots => _slots;

  MobileSlotVisual? _selectedSlot;
  MobileSlotVisual? get selectedSlot => _selectedSlot;

  MobileCellCoord? _selectedCell;
  MobileCellCoord? get selectedCell => _selectedCell;

  List<MobileDrawerSlot> _mobileSlots = [];
  List<MobileDrawerSlot> get mobileSlots => _mobileSlots;

  BedAssignment? _currentAssignment;
  BedAssignment? get currentAssignment => _currentAssignment;

  Station? _station;
  Station? get station => _station;

  List<HospitalService> get services {
    if (_station == null) {
      return [];
    }

    return [
      if (_station!.service != null) _station!.service!,
      ..._station!.services.where((s) => s.id != _station!.service?.id),
    ];
  }

  HospitalService? _service;
  HospitalService? get service => _service;

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  Room? _room;
  Room? get room => _room;

  List<Bed> _beds = [];
  List<Bed> get beds => _beds;

  Bed? _bed;
  Bed? get bed => _bed;

  void init({required CabinVisualizerData visualizer, required Cabin cabin, required Station station}) {
    _cabin = cabin;

    _slots = visualizer.slots.whereType<MobileSlotVisual>().toList();
    _mobileSlots = visualizer.mobileSlots;
    _station = station;

    notifyListeners();

    _getAssignments(cabin);
  }

  Future<void> _getAssignments(Cabin cabin) async {
    if (cabin.id == null) {
      return;
    }

    await execute(
      fetchOp,
      operation: () => _getBedAssignmentsUseCase.call(),
      onData: (data) {
        _assignments = data;
        notifyListeners();
      },
    );
  }

  void selectSlot(MobileSlotVisual? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void selectCell(MobileCellCoord? coord) {
    if (_selectedSlot?.workingStatus != null) {
      return;
    }
    _selectedCell = coord;

    final cellId = _resolveCellId(mobileSlots: _mobileSlots, coord: coord!);
    final currentAssignment = cellId != null ? _assignments.firstWhereOrNull((a) => a.cellId == cellId) : null;
    _currentAssignment = currentAssignment;

    _bed = _currentAssignment?.bed;
    _room = _currentAssignment?.bed?.room;
    _service = _currentAssignment?.hospitalization?.physicalService ?? _currentAssignment?.bed?.room?.service;

    notifyListeners();
  }

  void selectService(HospitalService? service) async {
    _service = service;
    notifyListeners();

    final serviceId = _service?.id;
    if (serviceId == null) {
      return;
    }

    await execute(
      fetchServicesOp,
      operation: () => _getServiceUseCase.call(serviceId),
      onData: (data) {
        _service = data;
        _rooms = data?.rooms ?? [];
      },
    );
  }

  void selectRoom(Room? room) {
    _room = room;
    _beds = room?.beds ?? [];
    _bed = null;
    notifyListeners();
  }

  void selectBed(Bed? bed) {
    _bed = bed;
    notifyListeners();
  }

  Future<void> saveAssignment({Function(String? msg)? onSuccess, Function(String? msg)? onFailed}) async {
    final Future<Result> operation;

    final cellId = _resolveCellId(mobileSlots: _mobileSlots, coord: _selectedCell!);

    if (_currentAssignment != null) {
      final entity = _currentAssignment!.copyWith(bedId: _bed!.id);
      operation = _updateBedAssignmentUseCase.call(entity);
    } else {
      final entity = BedAssignment(cellId: cellId, bedId: bed!.id);
      operation = _createBedAssignmentUseCase.call(entity);
    }

    await executeVoid(
      submitOp,
      operation: () => operation,
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () {
        _selectedCell = null;
        onSuccess?.call(null);
        _getAssignments(_cabin!);
      },
    );
  }

  Future<void> deleteAssignment({Function(String? msg)? onSuccess, Function(String? msg)? onFailed}) async {
    if (_currentAssignment != null) {
      await executeVoid(
        deleteOp,
        operation: () => _deleteBedAssignmentUseCase.call(_currentAssignment!),
        onFailed: (error) => onFailed?.call(error.message),
        onSuccess: () {
          onSuccess?.call(null);
          _getAssignments(_cabin!);
        },
      );
    }
  }

  Map<MobileCellCoord, BedAssignment> get assignmentByCoord {
    final map = <MobileCellCoord, BedAssignment>{};
    for (final a in _assignments) {
      if (a.cellId == null) continue;
      final coord = _resolveCoord(mobileSlots: _mobileSlots, cellId: a.cellId!);
      if (coord != null) {
        map[coord] = a;
      } else {
        // atama var ama coord çözülemiyor → _mobileSlots eksik/yanlış
      }
    }
    return map;
  }

  MobileCellCoord? _resolveCoord({required List<MobileDrawerSlot> mobileSlots, required int cellId}) {
    for (final slot in mobileSlots) {
      for (int uIdx = 0; uIdx < slot.units.length; uIdx++) {
        final unit = slot.units[uIdx];
        for (int cIdx = 0; cIdx < unit.cells.length; cIdx++) {
          if (unit.cells[cIdx].id == cellId) {
            return (slot.id, uIdx, cIdx); // orderNo - 1 değil, index
          }
        }
      }
    }
    return null;
  }

  int? _resolveCellId({required List<MobileDrawerSlot> mobileSlots, required MobileCellCoord coord}) {
    final slot = mobileSlots.where((s) => s.id == coord.$1).firstOrNull;
    if (slot == null) return null;
    if (coord.$2 >= slot.units.length) return null;
    final unit = slot.units[coord.$2];
    if (coord.$3 >= unit.cells.length) return null;
    return unit.cells[coord.$3].id;
  }
}
