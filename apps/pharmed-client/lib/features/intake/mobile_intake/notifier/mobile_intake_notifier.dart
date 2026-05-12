import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';

// [SWREQ-CLI-INTAKE-001] [IEC 62304 §5.5]
// Mobil kabin ilaç alım ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan slot + atama verilerini alır
//   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
//   - Alım başlatma → CheckMobileIntakeUseCase ile backend validasyon → çekmece açar
//   - RFID kaybı → takenEpcs günceller (dolumun tersi: kayıp = alındı)
//   - Alım tamamlama → çekmece kapalıyken CompleteMobileIntakeUseCase çağırır
//
// Dolumdan farkı:
//   - startIntake öncesi CheckMobileIntakeUseCase çalışır
//   - rfidReadEpcs yerine takenEpcs takip edilir (EPC kaybolunca alındı sayılır)
//   - EPC geri gelirse takenEpcs'ten çıkarılır (ilaç geri konuldu)
//   - canComplete: seçili RFID'li item'ların EPC'si takenEpcs'te olmalı
//
// Sınıf: Class B

final mobileIntakeNotifierProvider = NotifierProvider<MobileIntakeNotifier, MobileIntakeState>(
  MobileIntakeNotifier.new,
);

class MobileIntakeNotifier extends Notifier<MobileIntakeState> {
  late final MobileDrawerOrchestrator _drawer;
  MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);
  CheckMobileIntakeUseCase get _checkIntake => ref.read(checkMobileIntakeUseCaseProvider);
  CompleteMobileIntakeUseCase get _completeIntake => ref.read(completeMobileIntakeUseCaseProvider);

  @override
  MobileIntakeState build() {
    _drawer = MobileDrawerOrchestrator(ref: ref)
      ..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead, onEpcLost: _onEpcLost);

    ref.onDispose(() => _drawer.dispose());

    return const MobileIntakeUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    final mobileSlots = data.mobileSlots;

    state = MobileIntakeLoading(slots: slots, cabinId: data.cabinId);

    final assignmentResult = await _getAssignments.call(data.cabinId);

    state = assignmentResult.when(
      ok: (assignments) =>
          MobileIntakeIdle(slots: slots, mobileSlots: mobileSlots, assignments: assignments, cabinId: data.cabinId),
      error: (e) => MobileIntakeError(
        message: e.message,
        previousState: MobileIntakeIdle(
          slots: slots,
          mobileSlots: mobileSlots,
          assignments: const [],
          cabinId: data.cabinId,
        ),
      ),
    );
  }

  /// Panel'deki hasta listesinden bir hasta seçildiğinde çağrılır.
  /// İlgili göze otomatik gider — mevcut [onCellTap] akışını kullanır.
  Future<void> selectAssignment(BedAssignment assignment) async {
    if (assignment.cellId == null) return;

    final coord = state.assignmentByCoord.entries
        .where((e) => e.value.id == assignment.id)
        .map((e) => e.key)
        .firstOrNull;
    if (coord == null) return;

    final slot = state.slots.where((s) => s.slotId == coord.$1).firstOrNull;
    if (slot == null) return;
    if (state.selectedSlotId != slot.slotId) {
      onSlotTap(slot);
    }

    await onCellTap(coord);
  }

  /// Ready/NoPatient state'inden hasta listesine geri döner.
  /// Slot seçimi korunur.
  void clearPatientSelection() {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    state = MobileIntakeSlotSelected(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  /// İlaç işaretle / işareti kaldır.
  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileIntakeReady) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
  }

  /// Alıma başla — önce backend check, sonra çekmece aç.
  ///
  /// [CheckMobileIntakeUseCase] hata dönerse çekmece açılmaz.
  /// Check geçerse [_drawer.open] çağrılır; RFID session orchestrator tarafından başlatılır.
  ///
  /// SWREQ-CLI-INTAKE-002
  Future<void> startIntake() async {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (current.selectedItemIds.isEmpty) return;

    // Check sırasında UI kilitlenir — isStarting: state is MobileIntakeCheckInProgress
    state = MobileIntakeCheckInProgress(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    // Check için EPC gönderilmez
    final params = current.prescriptionItems
        .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
        .map((i) => MobileIntakeParams(prescriptionDetailId: i.id!, dosePiece: i.dosePiece?.toDouble(), epc: i.rfidTag))
        .toList();

    final checkResult = await _checkIntake(params);

    if (checkResult is Error) {
      state = MobileIntakeError(message: checkResult.error.message, previousState: current);
      return;
    }

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  /// Çekmeceyi tekrar aç — RFID eksikse "Alıma Devam Et" butonuna bağlanır.
  Future<void> reopenDrawer() async {
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// Alımı iptal et.
  ///
  /// - DrawerIdle + seçim var → seçimleri sıfırla
  /// - DrawerOpening/Opened + takenEpcs dolu → view handle eder, dönülür
  /// - Diğer durumlarda → session durdur, seçimleri sıfırla
  Future<void> cancelIntake() async {
    final current = state;
    final ready = switch (current) {
      MobileIntakeReady r => r,
      MobileIntakeCheckInProgress(:final ready) => ready,
      MobileIntakeSaving(:final ready) => ready,
      _ => null,
    };

    final stage = _drawerStage;

    if (stage is MobileDrawerIdle) {
      if (ready == null) return;
      state = ready.copyWith(selectedItemIds: {}, rfidReadEpcs: {}, takenEpcs: {});
      return;
    }

    if ((stage is MobileDrawerOpening || stage is MobileDrawerOpened) && (ready?.takenEpcs.isNotEmpty ?? false)) {
      return;
    }

    await _drawer.stop();

    if (ready != null) {
      state = ready.copyWith(selectedItemIds: {}, rfidReadEpcs: {}, takenEpcs: {});
    }
  }

  /// Alımı tamamla — çekmece kapalı + [MobileIntakeReady.canComplete] true olmalı.
  ///
  /// canComplete koşulu:
  ///   - RFID'li item: EPC'si takenEpcs'te olmalı
  ///   - RFID'siz item: seçili olması yeterli
  ///
  /// SWREQ-CLI-INTAKE-003
  Future<void> completeIntake() async {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (current.selectedItemIds.isEmpty) return;
    if (!current.canComplete) return;

    final drawerStage = ref.read(mobileDrawerSessionProvider).stage;
    if (drawerStage is! MobileDrawerClosed) return;

    state = MobileIntakeSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    final params = current.prescriptionItems
        .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
        .map(
          (i) => MobileIntakeParams(
            prescriptionDetailId: i.id!,
            dosePiece: i.dosePiece?.toDouble(),
            // Yalnızca takenEpcs'te olan EPC'ler gönderilir
            epc: current.takenEpcs.contains(i.rfidTag) ? i.rfidTag : null,
          ),
        )
        .toList();

    final result = await _completeIntake(params);

    result.when(
      ok: (_) async {
        await _drawer.stop();

        state = MobileIntakeSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          message: 'Alım işlemi başarıyla tamamlandı.',
          ready: current.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        );
      },
      error: (e) {
        state = MobileIntakeError(
          message: e.message,
          previousState: current.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        );
      },
    );
  }

  /// EPC okundu → ilaç geri konuldu: takenEpcs'ten çıkar.
  ///
  /// SWREQ-CLI-INTAKE-004
  void _onEpcRead(String epc) {
    final current = state;
    if (current is! MobileIntakeReady) return;

    final wasTaken = current.takenEpcs.contains(epc);
    final alreadyRead = current.rfidReadEpcs.contains(epc);
    if (!wasTaken && alreadyRead) return;

    final newTaken = Set<String>.from(current.takenEpcs)..remove(epc);
    final newRead = {...current.rfidReadEpcs, epc};

    state = current.copyWith(rfidReadEpcs: newRead, takenEpcs: newTaken);

    if (wasTaken) {
      MedLogger.info(
        unit: 'MobileIntakeNotifier',
        swreq: 'SWREQ-CLI-INTAKE-004',
        message: 'RFID tag tekrar kapsama alanına girdi — alındı sayımından çıkarıldı',
        context: {'epc': epc},
      );
    }
  }

  /// EPC kayboldu → ilaç kabinden çıkarıldı: takenEpcs'e ekle.
  ///
  /// Seçili olmayan item'ın EPC'si kaybolsa bile takenEpcs'e eklenir;
  /// [canComplete] yalnızca seçili item'ları dikkate alır.
  ///
  /// SWREQ-CLI-INTAKE-005
  void _onEpcLost(String epc) {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (current.takenEpcs.contains(epc)) return;

    final newRead = Set<String>.from(current.rfidReadEpcs)..remove(epc);
    final newTaken = {...current.takenEpcs, epc};

    state = current.copyWith(rfidReadEpcs: newRead, takenEpcs: newTaken);

    MedLogger.info(
      unit: 'MobileIntakeNotifier',
      swreq: 'SWREQ-CLI-INTAKE-005',
      message: 'RFID tag kapsama dışına çıktı — alındı olarak işaretlendi',
      context: {'epc': epc},
    );
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    if (next is MobileDrawerOpened) {
      final current = state;
      if (current is MobileIntakeCheckInProgress) {
        state = current.ready;
      }
    }

    if (next is MobileDrawerFailed) {
      final current = state;
      final cleaned = switch (current) {
        MobileIntakeReady r => r.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        MobileIntakeCheckInProgress(:final ready) => ready.copyWith(
          rfidReadEpcs: {},
          takenEpcs: {},
          selectedItemIds: {},
        ),
        _ => current,
      };
      state = MobileIntakeError(message: next.message, previousState: cleaned);
    }
  }

  void onSlotTap(MobileSlotVisual slot) {
    final current = state;
    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    if (current.selectedSlotId == slot.slotId) {
      state = MobileIntakeIdle(slots: slots, mobileSlots: ms, assignments: assignments, cabinId: cabinId);
      return;
    }

    state = MobileIntakeSlotSelected(
      slots: slots,
      mobileSlots: ms,
      selectedSlot: slot,
      assignments: assignments,
      cabinId: cabinId,
    );
  }

  Future<void> onCellTap(MobileCellCoord coord) async {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    if (current.selectedCell == coord) {
      state = MobileIntakeSlotSelected(
        slots: slots,
        mobileSlots: ms,
        selectedSlot: selectedSlot,
        assignments: assignments,
        cabinId: cabinId,
      );
      return;
    }

    final assignment = current.assignmentByCoord[coord];

    if (assignment?.hospitalization?.patient == null) {
      state = MobileIntakeNoPatient(
        slots: slots,
        mobileSlots: ms,
        selectedSlot: selectedSlot,
        selectedCell: coord,
        assignments: assignments,
        cabinId: cabinId,
      );
      return;
    }

    await _loadPrescriptions(
      slots: slots,
      mobileSlots: ms,
      selectedSlot: selectedSlot,
      selectedCell: coord,
      assignments: assignments,
      cabinId: cabinId,
      assignment: assignment!,
    );
  }

  Future<void> _loadPrescriptions({
    required List<MobileSlotVisual> slots,
    required List<MobileDrawerSlot> mobileSlots,
    required MobileSlotVisual selectedSlot,
    required MobileCellCoord selectedCell,
    required List<BedAssignment> assignments,
    required int cabinId,
    required BedAssignment assignment,
  }) async {
    final patient = assignment.hospitalization?.patient;
    if (patient?.id == null) return;

    state = MobileIntakeLoading(
      slots: slots,
      cabinId: cabinId,
      selectedSlot: selectedSlot,
      mobileSlots: mobileSlots,
      assignments: assignments,
    );

    final result = await _getPrescriptionHistory(patient!.id!);

    result.when(
      ok: (items) {
        state = MobileIntakeReady(
          slots: slots,
          mobileSlots: mobileSlots,
          selectedSlot: selectedSlot,
          selectedCell: selectedCell,
          assignments: assignments,
          cabinId: cabinId,
          patient: patient,
          bed: assignment.bed,
          room: assignment.bed?.room,
          prescriptionItems: items,
          rfidReadEpcs: const {},
          takenEpcs: const {},
          selectedItemIds: {},
        );
      },
      error: (e) {
        state = MobileIntakeError(
          message: e.message,
          previousState: MobileIntakeNoPatient(
            slots: slots,
            mobileSlots: mobileSlots,
            selectedSlot: selectedSlot,
            selectedCell: selectedCell,
            assignments: assignments,
            cabinId: cabinId,
          ),
        );
      },
    );
  }

  void dismissError() {
    final current = state;
    if (current is! MobileIntakeError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileIntakeSuccess) return;
    state = MobileIntakeIdle(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }
}
