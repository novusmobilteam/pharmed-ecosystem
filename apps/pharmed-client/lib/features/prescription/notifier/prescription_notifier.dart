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
    state = PrescriptionLoading(cabinId: cabinId);
    final result = await _getBedAssignments.call(cabinId);

    await result.when(
      ok: (assignments) async {
        final hospitalizations = _toHospitalizations(assignments);
        state = PrescriptionIdle(cabinId: cabinId, hospitalizations: hospitalizations);
        if (hospitalizations.isEmpty) return;

        await onPatientTap(hospitalizations.first);
      },
      error: (error) {
        state = PrescriptionError(
          message: error.message,
          previousState: PrescriptionIdle(cabinId: cabinId, hospitalizations: const []),
        );
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    if (state.selectedPatient?.patient?.id == patientId) {
      state = PrescriptionIdle(cabinId: state.cabinId!, hospitalizations: state.hospitalizations, search: state.search);
      return;
    }

    state = PrescriptionPatientSelected(
      cabinId: state.cabinId!,
      hospitalizations: state.hospitalizations,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => PrescriptionPatientSelected(
        cabinId: state.cabinId!,
        hospitalizations: state.hospitalizations,
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
          hospitalizations: state.hospitalizations,
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
      PrescriptionIdle s => PrescriptionIdle(cabinId: s.cabinId, hospitalizations: s.hospitalizations, search: value),
      PrescriptionPatientSelected s => s.copyWith(search: value),
      _ => state,
    };
  }

  void dismissError() {
    final current = state;
    if (current is PrescriptionError) state = current.previousState;
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
