// lib/features/unapplied_prescription_screen/unapplied_prescription_notifier.dart
//
// [SWREQ-UI-UNAPP-NOTIFIER-001]
// Sınıf : Class A
//
// PrescriptionNotifier ile aynı API çağrıları — fark:
//   onPatientTap içinde API'den gelen tüm items'a
//   PrescriptionItemStatus.pendingPickup filtresi uygulanır.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';
import 'unapplied_prescription_state.dart';

final unappliedPrescriptionNotifierProvider =
    NotifierProvider<UnappliedPrescriptionNotifier, UnappliedPrescriptionState>(UnappliedPrescriptionNotifier.new);

class UnappliedPrescriptionNotifier extends Notifier<UnappliedPrescriptionState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);

  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  @override
  UnappliedPrescriptionState build() => const UnappliedPrescriptionUninitialized();

  Future<void> init(int cabinId) async {
    if (state.cabinId == cabinId && state is! UnappliedPrescriptionUninitialized) return;

    state = UnappliedPrescriptionLoading(cabinId: cabinId);

    final result = await _getBedAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => UnappliedPrescriptionIdle(cabinId: cabinId, patients: _toPatients(assignments)),
      error: (e) => UnappliedPrescriptionError(
        message: e.message,
        previousState: UnappliedPrescriptionIdle(cabinId: cabinId, patients: const []),
      ),
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    // Toggle — aynı hasta tekrar seçilirse Idle'a dön
    if (state.selectedPatient?.patient?.id == patientId) {
      state = UnappliedPrescriptionIdle(cabinId: state.cabinId!, patients: state.patients, search: state.search);
      return;
    }

    state = UnappliedPrescriptionPatientSelected(
      cabinId: state.cabinId!,
      patients: state.patients,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => UnappliedPrescriptionPatientSelected(
        cabinId: state.cabinId!,
        patients: state.patients,
        selectedPatient: hospitalization,
        // ── Tek fark burası ──────────────────────────────────────────
        // Tüm reçete kalemleri arasından yalnızca alım bekleyenler alınır.
        prescriptionItems: items.where((item) => item.status == PrescriptionMovementType.purchasePending).toList(),
        // ─────────────────────────────────────────────────────────────
        search: state.search,
        isPrescriptionsLoading: false,
      ),
      error: (e) => UnappliedPrescriptionError(
        message: e.message,
        previousState: UnappliedPrescriptionPatientSelected(
          cabinId: state.cabinId!,
          patients: state.patients,
          selectedPatient: hospitalization,
          prescriptionItems: const [],
          search: state.search,
          isPrescriptionsLoading: false,
        ),
      ),
    );
  }

  void onSearchChanged(String value) {
    state = switch (state) {
      UnappliedPrescriptionIdle s => UnappliedPrescriptionIdle(cabinId: s.cabinId, patients: s.patients, search: value),
      UnappliedPrescriptionPatientSelected s => s.copyWith(search: value),
      _ => state,
    };
  }

  void dismissError() {
    final current = state;
    if (current is UnappliedPrescriptionError) state = current.previousState;
  }

  List<Hospitalization> _toPatients(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
