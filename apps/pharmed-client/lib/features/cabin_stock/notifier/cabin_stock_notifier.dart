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
    if (state.cabinId == cabinId && state is! CabinStockUninitialized) return;

    state = CabinStockLoading(cabinId: cabinId);

    final result = await _getBedAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => CabinStockIdle(cabinId: cabinId, patients: _toPatients(assignments)),
      error: (e) => CabinStockError(
        message: e.message,
        previousState: CabinStockIdle(cabinId: cabinId, patients: const []),
      ),
    );
  }

  // ── onPatientTap ──────────────────────────────────────────────────────────
  // Toggle: aynı hasta tekrar tıklanırsa Idle'a dön.

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    // Toggle
    if (state.selectedPatient?.patient?.id == patientId) {
      state = CabinStockIdle(cabinId: state.cabinId!, patients: state.patients, search: state.search);
      return;
    }

    // Yeni hasta — önce loading geçişini göster
    state = CabinStockPatientSelected(
      cabinId: state.cabinId!,
      patients: state.patients,
      selectedPatient: hospitalization,
      prescriptionItems: const [],
      search: state.search,
      isPrescriptionsLoading: true,
    );

    final result = await _getPrescriptionHistory.call(patientId);

    state = result.when(
      ok: (items) => CabinStockPatientSelected(
        cabinId: state.cabinId!,
        patients: state.patients,
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
          patients: state.patients,
          selectedPatient: hospitalization,
          prescriptionItems: const [],
          search: state.search,
          isPrescriptionsLoading: false,
        ),
      ),
    );
  }

  // ── onDrugTap ─────────────────────────────────────────────────────────────
  // Toggle: aynı ilaç tekrar tıklanırsa PatientSelected'a dön.

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
        patients: state.patients,
        selectedPatient: patient,
        prescriptionItems: items,
        search: state.search,
      );
      return;
    }

    state = CabinStockDrugSelected(
      cabinId: state.cabinId!,
      patients: state.patients,
      selectedPatient: patient,
      prescriptionItems: items,
      selectedItem: item,
      search: state.search,
    );
  }

  void onSearchChanged(String value) {
    final current = state;
    state = switch (current) {
      CabinStockIdle() => CabinStockIdle(cabinId: current.cabinId, patients: current.patients, search: value),
      CabinStockPatientSelected() => current.copyWith(search: value),
      CabinStockDrugSelected() => CabinStockDrugSelected(
        cabinId: current.cabinId,
        patients: current.patients,
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
  List<Hospitalization> _toPatients(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }

  /// Yalnızca stokta bulunan (purchasePending) kalemleri döndürür.
  List<PrescriptionItem> _filterStockItems(List<PrescriptionItem> items) {
    return items.where((i) => i.status == PrescriptionMovementType.purchasePending).toList();
  }
}
