// [SWREQ-UI-STOCK-NOTIFIER-001]
// Sınıf : Class A

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';
import 'cabin_stock_state.dart';

final cabinStockNotifierProvider = NotifierProvider<CabinStockNotifier, CabinStockState>(CabinStockNotifier.new);

class CabinStockNotifier extends Notifier<CabinStockState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  @override
  CabinStockState build() => const CabinStockUninitialized();

  Future<void> init(int cabinId) async {
    state = CabinStockLoading(cabinId: cabinId);

    final result = await _getBedAssignments.call(cabinId);

    await result.when(
      ok: (assignments) async {
        final hospitalizations = _toHospitalizations(assignments);
        state = CabinStockIdle(cabinId: cabinId, hospitalizations: hospitalizations);
        if (hospitalizations.isEmpty) return;

        await onPatientTap(hospitalizations.first);
      },
      error: (error) {
        state = CabinStockError(
          message: error.message,
          previousState: CabinStockIdle(cabinId: cabinId, hospitalizations: const []),
        );
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    if (state.selectedPatient?.patient?.id == patientId) {
      state = CabinStockIdle(cabinId: state.cabinId!, hospitalizations: state.hospitalizations, search: state.search);
      return;
    }

    state = CabinStockPatientSelected(
      cabinId: state.cabinId!,
      hospitalizations: state.hospitalizations,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => CabinStockPatientSelected(
        cabinId: state.cabinId!,
        hospitalizations: state.hospitalizations,
        selectedPatient: hospitalization,
        // Yalnızca stokta olan (purchasePending) ilaçları göster
        prescriptionItems: _filterStockItems(items),
        search: state.search,
        isPrescriptionsLoading: false,
      ),
      error: (e) => CabinStockError(
        message: e.message,
        previousState: CabinStockPatientSelected(
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

  void onDrugTap(PrescriptionItem item) {
    final current = state;

    final (patient, items) = switch (current) {
      CabinStockPatientSelected(:final selectedPatient, :final prescriptionItems) => (
        selectedPatient,
        prescriptionItems,
      ),
      CabinStockDrugSelected(:final selectedPatient, :final prescriptionItems) => (selectedPatient, prescriptionItems),
      _ => (null, null),
    };

    if (patient == null || items == null) return;

    // Toggle
    if (state.selectedItem?.id == item.id) {
      state = CabinStockPatientSelected(
        cabinId: state.cabinId!,
        hospitalizations: state.hospitalizations,
        selectedPatient: patient,
        prescriptionItems: items,
        search: state.search,
      );
      return;
    }

    state = CabinStockDrugSelected(
      cabinId: state.cabinId!,
      hospitalizations: state.hospitalizations,
      selectedPatient: patient,
      prescriptionItems: items,
      selectedItem: item,
      search: state.search,
    );
  }

  void onSearchChanged(String value) {
    final current = state;
    state = switch (current) {
      CabinStockIdle() => CabinStockIdle(
        cabinId: current.cabinId,
        hospitalizations: current.hospitalizations,
        search: value,
      ),
      CabinStockPatientSelected() => current.copyWith(search: value),
      CabinStockDrugSelected() => CabinStockDrugSelected(
        cabinId: current.cabinId,
        hospitalizations: current.hospitalizations,
        selectedPatient: current.selectedPatient,
        prescriptionItems: current.prescriptionItems,
        selectedItem: current.selectedItem,
        search: value,
      ),
      _ => current,
    };
  }

  void dismissError() {
    final current = state;
    if (current is CabinStockError) state = current.previousState;
  }

  /// BedAssignment listesinden null olmayan Hospitalization'ları çıkarır.
  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }

  /// Yalnızca stokta bulunan (purchasePending) kalemleri döndürür.
  List<PrescriptionItem> _filterStockItems(List<PrescriptionItem> items) {
    return items.where((i) => i.status == PrescriptionMovementType.purchasePending).toList();
  }
}
