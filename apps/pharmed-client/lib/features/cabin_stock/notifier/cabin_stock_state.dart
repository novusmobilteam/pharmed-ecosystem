// lib/features/cabin_stock/cabin_stock_state.dart
//
// [SWREQ-UI-STOCK-STATE-001]
// Sınıf : Class A

import 'package:pharmed_core/pharmed_core.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State geçiş diyagramı:
//
//   Uninitialized
//       │ init(cabinId)
//       ▼
//     Loading
//       │ getBedAssignments OK
//       ▼
//      Idle ◄──────────────────────────────────────────────┐
//       │ onPatientTap(hospitalization)                     │
//       ▼                                                   │ dismissError
//   PatientSelected (isPrescriptionsLoading: true)          │
//       │ getPrescriptionHistory OK → filtrele              │
//       ▼                                                   │
//   PatientSelected (isPrescriptionsLoading: false)         │
//       │ onDrugTap(item)                                   │
//       ▼                                                   │
//   DrugSelected ──────────────────────────────────────────►┘
//       │
//       ▼
//   Error(previousState)
//
// Not: prescriptionItems yalnızca PrescriptionStatus.purchasePending
//      olanları içerir — filtreleme notifier'da yapılır.
// ─────────────────────────────────────────────────────────────────────────────

sealed class CabinStockState {
  const CabinStockState();
}

// ── Uninitialized ────────────────────────────────────────────────────────────

final class CabinStockUninitialized extends CabinStockState {
  const CabinStockUninitialized();
}

// ── Loading ──────────────────────────────────────────────────────────────────

final class CabinStockLoading extends CabinStockState {
  const CabinStockLoading({required this.cabinId});
  final int cabinId;
}

// ── Idle ─────────────────────────────────────────────────────────────────────

final class CabinStockIdle extends CabinStockState {
  const CabinStockIdle({required this.cabinId, required this.hospitalizations, this.search = ''});

  final int cabinId;
  final List<Hospitalization> hospitalizations;
  final String search;
}

// ── PatientSelected ──────────────────────────────────────────────────────────

final class CabinStockPatientSelected extends CabinStockState {
  const CabinStockPatientSelected({
    required this.cabinId,
    required this.hospitalizations,
    required this.selectedPatient,
    required this.prescriptionItems,
    this.search = '',
    this.isPrescriptionsLoading = false,
  });

  final int cabinId;
  final List<Hospitalization> hospitalizations;
  final Hospitalization selectedPatient;

  /// Yalnızca PrescriptionStatus.purchasePending olanlar.
  final List<PrescriptionItem> prescriptionItems;

  final String search;
  final bool isPrescriptionsLoading;

  static const _sentinel = Object();

  CabinStockPatientSelected copyWith({
    List<PrescriptionItem>? prescriptionItems,
    String? search,
    Object? isPrescriptionsLoading = _sentinel,
  }) {
    return CabinStockPatientSelected(
      cabinId: cabinId,
      hospitalizations: hospitalizations,
      selectedPatient: selectedPatient,
      prescriptionItems: prescriptionItems ?? this.prescriptionItems,
      search: search ?? this.search,
      isPrescriptionsLoading: isPrescriptionsLoading == _sentinel
          ? this.isPrescriptionsLoading
          : isPrescriptionsLoading as bool,
    );
  }
}

// ── DrugSelected ─────────────────────────────────────────────────────────────

final class CabinStockDrugSelected extends CabinStockState {
  const CabinStockDrugSelected({
    required this.cabinId,
    required this.hospitalizations,
    required this.selectedPatient,
    required this.prescriptionItems,
    required this.selectedItem,
    this.search = '',
  });

  final int cabinId;
  final List<Hospitalization> hospitalizations;
  final Hospitalization selectedPatient;
  final List<PrescriptionItem> prescriptionItems;
  final PrescriptionItem selectedItem;
  final String search;
}

// ── Error ────────────────────────────────────────────────────────────────────

final class CabinStockError extends CabinStockState {
  const CabinStockError({required this.message, required this.previousState});

  final String message;
  final CabinStockState previousState;
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension
// ─────────────────────────────────────────────────────────────────────────────

extension CabinStockStateX on CabinStockState {
  int? get cabinId => switch (this) {
    CabinStockLoading(:final cabinId) => cabinId,
    CabinStockIdle(:final cabinId) => cabinId,
    CabinStockPatientSelected(:final cabinId) => cabinId,
    CabinStockDrugSelected(:final cabinId) => cabinId,
    CabinStockError(:final previousState) => previousState.cabinId,
    _ => null,
  };

  List<Hospitalization> get hospitalizations => switch (this) {
    CabinStockIdle(:final hospitalizations) => hospitalizations,
    CabinStockPatientSelected(:final hospitalizations) => hospitalizations,
    CabinStockDrugSelected(:final hospitalizations) => hospitalizations,
    CabinStockError(:final previousState) => previousState.hospitalizations,
    _ => const [],
  };

  String get search => switch (this) {
    CabinStockIdle(:final search) => search,
    CabinStockPatientSelected(:final search) => search,
    CabinStockDrugSelected(:final search) => search,
    CabinStockError(:final previousState) => previousState.search,
    _ => '',
  };

  Hospitalization? get selectedPatient => switch (this) {
    CabinStockPatientSelected(:final selectedPatient) => selectedPatient,
    CabinStockDrugSelected(:final selectedPatient) => selectedPatient,
    CabinStockError(:final previousState) => previousState.selectedPatient,
    _ => null,
  };

  List<PrescriptionItem> get prescriptionItems => switch (this) {
    CabinStockPatientSelected(:final prescriptionItems) => prescriptionItems,
    CabinStockDrugSelected(:final prescriptionItems) => prescriptionItems,
    CabinStockError(:final previousState) => previousState.prescriptionItems,
    _ => const [],
  };

  PrescriptionItem? get selectedItem => switch (this) {
    CabinStockDrugSelected(:final selectedItem) => selectedItem,
    CabinStockError(:final previousState) => previousState.selectedItem,
    _ => null,
  };

  bool get isPrescriptionsLoading => switch (this) {
    CabinStockPatientSelected(:final isPrescriptionsLoading) => isPrescriptionsLoading,
    _ => false,
  };

  bool get isPatientSelected => switch (this) {
    CabinStockPatientSelected() || CabinStockDrugSelected() => true,
    CabinStockError(:final previousState) => previousState.isPatientSelected,
    _ => false,
  };

  /// RxDrugPanel.isBusy — bu ekranda kayıt işlemi yok
  bool get isBusy => false;
}
