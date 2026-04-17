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
import '../../assignment.dart';

final patientAssignmentNotifierProvider = NotifierProvider<PatientAssignmentNotifier, PatientAssignmentState>(
  PatientAssignmentNotifier.new,
);

class PatientAssignmentNotifier extends Notifier<PatientAssignmentState> {
  @override
  PatientAssignmentState build() => const PatientAssignmentUninitialized();

  GetPatientAssignmentsUseCase get _getAssignments => ref.read(getPatientAssignmentsUseCaseProvider);
  CreatePatientAssignmentUseCase get _createAssignment => ref.read(createPatientAssignmentUseCaseProvider);
  DeletePatientAssignmentUseCase get _deleteAssignment => ref.read(deletePatientAssignmentUseCaseProvider);

  // Init
  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();

    state = PatientAssignmentLoading(slots: slots, cabinId: data.cabinId);

    final results = await Future.wait([
      _getAssignments.call(data.cabinId),
      ref.read(allRoomsProvider.future),
      ref.read(allBedsProvider.future),
      ref.read(allServicesProvider.future),
    ]);

    final assignmentResult = results[0] as Result<List<PatientAssignment>>;

    state = assignmentResult.when(
      ok: (assignments) {
        // Her atamadaki hospitalization'ı zenginleştir
        final enriched = _enrichAssignments(assignments);

        return PatientAssignmentIdle(
          slots: slots,
          mobileSlots: data.mobileSlots,
          assignments: enriched,
          cabinId: data.cabinId,
        );
      },
      error: (e) => PatientAssignmentError(
        message: e.message,
        previousState: PatientAssignmentIdle(
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
    final slots = state.slots;
    final mobileSlots = state.mobileSlots;
    final assignments = state.assignments;

    final currentSlotId = switch (current) {
      PatientAssignmentSlotSelected s => s.selectedSlotId,
      PatientAssignmentCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId == slot.slotId) {
      state = PatientAssignmentIdle(
        slots: slots,
        mobileSlots: mobileSlots,
        assignments: assignments,
        cabinId: current.cabinId,
      );
      return;
    }

    state = PatientAssignmentSlotSelected(
      slots: slots,
      mobileSlots: mobileSlots,
      assignments: assignments,
      selectedSlot: slot,
      cabinId: current.cabinId,
    );
  }

  // Hücre seçimi
  void onCellTap(MobileCellCoord coord) {
    final current = state;
    final selectedSlot = state.selectedSlot;
    if (selectedSlot == null) return;

    if (current is PatientAssignmentCellSelected && current.selectedCell == coord) {
      state = PatientAssignmentSlotSelected(
        slots: state.slots,
        mobileSlots: state.mobileSlots,
        assignments: state.assignments,
        selectedSlot: selectedSlot,
        cabinId: current.cabinId,
      );
      return;
    }

    // Seçili hücrede mevcut atama var mı — cellId lookup
    final cellId = _resolveCellId(mobileSlots: state.mobileSlots, coord: coord);
    final existingAssignment = cellId != null ? state.assignments.firstWhereOrNull((a) => a.cellId == cellId) : null;

    state = PatientAssignmentCellSelected(
      slots: state.slots,
      cabinId: current.cabinId,
      mobileSlots: state.mobileSlots,
      assignments: state.assignments,
      selectedSlot: selectedSlot,
      selectedCell: coord,
      existingAssignment: existingAssignment,
      selectedHospitalization: existingAssignment?.hospitalization,
    );
  }

  // Yatış seçimi
  void onHospitalizationSelected(Hospitalization hospitalization) {
    final current = state;
    if (current is! PatientAssignmentCellSelected) return;

    final rooms = ref.read(allRoomsProvider).valueOrNull ?? [];
    final beds = ref.read(allBedsProvider).valueOrNull ?? [];
    final services = ref.read(allServicesProvider).valueOrNull ?? [];

    final roomById = {for (final r in rooms) r.id: r};
    final bedById = {for (final b in beds) b.id: b};
    final serviceById = {for (final s in services) s.id: s};

    final room = roomById[hospitalization.roomId];
    final enriched = hospitalization.copyWith(
      room: room,
      bed: bedById[hospitalization.bedId],
      physicalService:
          serviceById[hospitalization.physicalServiceId] ?? (room != null ? serviceById[room.serviceId] : null),
    );

    state = current.copyWith(selectedHospitalization: enriched);
  }

  // Kaydet
  Future<void> saveAssignment() async {
    final current = state;
    if (current is! PatientAssignmentCellSelected) return;
    if (!current.canSave) return;

    final cellId = _resolveCellId(mobileSlots: current.mobileSlots, coord: current.selectedCell);
    if (cellId == null) {
      state = PatientAssignmentError(message: 'Seçili göz bulunamadı', previousState: current);
      return;
    }

    state = PatientAssignmentSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      selectedSlot: current.selectedSlot,
      cabinId: current.cabinId,
    );

    final entity = (current.existingAssignment ?? const PatientAssignment()).copyWith(
      cellId: cellId,
      bedId: current.selectedHospitalization!.bedId,
    );
    final result = await _createAssignment.call(entity);

    result.when(
      ok: (_) => _refreshAssignments(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        selectedSlot: current.selectedSlot,
        cabinId: current.cabinId,
        message: 'Hasta ataması başarıyla kaydedildi',
      ),
      error: (e) {
        state = PatientAssignmentError(message: e.message, previousState: current);
      },
    );
  }

  Future<void> deleteAssignment() async {
    final current = state;
    if (current is! PatientAssignmentCellSelected) return;
    if (current.existingAssignment == null) return;

    state = PatientAssignmentSaving(
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
        message: 'Hasta ataması kaldırıldı',
      ),
      error: (e) {
        state = PatientAssignmentError(message: e.message, previousState: current);
      },
    );
  }

  Future<void> _refreshAssignments({
    required List<MobileSlotVisual> slots,
    required List<MobileDrawerSlot> mobileSlots,
    required MobileSlotVisual selectedSlot,
    required int cabinId,
    required String message, // eklendi
  }) async {
    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) {
        final enriched = _enrichAssignments(assignments);
        return PatientAssignmentSuccess(
          slots: slots,
          mobileSlots: mobileSlots,
          selectedSlot: selectedSlot,
          assignments: enriched,
          cabinId: cabinId,
          message: message,
        );
      },
      error: (e) => PatientAssignmentError(
        message: e.message,
        previousState: PatientAssignmentSlotSelected(
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
    if (state is PatientAssignmentError) {
      state = (state as PatientAssignmentError).previousState;
    }
  }

  void dismissSuccess() {
    final current = state;
    if (current is! PatientAssignmentSuccess) return;
    state = PatientAssignmentSlotSelected(
      slots: current.slots,
      cabinId: current.cabinId,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      selectedSlot: current.selectedSlot,
    );
  }

  // MobileCellCoord → MobileDrawerCell.id çözümleyici
  //
  // coord.slotId → MobileDrawerSlot.id
  // coord.rowIndex → MobileDrawerUnit sırası (orderNo - 1)
  // coord.colIndex → MobileDrawerCell sırası (stepNo - 1)

  int? _resolveCellId({required List<MobileDrawerSlot> mobileSlots, required MobileCellCoord coord}) {
    final slot = mobileSlots.where((s) => s.id == coord.$1).firstOrNull;
    if (slot == null) return null;

    // orderNo - 1 değil, sort edilmiş listedeki index
    if (coord.$2 >= slot.units.length) return null;
    final unit = slot.units[coord.$2];

    // stepNo - 1 değil, sort edilmiş listedeki index
    if (coord.$3 >= unit.cells.length) return null;
    final cell = unit.cells[coord.$3];

    return cell.id;
  }

  List<PatientAssignment> _enrichAssignments(List<PatientAssignment> assignments) {
    final rooms = ref.read(allRoomsProvider).valueOrNull ?? [];
    final beds = ref.read(allBedsProvider).valueOrNull ?? [];
    final services = ref.read(allServicesProvider).valueOrNull ?? [];
    final roomById = {for (final r in rooms) r.id: r};
    final bedById = {for (final b in beds) b.id: b};
    final serviceById = {for (final s in services) s.id: s};

    return assignments.map((a) {
      final hosp = a.hospitalization;
      if (hosp == null) return a;
      final room = roomById[hosp.roomId];
      final service = room != null ? serviceById[room.serviceId] : null;
      return a.copyWith(
        hospitalization: hosp.copyWith(
          room: room,
          bed: bedById[hosp.bedId],
          physicalService: service ?? serviceById[hosp.physicalServiceId],
        ),
      );
    }).toList();
  }
}
