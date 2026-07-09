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

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../../assignment.dart';

final bedAssignmentNotifierProvider = NotifierProvider<BedAssignmentNotifier, BedAssignmentState>(
  BedAssignmentNotifier.new,
);

class BedAssignmentNotifier extends Notifier<BedAssignmentState> {
  @override
  BedAssignmentState build() => const BedAssignmentUninitialized();

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  CreateBedAssignmentUseCase get _createAssignment => ref.read(createBedAssignmentUseCaseProvider);
  DeleteBedAssignmentUseCase get _deleteAssignment => ref.read(deleteBedAssignmentUseCaseProvider);
  UpdateBedAssignmentUseCase get _updateAssignment => ref.read(updateBedAssignmentUseCaseProvider);
  GetCabinUseCase get _getCabin => ref.read(getCabinUseCaseProvider);
  GetStationUseCase get _getStation => ref.read(getStationUseCaseProvider);
  GetServiceUseCase get _getService => ref.read(getServiceUseCaseProvider);

  // In-memory servis listesi — oturum boyunca geçerli
  List<HospitalService> _services = const [];

  // Init
  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    state = BedAssignmentLoading(slots: slots, cabinId: data.cabinId);

    // 1. Kabin + atamalar paralel çek
    final results = await Future.wait([_getCabin.call(data.cabinId), _getAssignments.call(data.cabinId)]);

    final cabinResult = results[0] as Result<Cabin?>;
    final assignmentResult = results[1] as Result<List<BedAssignment>>;

    // 2. Kabin başarısız → hata
    final Cabin? cabin = cabinResult.when(ok: (data) => data, error: (_) => null);

    if (cabin == null || cabin.stationId == null) {
      state = BedAssignmentError(
        message: contextlessL10n().assignment_error_stationLoadFailed,
        previousState: BedAssignmentIdle(
          slots: slots,
          mobileSlots: data.mobileSlots,
          assignments: const [],
          cabinId: data.cabinId,
        ),
      );
      return;
    }

    // 3. İstasyon çek → services
    final stationResult = await _getStation.call(cabin.stationId!);

    stationResult.when(
      ok: (station) {
        _services = station?.services ?? const [];
      },
      error: (_) {
        _services = const [];
      },
    );

    // 4. Atama sonucunu işle
    state = assignmentResult.when(
      ok: (assignments) => BedAssignmentIdle(
        slots: slots,
        mobileSlots: data.mobileSlots,
        assignments: assignments,
        cabinId: data.cabinId,
      ),
      error: (e) => BedAssignmentError(
        message: e.message,
        previousState: BedAssignmentIdle(
          slots: slots,
          mobileSlots: data.mobileSlots,
          assignments: const [],
          cabinId: data.cabinId,
        ),
      ),
    );
  }

  // Slot seçimi
  void onSlotTap(MobileSlotVisual slot) {
    final current = state;
    final currentSlotId = switch (current) {
      BedAssignmentSlotSelected s => s.selectedSlotId,
      BedAssignmentCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId == slot.slotId) {
      state = BedAssignmentIdle(
        slots: state.slots,
        mobileSlots: state.mobileSlots,
        assignments: state.assignments,
        cabinId: current.cabinId,
      );
      return;
    }

    state = BedAssignmentSlotSelected(
      slots: state.slots,
      mobileSlots: state.mobileSlots,
      assignments: state.assignments,
      selectedSlot: slot,
      cabinId: current.cabinId,
    );
  }

  // Hücre seçimi
  void onCellTap(MobileCellCoord coord) {
    final current = state;
    final selectedSlot = state.selectedSlot;
    if (selectedSlot == null) return;

    if (current is BedAssignmentCellSelected && current.selectedCell == coord) {
      state = BedAssignmentSlotSelected(
        slots: state.slots,
        mobileSlots: state.mobileSlots,
        assignments: state.assignments,
        selectedSlot: selectedSlot,
        cabinId: current.cabinId,
      );
      return;
    }

    final cellId = _resolveCellId(mobileSlots: state.mobileSlots, coord: coord);
    final existingAssignment = cellId != null ? state.assignments.firstWhereOrNull((a) => a.cellId == cellId) : null;

    state = BedAssignmentCellSelected(
      slots: state.slots,
      mobileSlots: state.mobileSlots,
      assignments: state.assignments,
      selectedSlot: selectedSlot,
      selectedCell: coord,
      cabinId: current.cabinId,
      services: _services,
      existingAssignment: existingAssignment,
      selectedBed: existingAssignment?.bed,
      selectedRoom: existingAssignment?.bed?.room,
      selectedService: existingAssignment?.hospitalization?.physicalService ?? existingAssignment?.bed?.room?.service,
    );
  }

  Future<void> onServiceSelected(HospitalService? service) async {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;

    // Önce servisi seç, oda+yatak sıfırla, loading göster
    state = current.copyWith(selectedService: service, rooms: null, selectedRoom: null, beds: null, selectedBed: null);

    final result = await _getService.call(service?.id! ?? 0);

    result.when(
      ok: (fullService) {
        final current = state;
        if (current is! BedAssignmentCellSelected) return;
        state = current.copyWith(
          selectedService: fullService ?? service,
          rooms: fullService?.rooms ?? const [],
          selectedRoom: null,
          beds: null,
          selectedBed: null,
        );
      },
      error: (e) {
        final current = state;
        if (current is! BedAssignmentCellSelected) return;
        state = BedAssignmentError(message: e.message, previousState: current);
      },
    );
  }

  void onRoomSelected(Room? room) {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;

    state = current.copyWith(selectedRoom: room, beds: room?.beds, selectedBed: null);
  }

  void onBedSelected(Bed? bed) {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;

    state = current.copyWith(selectedBed: bed);
  }

  // Kaydet
  Future<void> saveAssignment() async {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;
    if (!current.canSave) return;

    final cellId = _resolveCellId(mobileSlots: current.mobileSlots, coord: current.selectedCell);
    if (cellId == null) {
      state = BedAssignmentError(message: contextlessL10n().assignment_cellNotFoundError, previousState: current);
      return;
    }

    state = BedAssignmentSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      selectedSlot: current.selectedSlot,
      cabinId: current.cabinId,
    );

    final Result<void> result;

    if (current.existingAssignment != null) {
      final entity = current.existingAssignment!.copyWith(bedId: current.selectedBed!.id);
      result = await _updateAssignment.call(entity);
    } else {
      final entity = BedAssignment(cellId: cellId, bedId: current.selectedBed!.id);
      result = await _createAssignment.call(entity);
    }

    result.when(
      ok: (_) => _refreshAssignments(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        selectedSlot: current.selectedSlot,
        cabinId: current.cabinId,
        selectedCell: current.selectedCell,
        isCreated: true,
      ),
      error: (e) {
        state = BedAssignmentError(message: e.message, previousState: current);
      },
    );
  }

  Future<void> deleteAssignment() async {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;
    if (current.existingAssignment == null) return;

    state = BedAssignmentSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      selectedSlot: current.selectedSlot,
      cabinId: current.cabinId,
    );

    final result = await _deleteAssignment.call(current.existingAssignment!);

    result.when(
      ok: (_) => _refreshAssignments(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        selectedSlot: current.selectedSlot,
        cabinId: current.cabinId,
        selectedCell: current.selectedCell,
        isCreated: false,
      ),
      error: (e) {
        state = BedAssignmentError(message: e.message, previousState: current);
      },
    );
  }

  Future<void> _refreshAssignments({
    required List<MobileSlotVisual> slots,
    required List<MobileDrawerSlot> mobileSlots,
    required MobileSlotVisual selectedSlot,
    required MobileCellCoord selectedCell,
    required int cabinId,
    required bool isCreated,
  }) async {
    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => BedAssignmentSuccess(
        slots: slots,
        mobileSlots: mobileSlots,
        selectedSlot: selectedSlot,
        selectedCell: selectedCell,
        assignments: assignments,
        cabinId: cabinId,
        message: '',
        isCreated: isCreated,
      ),
      error: (e) => BedAssignmentError(
        message: e.message,
        previousState: BedAssignmentSlotSelected(
          slots: slots,
          mobileSlots: mobileSlots,
          assignments: const [],
          selectedSlot: selectedSlot,
          cabinId: cabinId,
        ),
      ),
    );
  }

  void dismissError() {
    if (state is BedAssignmentError) {
      state = (state as BedAssignmentError).previousState;
    }
  }

  void dismissSuccess() {
    final current = state;
    if (current is! BedAssignmentSuccess) return;

    final cellId = _resolveCellId(mobileSlots: current.mobileSlots, coord: current.selectedCell);
    final existingAssignment = cellId != null ? current.assignments.firstWhereOrNull((a) => a.cellId == cellId) : null;

    state = BedAssignmentCellSelected(
      slots: current.slots,
      cabinId: current.cabinId,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      selectedSlot: current.selectedSlot,
      selectedCell: current.selectedCell,
      services: _services,
      existingAssignment: existingAssignment,
      selectedBed: existingAssignment?.bed,
      selectedRoom: existingAssignment?.bed?.room,
      selectedService: existingAssignment?.hospitalization?.physicalService ?? existingAssignment?.bed?.room?.service,
    );
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
