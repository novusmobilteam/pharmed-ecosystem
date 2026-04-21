// lib/features/assignment/presentation/notifier/patient_assignment_notifier.dart
//
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

import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../cabin/cabin.dart';
import '../../assignment.dart';

final bedAssignmentNotifierProvider = NotifierProvider<BedAssignmentNotifier, BedAssignmentState>(
  BedAssignmentNotifier.new,
);

class BedAssignmentNotifier extends Notifier<BedAssignmentState> {
  @override
  BedAssignmentState build() => const BedAssignmentUninitialized();

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getPatientAssignmentsUseCaseProvider);
  CreatePatientAssignmentUseCase get _createAssignment => ref.read(createPatientAssignmentUseCaseProvider);
  DeleteBedAssignmentUseCase get _deleteAssignment => ref.read(deletePatientAssignmentUseCaseProvider);
  UpdateBedAssignmentUseCase get _updateAssignment => ref.read(updatePatientAssignmentUseCaseProvider);
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

    final cabinResult = results[0] as RepoResult<Cabin?>;
    final assignmentResult = results[1] as Result<List<BedAssignment>>;

    // 2. Kabin başarısız → hata
    final Cabin? cabin = switch (cabinResult) {
      RepoSuccess(:final data) => data,
      RepoStale(:final data) => data,
      RepoFailure() => null,
    };

    if (cabin == null || cabin.stationId == null) {
      state = BedAssignmentError(
        message: 'Kabin istasyon bilgisi alınamadı',
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
      // Mevcut atama varsa bed bilgisini önceden doldur
      selectedBed: existingAssignment?.bed,
    );
  }

  Future<void> onServiceSelected(HospitalService service) async {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;

    // Önce servisi seç, oda+yatak sıfırla, loading göster
    state = current.copyWith(selectedService: service, rooms: null, selectedRoom: null, beds: null, selectedBed: null);

    final result = await _getService.call(service.id!);

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

  void onRoomSelected(Room room) {
    final current = state;
    if (current is! BedAssignmentCellSelected) return;

    state = current.copyWith(selectedRoom: room, beds: room.beds, selectedBed: null);
  }

  void onBedSelected(Bed bed) {
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
      // TODO(l10n): move to view layer or pass translated string as parameter
      state = BedAssignmentError(message: 'Seçili göz bulunamadı', previousState: current);
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
        // TODO(l10n): move to view layer or pass translated string as parameter
        message: 'Yatak ataması başarıyla kaydedildi',
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
        // TODO(l10n): move to view layer or pass translated string as parameter
        message: 'Yatak ataması kaldırıldı',
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
    required int cabinId,
    required String message,
  }) async {
    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => BedAssignmentSuccess(
        slots: slots,
        mobileSlots: mobileSlots,
        selectedSlot: selectedSlot,
        assignments: assignments,
        cabinId: cabinId,
        message: message,
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
    state = BedAssignmentSlotSelected(
      slots: current.slots,
      cabinId: current.cabinId,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      selectedSlot: current.selectedSlot,
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
