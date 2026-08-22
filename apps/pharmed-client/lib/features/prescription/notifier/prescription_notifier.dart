// [SWREQ-UI-PRESC-NOTIFIER-001]
// Sınıf : Class A

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../../core/cache/app_settings_cache.dart';
import '../../../core/providers/providers.dart';
import 'prescription_state.dart';

final prescriptionNotifierProvider = NotifierProvider<PrescriptionNotifier, PrescriptionState>(
  PrescriptionNotifier.new,
);

class PrescriptionNotifier extends Notifier<PrescriptionState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetActiveHospitalizationsUseCase get _getHospitalizations => ref.read(getActiveHospitalizationsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  @override
  PrescriptionState build() => const PrescriptionUninitialized();

  Future<void> init() async {
    state = PrescriptionLoading();

    final cabinType = await ref.read(deviceModeProvider.future);
    final isMobile = cabinType == CabinType.mobile;

    final result = isMobile
        ? _fromBedAssignments(await _getBedAssignments.call())
        : _fromApiResponse(await _getHospitalizations.call(const PagedQueryParams()));

    await result.when(
      ok: (hospitalizations) async {
        state = PrescriptionIdle(hospitalizations: hospitalizations);
        if (hospitalizations.isEmpty) return;

        await onPatientTap(hospitalizations.first);
      },
      error: (error) {
        state = PrescriptionError(
          message: error.message,
          previousState: PrescriptionIdle(hospitalizations: const []),
        );
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    if (state.selectedPatient?.patient?.id == patientId) {
      state = PrescriptionIdle(hospitalizations: state.hospitalizations, search: state.search);
      return;
    }

    state = PrescriptionPatientSelected(
      hospitalizations: state.hospitalizations,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => PrescriptionPatientSelected(
        hospitalizations: state.hospitalizations,
        selectedPatient: hospitalization,

        prescriptionItems: items,
        search: state.search,
        isPrescriptionsLoading: false,
      ),
      error: (e) => PrescriptionError(
        message: e.message,
        previousState: PrescriptionPatientSelected(
          hospitalizations: state.hospitalizations,
          selectedPatient: hospitalization,
          prescriptionItems: const [],
          search: state.search,
          isPrescriptionsLoading: false,
        ),
      ),
    );
  }

  void dismissError() {
    final current = state;
    if (current is PrescriptionError) state = current.previousState;
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
