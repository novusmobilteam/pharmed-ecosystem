import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../../core/providers/providers.dart';
import 'unapplied_prescription_state.dart';

final unappliedPrescriptionNotifierProvider =
    NotifierProvider<UnappliedPrescriptionNotifier, UnappliedPrescriptionState>(UnappliedPrescriptionNotifier.new);

class UnappliedPrescriptionNotifier extends Notifier<UnappliedPrescriptionState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetActiveHospitalizationsUseCase get _getHospitalizations => ref.read(getActiveHospitalizationsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  @override
  UnappliedPrescriptionState build() => const UnappliedPrescriptionUninitialized();

  Future<void> init(CabinType? deviceMode) async {
    state = UnappliedPrescriptionLoading();

    final isMobile = deviceMode == CabinType.mobile;

    final result = isMobile
        ? _fromBedAssignments(await _getBedAssignments.call())
        : _fromApiResponse(await _getHospitalizations.call(const PagedQueryParams()));

    await result.when(
      ok: (hospitalizations) async {
        state = UnappliedPrescriptionIdle(hospitalizations: hospitalizations);
        if (hospitalizations.isEmpty) return;

        await onPatientTap(hospitalizations.first);
      },
      error: (error) {
        state = UnappliedPrescriptionError(
          message: error.message,
          previousState: UnappliedPrescriptionIdle(hospitalizations: const []),
        );
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    // Toggle — aynı hasta tekrar seçilirse Idle'a dön
    if (state.selectedPatient?.patient?.id == patientId) {
      state = UnappliedPrescriptionIdle(hospitalizations: state.hospitalizations, search: state.search);
      return;
    }

    state = UnappliedPrescriptionPatientSelected(
      hospitalizations: state.hospitalizations,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => UnappliedPrescriptionPatientSelected(
        hospitalizations: state.hospitalizations,
        selectedPatient: hospitalization,
        prescriptionItems: items.where((item) => item.status == PrescriptionMovementType.purchasePending).toList(),
        search: state.search,
        isPrescriptionsLoading: false,
      ),
      error: (e) => UnappliedPrescriptionError(
        message: e.message,
        previousState: UnappliedPrescriptionPatientSelected(
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
      UnappliedPrescriptionIdle s => UnappliedPrescriptionIdle(hospitalizations: s.hospitalizations, search: value),
      UnappliedPrescriptionPatientSelected s => s.copyWith(search: value),
      _ => state,
    };
  }

  void dismissError() {
    final current = state;
    if (current is UnappliedPrescriptionError) state = current.previousState;
  }

  /// Mobil akış — BedAssignment listesini Hospitalization'a indirger.
  Result<List<Hospitalization>> _fromBedAssignments(Result<List<BedAssignment>> result) {
    return result.when(ok: (assignments) => Result.ok(_toHospitalizations(assignments)), error: (e) => Result.error(e));
  }

  /// Master/diğer cihazlar akışı — ApiResponse sarmalını burada çözüyoruz,
  /// yukarıdaki shared `.when` bloğu artık hangi kaynaktan geldiğini bilmiyor.
  Result<List<Hospitalization>> _fromApiResponse(Result<ApiResponse<List<Hospitalization>>> result) {
    return result.when(ok: (response) => Result.ok(response.data ?? const []), error: (e) => Result.error(e));
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
