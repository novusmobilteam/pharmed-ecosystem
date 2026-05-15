// [SWREQ-UI-UNAPP-STATE-001]
// Sınıf : Class A
//
// PrescriptionState ile aynı yapı — fark:
//   - prescriptionItems yalnızca PrescriptionItemStatus.pendingPickup kalemlerini içerir
//   - Filtre notifier katmanında uygulanır, view saf kalır

import 'package:pharmed_core/pharmed_core.dart';

sealed class UnappliedPrescriptionState {
  const UnappliedPrescriptionState();
}

final class UnappliedPrescriptionUninitialized extends UnappliedPrescriptionState {
  const UnappliedPrescriptionUninitialized();
}

final class UnappliedPrescriptionLoading extends UnappliedPrescriptionState {
  const UnappliedPrescriptionLoading({required this.cabinId});
  final int cabinId;
}

final class UnappliedPrescriptionIdle extends UnappliedPrescriptionState {
  const UnappliedPrescriptionIdle({required this.cabinId, required this.patients, this.search = ''});

  final int cabinId;
  final List<Hospitalization> patients;
  final String search;
}

final class UnappliedPrescriptionPatientSelected extends UnappliedPrescriptionState {
  const UnappliedPrescriptionPatientSelected({
    required this.cabinId,
    required this.patients,
    required this.selectedPatient,
    required this.prescriptionItems,
    this.search = '',
    this.isPrescriptionsLoading = false,
  });

  final int cabinId;
  final List<Hospitalization> patients;
  final Hospitalization selectedPatient;

  /// Yalnızca [PrescriptionItemStatus.pendingPickup] durumundaki kalemler.
  final List<PrescriptionItem> prescriptionItems;

  final String search;
  final bool isPrescriptionsLoading;

  static const _sentinel = Object();

  UnappliedPrescriptionPatientSelected copyWith({
    List<PrescriptionItem>? prescriptionItems,
    String? search,
    Object? isPrescriptionsLoading = _sentinel,
  }) {
    return UnappliedPrescriptionPatientSelected(
      cabinId: cabinId,
      patients: patients,
      selectedPatient: selectedPatient,
      prescriptionItems: prescriptionItems ?? this.prescriptionItems,
      search: search ?? this.search,
      isPrescriptionsLoading: isPrescriptionsLoading == _sentinel
          ? this.isPrescriptionsLoading
          : isPrescriptionsLoading as bool,
    );
  }
}

final class UnappliedPrescriptionError extends UnappliedPrescriptionState {
  const UnappliedPrescriptionError({required this.message, required this.previousState});

  final String message;
  final UnappliedPrescriptionState previousState;
}

extension UnappliedPrescriptionStateX on UnappliedPrescriptionState {
  int? get cabinId => switch (this) {
    UnappliedPrescriptionLoading(:final cabinId) => cabinId,
    UnappliedPrescriptionIdle(:final cabinId) => cabinId,
    UnappliedPrescriptionPatientSelected(:final cabinId) => cabinId,
    UnappliedPrescriptionError(:final previousState) => previousState.cabinId,
    _ => null,
  };

  List<Hospitalization> get patients => switch (this) {
    UnappliedPrescriptionIdle(:final patients) => patients,
    UnappliedPrescriptionPatientSelected(:final patients) => patients,
    UnappliedPrescriptionError(:final previousState) => previousState.patients,
    _ => const [],
  };

  String get search => switch (this) {
    UnappliedPrescriptionIdle(:final search) => search,
    UnappliedPrescriptionPatientSelected(:final search) => search,
    UnappliedPrescriptionError(:final previousState) => previousState.search,
    _ => '',
  };

  Hospitalization? get selectedPatient => switch (this) {
    UnappliedPrescriptionPatientSelected(:final selectedPatient) => selectedPatient,
    UnappliedPrescriptionError(:final previousState) => previousState.selectedPatient,
    _ => null,
  };

  List<PrescriptionItem> get prescriptionItems => switch (this) {
    UnappliedPrescriptionPatientSelected(:final prescriptionItems) => prescriptionItems,
    UnappliedPrescriptionError(:final previousState) => previousState.prescriptionItems,
    _ => const [],
  };

  bool get isPrescriptionsLoading => switch (this) {
    UnappliedPrescriptionPatientSelected(:final isPrescriptionsLoading) => isPrescriptionsLoading,
    _ => false,
  };

  bool get isPatientSelected => switch (this) {
    UnappliedPrescriptionPatientSelected() => true,
    UnappliedPrescriptionError(:final previousState) => previousState.isPatientSelected,
    _ => false,
  };
}
