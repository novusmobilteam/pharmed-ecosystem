// lib/features/prescription_screen/prescription_screen_notifier.dart
//
// [SWREQ-UI-PRESC-NOTIFIER-001]
// Sınıf : Class A

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';
import 'prescription_state.dart';

final prescriptionNotifierProvider = NotifierProvider<PrescriptionNotifier, PrescriptionState>(
  PrescriptionNotifier.new,
);

class PrescriptionNotifier extends Notifier<PrescriptionState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  @override
  PrescriptionState build() => const PrescriptionUninitialized();

  Future<void> init(int cabinId) async {
    if (state.cabinId == cabinId && state is! PrescriptionUninitialized) return;

    state = PrescriptionLoading(cabinId: cabinId);

    final result = await _getBedAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => PrescriptionIdle(cabinId: cabinId, patients: _toPatients(assignments)),
      error: (e) => PrescriptionError(
        message: e.message,
        previousState: PrescriptionIdle(cabinId: cabinId, patients: const []),
      ),
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    // Toggle
    if (state.selectedPatient?.patient?.id == patientId) {
      state = PrescriptionIdle(cabinId: state.cabinId!, patients: state.patients, search: state.search);
      return;
    }

    state = PrescriptionPatientSelected(
      cabinId: state.cabinId!,
      patients: state.patients,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => PrescriptionPatientSelected(
        cabinId: state.cabinId!,
        patients: state.patients,
        selectedPatient: hospitalization,
        // Filtre yok — tüm statusler gösterilir
        prescriptionItems: items,
        search: state.search,
        isPrescriptionsLoading: false,
      ),
      error: (e) => PrescriptionError(
        message: e.message,
        previousState: PrescriptionPatientSelected(
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
      PrescriptionIdle s => PrescriptionIdle(cabinId: s.cabinId, patients: s.patients, search: value),
      PrescriptionPatientSelected s => s.copyWith(search: value),
      _ => state,
    };
  }

  void dismissError() {
    final current = state;
    if (current is PrescriptionError) state = current.previousState;
  }

  List<Hospitalization> _toPatients(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
